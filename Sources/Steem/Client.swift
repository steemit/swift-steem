/// Steem-flavoured JSON-RPC 2.0 client.
/// - Author: Johan Nordberg <johan@steemit.com>

import AnyCodable
import Foundation

/// JSON-RPC 2.0 request type.
///
/// Implementers should provide `Decodable` response types, example:
///
///     struct MyResponse: Decodable {
///         let hello: String
///         let foo: Int
///     }
///     struct MyRequest: Steem.Request {
///         typealias Response = MyResponse
///         let method = "my_method"
///         let params: RequestParams<String>
///         init(name: String) {
///             self.params = RequestParams(["hello": name])
///         }
///     }
///
public protocol Request {
    /// Response type.
    associatedtype Response: Decodable
    /// Request parameter type.
    associatedtype Params: Encodable
    /// JSON-RPC 2.0 method to call.
    var method: String { get }
    /// JSON-RPC 2.0 parameters
    var params: Params? { get }
}

// Default implementation sends a request without params.
extension Request {
    public var params: RequestParams<AnyEncodable>? {
        return nil
    }
}

/// Request parameter helper type. Can wrap any `Encodable` as set of params, either keyed by name or indexed.
public struct RequestParams<T: Encodable> {
    private var named: [String: T]?
    private var indexed: [T]?

    /// Create a new set of named params.
    public init(_ params: [String: T]) {
        self.named = params
    }

    /// Create a new set of ordered params.
    public init(_ params: [T]) {
        self.indexed = params
    }
}

extension RequestParams: Encodable {
    private struct Key: CodingKey {
        var stringValue: String
        init?(stringValue: String) {
            self.stringValue = stringValue
        }

        var intValue: Int?
        init?(intValue: Int) {
            self.intValue = intValue
            self.stringValue = "\(intValue)"
        }
    }

    public func encode(to encoder: Encoder) throws {
        if let params = indexed {
            var container = encoder.unkeyedContainer()
            try container.encode(contentsOf: params)
        } else if let params = self.named {
            var container = encoder.container(keyedBy: Key.self)
            for (key, value) in params {
                try container.encode(value, forKey: Key(stringValue: key)!)
            }
        }
    }
}

/// JSON-RPC 2.0 request payload wrapper.
internal struct RequestPayload<Request: Steem.Request> {
    let request: Request
    let id: Int
}

extension RequestPayload: Encodable {
    fileprivate enum Keys: CodingKey {
        case id
        case jsonrpc
        case method
        case params
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode("2.0", forKey: .jsonrpc)
        try container.encode(self.request.method, forKey: .method)
        try container.encodeIfPresent(self.request.params, forKey: .params)
    }
}

/// JSON-RPC 2.0 response error type.
internal struct ResponseError: Decodable {
    let code: Int
    let message: String
    let data: [String: AnyDecodable]?
    var resolvedData: [String: Any]? {
        return self.data?.mapValues { $0.value as Any }
    }
}

/// JSON-RPC 2.0 response payload wrapper.
internal struct ResponsePayload<T: Request>: Decodable {
    let id: Int?
    let result: T.Response?
    let error: ResponseError?
}

/// URLSession adapter, for testability.
internal protocol SessionAdapter {
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> SessionDataTask
}

internal protocol SessionDataTask {
    func resume()
}

extension URLSessionDataTask: SessionDataTask {}
extension URLSession: SessionAdapter {
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
        return self.seq
    }
}

/// Steem-flavoured JSON-RPC 2.0 client.
public class Client {
    /// Client errors.
    public enum Error: Swift.Error {
        /// Server didn't respond with a valid JSON-RPC 2.0 response.
        case invalidResponse(message: String, error: Swift.Error?)
        /// JSON-RPC 2.0 Error.
        case responseError(code: Int, message: String, data: [String: Any]?)
    }

    /// The RPC Server address.
    public let address: URL

    internal var idgen: IdGenerator = SeqIdGenerator()
    internal var session: SessionAdapter

    /// Create a new client instance.
    /// - Parameter address: The rpc server to connect to.
    /// - Parameter session: The session to use when sending requests to the server.
    public init(address: URL, session: URLSession = URLSession.shared) {
        self.address = address
        self.session = session as SessionAdapter
    }

