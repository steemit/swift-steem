/// Steem transaction type.
/// - Author: Johan Nordberg <johan@steemit.com>

import AnyCodable
import Foundation

fileprivate protocol _Transaction: SteemEncodable, Decodable {
    /// Block number reference.
    var refBlockNum: UInt16 { get }
    /// Block number reference id.
    var refBlockPrefix: UInt32 { get }
    /// Transaction expiration.
    var expiration: Date { get }
    /// Protocol extensions.
    var extensions: [String] { get }
    /// Transaction operations.
    var operations: [OperationType] { get }
    /// SHA2-256 digest for signing.
    func digest(forChain chain: ChainId) throws -> Data
}

public struct Transaction: _Transaction {
    public var refBlockNum: UInt16
    public var refBlockPrefix: UInt32
    public var expiration: Date
    public var extensions: [String]
    public var operations: [OperationType] {
        return self._operations.map { $0.operation }
    }

    internal var _operations: [AnyOperation]

    /// Create a new transaction.
    public init(refBlockNum: UInt16, refBlockPrefix: UInt32, expiration: Date, operations: [OperationType] = [], extensions: [String] = []) {
        self.refBlockNum = refBlockNum
        self.refBlockPrefix = refBlockPrefix
        self.expiration = expiration
        self._operations = operations.map { AnyOperation($0) }
        self.extensions = extensions
    }

    /// Append an operation to the transaction.
    public mutating func append(operation: OperationType) {
        self._operations.append(AnyOperation(operation))
    }

    /// Sign transaction.
    public func sign(usingKey key: PrivateKey, forChain chain: ChainId = .mainNet) throws -> SignedTransaction {
        var signed = SignedTransaction(transaction: self)
        try signed.appendSignature(usingKey: key, forChain: chain)
        return signed
    }

    /// SHA2-256 digest for signing.
    public func digest(forChain chain: ChainId = .mainNet) throws -> Data {
        var data = chain.data
        data.append(try SteemEncoder.encode(self))
        return data.sha256Digest()
    }
}

extension Transaction: Equatable {
    public static func == (lhs: Transaction, rhs: Transaction) -> Bool {
        return (try? lhs.digest()) == (try? rhs.digest())
    }
}

/// A signed transaction.
public struct SignedTransaction: _Transaction, Equatable {
    /// Transaction signatures.
    public var signatures: [Signature]

    private var transaction: Transaction

    /// Create a new signed transaction.
    /// - Parameter transaction: Transaction to wrap.
    /// - Parameter signatures: Transaction signatures.
    public init(transaction: Transaction, signatures: [Signature] = []) {
        self.transaction = transaction
        self.signatures = signatures
    }

    /// Append a signature to the transaction.
    public mutating func appendSignature(_ signature: Signature) {
        self.signatures.append(signature)
    }

    /// Sign transaction and append signature.
    /// - Parameter key: Private key to sign transaction with.
    /// - Parameter chain: Chain id to use when signing.
    public mutating func appendSignature(usingKey key: PrivateKey, forChain chain: ChainId = .mainNet) throws {
        let signature = try key.sign(message: self.transaction.digest(forChain: chain))
        signatures.append(signature)
    }

    // Transaction proxy.

    public var refBlockNum: UInt16 {
        return self.transaction.refBlockNum
    }

    public var refBlockPrefix: UInt32 {
        return self.transaction.refBlockPrefix
    }

    public var expiration: Date {
        return self.transaction.expiration
    }

    public var extensions: [String] {
        return self.transaction.extensions
    }

    public var operations: [OperationType] {
        return self.transaction.operations
    }

    public func digest(forChain chain: ChainId = .mainNet) throws -> Data {
        return try self.transaction.digest(forChain: chain)
    }
}

// Codable conformance.
extension Transaction {
    fileprivate enum Key: CodingKey {
        case refBlockNum
        case refBlockPrefix
        case expiration
        case operations
        case extensions
        case signatures
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        self.refBlockNum = try container.decode(UInt16.self, forKey: .refBlockNum)
        self.refBlockPrefix = try container.decode(UInt32.self, forKey: .refBlockPrefix)
        self.expiration = try container.decode(Date.self, forKey: .expiration)
        self._operations = try container.decode([AnyOperation].self, forKey: .operations)
        self.extensions = try container.decode([String].self, forKey: .extensions)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Key.self)
        try container.encode(self.refBlockNum, forKey: .refBlockNum)
        try container.encode(self.refBlockPrefix, forKey: .refBlockPrefix)
        try container.encode(self.expiration, forKey: .expiration)
        try container.encode(self._operations, forKey: .operations)
        try container.encode(self.extensions, forKey: .extensions)
    }
}

extension SignedTransaction {
    private enum Key: CodingKey {
        case signatures
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        self.signatures = try container.decode([Signature].self, forKey: .signatures)
        self.transaction = try Transaction(from: decoder)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Key.self)
        try self.transaction.encode(to: encoder)
        try container.encode(self.signatures, forKey: .signatures)
    }
}

// Workaround for: Swift runtime does not yet support dynamically querying conditional conformance.
#if !swift(>=4.2)
    extension Transaction {
        public func binaryEncode(to encoder: SteemEncoder) throws {
            try encoder.encode(self.refBlockNum)
            try encoder.encode(self.refBlockPrefix)
            try encoder.encode(self.expiration)
            encoder.appendVarint(UInt64(self.operations.count))
            for operation in self._operations {
                try operation.binaryEncode(to: encoder)
            }
            encoder.appendVarint(UInt64(self.extensions.count))
            for ext in self.extensions {
                ext.binaryEncode(to: encoder)
            }
        }
    }
#endif
