/**
 Steem-flavoured JSON-RPC 2.0 client.
 - author: Johan Nordberg <johan@steemit.com>
 */

import Foundation

/**

 JSON-RPC 2.0 Request Protocol.

 Implementers are responsible for casting the result to the assoicated `Response` type.

 Example:

     struct MyResponse {
         let hello: String
         let foo: Int
     }

     enum MyError : Error {
         case invalidResponse
     }

     struct MyRequest : Steem.Request {
         typealias Response = MyResponse
         let method = "my_method"
         let params: Any?
         init(name: String) {
             self.params = ["hello": name]
         }
         func response(from result: Any) throws -> Response {
             guard let result = result as? [String: Any],
                   let hello = result["hello"] as? String,
                   let foo = result["foo"] as? Int
             else {
                 throw MyError.invalidResponse
             }
             return MyResponse(hello: hello, foo: foo)
         }
     }

 */
public protocol Request {
    /// Response type of request.
    associatedtype Response
    /// JSON-RPC 2.0 method to call.
    var method: String { get }
    /// JSON-RPC 2.0 parameters
    var params: Any? { get }
    /// Cast response to assoiciated response type.
    func response(from result: Any) throws -> Response
}

public extension Request {
    public var params: Any? {
        return nil
    }
}

/// JSON-RPC 2.0 Request payload wrapper
internal struct Payload<Request: Steem.Request> {
    public let request: Request
    public let version = "2.0"
    public let id: Int
    public let body: Any

    public init (request: Request, id: Int) {
        var body: [String: Any] = [
            "jsonrpc": version,
            "id": id,
            "method": request.method,
        ]
        if let params = request.params {
            body["params"] = params
        }
        self.request = request
        self.id = id
        self.body = body
    }
}

/// URLSession adapter, for testability
internal protocol SessionAdapter {
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> SessionDataTask
}
internal protocol SessionDataTask {
    func resume()
}
extension URLSessionDataTask : SessionDataTask {}
extension URLSession : SessionAdapter {
    internal func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> SessionDataTask {
        let task: URLSessionDataTask = self.dataTask(with: request, completionHandler: completionHandler)
        return task as SessionDataTask
    }
}

/// JSON-RPC 2.0 ID number generator
internal protocol IdGenerator {
    mutating func next() -> Int
}

/// JSON-RPC 2.0 Sequential ID number generator
internal struct SeqIdGenerator: IdGenerator {
    private var seq: Int = 1
    public init() {}
    public mutating func next() -> Int {
        defer {
            seq += 1
        }
        return seq
    }
}

/**
 Steem-flavoured JSON-RPC 2.0 client.
 */
public class Client {

    /// Client errors.
    public enum Error: Swift.Error {
        /// Server didn't respond with a valid JSON-RPC 2.0 response.
        case invalidResponse(message: String, response: HTTPURLResponse?, data: Data?)
        /// JSON-RPC 2.0 Error.
        case responseError(code: Int, message: String, data: Any?)
    }

    /// The RPC Server address.
    public let address: URL

    internal var idgen: IdGenerator = SeqIdGenerator()
    internal var session: SessionAdapter

    /**
     - parameter address: The rpc server to connect to.
     - parameter session: The session to use when sending requests to the server.
     */
    public init(address: URL, session: URLSession = URLSession.shared) {
        self.address = address
        self.session = session as SessionAdapter
    }

    /// Return a URLRequest for a JSON-RPC 2.0 request payload.
    internal func urlRequest<Request: Steem.Request>(for payload: Payload<Request>) throws -> URLRequest {
        var urlRequest = URLRequest(url: self.address)
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("swift-steem/1.0", forHTTPHeaderField: "User-Agent")
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = try JSONSerialization.data(withJSONObject: payload.body)
        return urlRequest
    }

    /// Resolve a URLSession dataTask to a `Response`.
    internal func resolveResponse<Request: Steem.Request>(for payload: Payload<Request>, data: Data?, response: URLResponse?) throws -> Request.Response {
        guard let response = response else {
            throw Error.invalidResponse(message: "No response from server", response: nil, data: data)
        }
        guard let httpResponse = response as? HTTPURLResponse else {
            throw Error.invalidResponse(message: "Not a HTTP response", response: nil, data: data)
        }
        if httpResponse.statusCode != 200 {
            throw Error.invalidResponse(message: "Server responded with HTTP \(httpResponse.statusCode)", response: httpResponse, data: data)
        }
        guard let data = data else {
            throw Error.invalidResponse(message: "Response body empty", response: httpResponse, data: nil)
        }
        let responseBody = try JSONSerialization.jsonObject(with: data, options: [])
        guard let responseDict = responseBody as? [String: Any] else {
            throw Error.invalidResponse(message: "Invalid response object", response: httpResponse, data: data)
        }
        guard let responseId = responseDict["id"] as? Int else {
            throw Error.invalidResponse(message: "Request id missing in response", response: httpResponse, data: data)
        }
        if (payload.id != responseId) {
            throw Error.invalidResponse(message: "Request id mismatch", response: httpResponse, data: data)
        }
        if let error = responseDict["error"] {
            guard let errorDict = error as? [String: Any] else {
                throw Error.invalidResponse(message: "Invalid error object in response", response: httpResponse, data: data)
            }
            guard let code = errorDict["code"] as? Int else {
                throw Error.invalidResponse(message: "Error code missing", response: httpResponse, data: data)
            }
            guard let message = errorDict["message"] as? String else {
                throw Error.invalidResponse(message: "Error message missing", response: httpResponse, data: data)
            }
            throw Error.responseError(code: code, message: message, data: errorDict["data"])
        }
        guard let result = responseDict["result"] else {
            throw Error.invalidResponse(message: "Result missing in response", response: httpResponse, data: data)
        }
        return try payload.request.response(from: result)
    }

    /**
     Send a JSON-RPC 2.0 request.
     - parameter request: The request to be sent.
     - parameter completionHandler: Callback function, called with either a response or an error.
     */
    public func send<Request: Steem.Request>(request: Request, completionHandler: @escaping (Request.Response?, Swift.Error?) -> Void) -> Void {
        let payload = Payload(request: request, id: self.idgen.next())
        let urlRequest: URLRequest
        do {
            urlRequest = try self.urlRequest(for: payload)
        } catch {
            return completionHandler(nil, error)
        }
        self.session.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                return completionHandler(nil, error)
            }
            let rv: Request.Response
            do {
                rv = try self.resolveResponse(for: payload, data: data, response: response)
            } catch {
                return completionHandler(nil, error)
            }
            completionHandler(rv, nil)
        }.resume()
    }
}
