/// Steem signing URLs.
/// - Author: Johan Nordberg <johan@steemit.com>

import Foundation

/// Type representing a Steem signing URL
///
/// See specification at https://github.com/steemit/steem-uri-spec
public struct SteemURL {
    /// All errors `SteemURL` can throw.
    public enum Error: Swift.Error {
        case invalidURL
        case invalidScheme
        case unknownAction
        case malformedAction
        case payloadInvalid
        case invalidCallback
        case invalidSigner
        case signerNotAvailable
    }

    /// Url params, encoded as query strings.
    public struct Params: Equatable {
        /// Requested signer.
        public var signer: String?
        /// The unresolved redirect URL.
        public var callback: String?
        /// Whether to just sign the transaction.
        public var noBroadcast: Bool = false

        public init() {}
        public init(signer _: String? = nil, callback _: String? = nil, noBroadcast _: Bool = false) {}
    }

    /// The signing action.
    public enum PayloadType: String, Equatable {
        case transaction = "tx"
        case operation = "op"
        case operations = "ops"
    }

    /// Parses a steem signing url
    static func parse(_ url: URLComponents) throws -> SteemURL {
        guard url.scheme == "steem" else {
            throw Error.invalidScheme
        }
        guard let action = url.host, action == "sign" else {
            throw Error.unknownAction
        }
        let pathComponents = url.path.split(separator: "/")
        guard pathComponents.count > 1 else {
            throw Error.malformedAction
        }
        guard let type = PayloadType(rawValue: String(pathComponents[0])) else {
            throw Error.unknownAction
        }
        guard
            let data = Data(base64uEncoded: String(pathComponents[1])),
            let payload = try? JSONSerialization.jsonObject(with: data, options: [])
        else {
            throw Error.payloadInvalid
        }
        var params = Params()
        if let queryItems = url.queryItems {
            for item in queryItems {
                switch item.name {
                case "nb":
                    params.noBroadcast = true
                case "cb":
                    guard let value = item.value,
                        let data = Data(base64uEncoded: value),
                        let callback = String(bytes: data, encoding: .utf8)
                    else {
                        throw Error.invalidCallback
                    }
                    params.callback = callback
                case "s":
                    guard let value = item.value else {
                        throw Error.invalidSigner
                    }
                    params.signer = value
                default:
                    break
                }
            }
        }
        return SteemURL(type: type, params: params, payload: payload)
    }

    /// The signing params.
    public let params: Params
    
    let type: PayloadType
    let payload: Any

    /// Create a new SteemURL from a custom payload.
    /// - Note: An invalid payload will cause the `resolve()` method to throw.
    public init(type: PayloadType, params: Params, payload: Any) {
        self.type = type
        self.params = params
        self.payload = payload
    }

    /// Create a new SteemURL from a string
    public init?(string: String) {
        guard let url = URLComponents(string: string),
            let _self = try? SteemURL.parse(url)
        else {
            return nil
        }
        self = _self
    }

    /// Create a new SteemURL from a URL.
    public init?(url: URL) {
        guard let url = URLComponents(url: url, resolvingAgainstBaseURL: true),
            let _self = try? SteemURL.parse(url)
        else {
            return nil
        }
        self = _self
    }

    /// Create a new SteemURL from a set of url components.
    public init?(urlComponents url: URLComponents) {
        guard let _self = try? SteemURL.parse(url) else {
            return nil
        }
        self = _self
    }

    /// Create a new SteemURL with a transaction, `steem://sign/tx/...`
    public init?(transaction: Transaction, params: Params = Params()) {
        guard let payload = try? encodeObject(transaction) else {
            return nil
        }
        self.type = .transaction
        self.payload = payload
        self.params = params
    }

    /// Create a new SteemURL with an operation, `steem://sign/op/...`
    public init?(operation: OperationType, params: Params = Params()) {
        guard let payload = try? encodeObject(AnyOperation(operation)) else {
            return nil
        }
        self.type = .operation
        self.payload = payload
        self.params = params
    }

    /// Create a new SteemURL with several operations, `steem://sign/ops/...`
    public init?(operations: [OperationType], params: Params = Params()) {
        guard let payload = try? encodeObject(operations.map({ AnyOperation($0) })) else {
            return nil
        }
        self.type = .operations
        self.payload = payload
        self.params = params
    }

    /// Options used to resolve a signing url to a signer and transaction.
    public struct ResolveOptions {
        /// The ref block number used to fill in the `__ref_block_num` placeholder.
        public var refBlockNum: UInt16
        /// The ref block prefix used to fill in the `__ref_block_prefix` placeholder.
        public var refBlockPrefix: UInt32
        /// The date string used to fill in the `__expiration` placeholder.
        public var expiration: Date
        /// List of account names available as signers.
        public var signers: [String]
        /// Preferred signer if none is explicitly set in params.
        public var preferredSigner: String

        /// Create a new instance.
        public init(refBlockNum: UInt16, refBlockPrefix: UInt32, expiration: Date, signers: [String], preferredSigner: String) {
            self.refBlockNum = refBlockNum
            self.refBlockPrefix = refBlockPrefix
            self.expiration = expiration
            self.signers = signers
            self.preferredSigner = preferredSigner
        }
    }

