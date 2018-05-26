/// Steem transaction type.
/// - Author: Johan Nordberg <johan@steemit.com>

import AnyCodable
import Foundation

public struct Transaction: SteemEncodable, Decodable {
    /// Block number reference.
    public let refBlockNum: UInt16
    /// Block number reference id.
    public let refBlockPrefix: UInt32
    /// Transaction expiration.
    public let expiration: Date
    /// Protocol extensions.
    public let extensions: [String]
    /// Transaction operations.
    public var operations: [OperationType] {
        return self._operations.map { $0.operation }
    }

    internal let _operations: [AnyOperation]

    public init(refBlockNum: UInt16, refBlockPrefix: UInt32, expiration: Date, operations: [OperationType], extensions: [String] = []) {
        self.refBlockNum = refBlockNum
        self.refBlockPrefix = refBlockPrefix
        self.expiration = expiration
        self._operations = operations.map { AnyOperation($0) }
        self.extensions = extensions
    }

    /// SHA2-256 digest for signing.
    public func digest(forChain id: ChainId) -> Data {
        var data = id.data
        data.append(try! SteemEncoder.encode(self))
        return data.sha256Digest()
    }
}

extension Transaction: Equatable {
    public static func == (lhs: Transaction, rhs: Transaction) -> Bool {
        return lhs.digest(forChain: .mainNet) == rhs.digest(forChain: .mainNet)
    }
}

// `Coding` conformance.
extension Transaction {
    private enum Key: CodingKey {
        case refBlockNum
        case refBlockPrefix
        case expiration
        case operations
        case extensions
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

// Workaround for: Swift runtime does not yet support dynamically querying conditional conformance.
// Should be safe to remove once 4.2 is released.
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