    /// Return a URLRequest for a JSON-RPC 2.0 request payload.
    internal func urlRequest<T: Request>(for payload: RequestPayload<T>) throws -> URLRequest {
        let encoder = Client.JSONEncoder()
        var urlRequest = URLRequest(url: self.address)
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("swift-steem/1.0", forHTTPHeaderField: "User-Agent")
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = try encoder.encode(payload)
        return urlRequest
    }

    /// Resolve a URLSession dataTask to a `Response`.
    internal func resolveResponse<T: Request>(for payload: RequestPayload<T>, data: Data?, response: URLResponse?) throws -> T.Response? {
        guard let response = response else {
            throw Error.invalidResponse(message: "No response from server", error: nil)
        }
        guard let httpResponse = response as? HTTPURLResponse else {
            throw Error.invalidResponse(message: "Not a HTTP response", error: nil)
        }
        if httpResponse.statusCode != 200 {
            throw Error.invalidResponse(message: "Server responded with HTTP \(httpResponse.statusCode)", error: nil)
        }
        guard let data = data else {
            throw Error.invalidResponse(message: "Response body empty", error: nil)
        }
        let decoder = Client.JSONDecoder()
        let responsePayload: ResponsePayload<T>
        do {
            responsePayload = try decoder.decode(ResponsePayload<T>.self, from: data)
        } catch {
            throw Error.invalidResponse(message: "Unable to decode response", error: error)
        }
        if let error = responsePayload.error {
            throw Error.responseError(code: error.code, message: error.message, data: error.resolvedData)
        }
        if responsePayload.id != payload.id {
            throw Error.invalidResponse(message: "Request id mismatch", error: nil)
        }
        return responsePayload.result
    }

    /// Send a JSON-RPC 2.0 request.
    /// - Parameter request: The request to be sent.
    /// - Parameter completionHandler: Callback function, called with either a response or an error.
    public func send<T: Request>(request: T, completionHandler: @escaping (T.Response?, Swift.Error?) -> Void) -> Void {
        let payload = RequestPayload(request: request, id: self.idgen.next())
        let urlRequest: URLRequest
        do {
            urlRequest = try self.urlRequest(for: payload)
        } catch {
            return completionHandler(nil, error)
        }
        self.session.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                return completionHandler(nil, error)
            }
            let rv: T.Response?
            do {
                rv = try self.resolveResponse(for: payload, data: data, response: response)
            } catch {
                return completionHandler(nil, error)
            }
            completionHandler(rv, nil)
        }.resume()
    }
}

/// JSON Coding helpers.
extension Client {
    /// Steem-style date formatter (ISO 8601 minus Z at the end).
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return formatter
    }()

    static let dateEncoder = Foundation.JSONEncoder.DateEncodingStrategy.custom { (date, encoder) throws in
        var container = encoder.singleValueContainer()
        try container.encode(dateFormatter.string(from: date))
    }

    static let dataEncoder = Foundation.JSONEncoder.DataEncodingStrategy.custom { (data, encoder) throws in
        var container = encoder.singleValueContainer()
        try container.encode(data.hexEncodedString())
    }

    static let dateDecoder = Foundation.JSONDecoder.DateDecodingStrategy.custom { (decoder) -> Date in
        let container = try decoder.singleValueContainer()
        guard let date = dateFormatter.date(from: try container.decode(String.self)) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date")
        }
        return date
    }

    static let dataDecoder = Foundation.JSONDecoder.DataDecodingStrategy.custom { (decoder) -> Data in
        let container = try decoder.singleValueContainer()
        return Data(hexEncoded: try container.decode(String.self))
    }

    static func JSONDecoder() -> Foundation.JSONDecoder {
        let decoder = Foundation.JSONDecoder()
        decoder.dataDecodingStrategy = dataDecoder
        decoder.dateDecodingStrategy = dateDecoder
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }

    static func JSONEncoder() -> Foundation.JSONEncoder {
        let encoder = Foundation.JSONEncoder()
        encoder.dataEncodingStrategy = dataEncoder
        encoder.dateEncodingStrategy = dateEncoder
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }
}