    /// Resolve this url to a signer and transaction.
    public func resolve(with options: ResolveOptions) throws -> (signer: String, tx: Transaction) {
        let tx: [String: Any]?
        switch self.type {
        case .transaction:
            tx = self.payload as? [String: Any]
        case .operation, .operations:
            let operations: Any = self.type == .operation ? [self.payload] : self.payload
            tx = [
                "ref_block_num": "__ref_block_num",
                "ref_block_prefix": "__ref_block_prefix",
                "expiration": "__expiration",
                "extensions": [],
                "operations": operations,
            ]
        }
        guard tx != nil else {
            throw Error.payloadInvalid
        }
        let signer = self.params.signer ?? options.preferredSigner
        guard options.signers.contains(signer) else {
            throw Error.signerNotAvailable
        }
        func walk(_ value: Any) -> Any {
            switch value {
            case let str as String:
                if str == "__ref_block_num" { return options.refBlockNum }
                if str == "__ref_block_prefix" { return options.refBlockPrefix }
                if str == "__expiration" { return Client.dateFormatter.string(from: options.expiration) }
                return str.replacingOccurrences(of: "__signer", with: signer)
            case let val as Array<Any>:
                return val.map(walk)
            case let val as Dictionary<String, Any>:
                var rv = Dictionary<String, Any>()
                for (k, v) in val {
                    rv[k] = walk(v)
                }
                return rv
            default:
                return value
            }
        }
        let resolved = walk(tx!)
        let transaction = try decodeObject(Transaction.self, from: resolved)
        return (signer, transaction)
    }

    /// Used to resolve callback urls, should be populated after signed txn has been broadcast.
    public struct CallbackContext {
        /// The signature that the transaction was signed with.
        public var signature: Signature
        /// Transaction hash, should only be set if the transaction was broadcast.
        public var id: String?
        /// Block number transaction was included in, should only be set if the transaction was broadcast.
        public var blockNum: UInt32?
        /// Transaction index in block, should only be set if the transaction was broadcast.
        public var txNum: UInt32?

        public init(signature: Signature) {
            self.signature = signature
        }
    }

    /// Resolves the callback URL.
    /// - Returns: The callback URL with variables populated or nil if no callback param was set.
    public func resolveCallback(with ctx: CallbackContext) -> URL? {
        guard var urlString = self.params.callback else {
            return nil
        }
        urlString = urlString
            .replacingOccurrences(of: "{{sig}}", with: String(ctx.signature))
            .replacingOccurrences(of: "{{id}}", with: ctx.id ?? "")
            .replacingOccurrences(of: "{{block}}", with: ctx.blockNum != nil ? String(ctx.blockNum!) : "")
            .replacingOccurrences(of: "{{txn}}", with: ctx.txNum != nil ? String(ctx.txNum!) : "")
        return URL(string: urlString)
    }

    /// The steem:// URL
    var url: URL? {
        guard let data = try? JSONSerialization.data(withJSONObject: self.payload, options: []) else {
            return nil
        }
        var url = URLComponents()
        url.scheme = "steem"
        url.host = "sign"
        url.path = "/\(self.type.rawValue)/\(data.base64uEncodedString())"
        var query: [URLQueryItem] = []
        if let callback = self.params.callback {
            guard let data = callback.data(using: .utf8) else {
                return nil
            }
            query.append(URLQueryItem(name: "cb", value: data.base64uEncodedString()))
        }
        if self.params.noBroadcast {
            query.append(URLQueryItem(name: "nb", value: nil))
        }
        if let signer = self.params.signer {
            query.append(URLQueryItem(name: "s", value: signer))
        }
        if query.count > 0 {
            url.queryItems = query
        }
        return url.url
    }
}

extension SteemURL: CustomStringConvertible {
    public var description: String {
        guard let url = self.url else {
            return "Invalid SteemURL"
        }
        return url.absoluteString
    }
}

extension SteemURL: Equatable {
    public static func == (lhs: SteemURL, rhs: SteemURL) -> Bool {
        return lhs.url == rhs.url
    }
}

// Object encoder and decoder, could be improved in the future with a DictionaryEncoder/Decoder
// implementation instead of taking the rountdrip to json and back

fileprivate func encodeObject<T: Encodable>(_ value: T) throws -> Any {
    let encoder = Client.JSONEncoder()
    let data = try encoder.encode(value)
    return try JSONSerialization.jsonObject(with: data, options: [])
}

fileprivate func decodeObject<T: Decodable>(_ type: T.Type, from object: Any) throws -> T {
    let decoder = Client.JSONDecoder()
    let json = try JSONSerialization.data(withJSONObject: object, options: [])
    return try decoder.decode(type, from: json)
}

// Base64u encoding & decoding

extension Data {
    init?(base64uEncoded base64uString: String) {
        let base64String = base64uString
            .replacingOccurrences(of: "_", with: "/")
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: ".", with: "=")
        guard let data = Data(base64Encoded: base64String) else {
            return nil
        }
        self = data
    }

    func base64uEncodedString() -> String {
        let base64 = self.base64EncodedString()
        return base64
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "=", with: ".")
    }
}
