/// Steem block types.
/// - Author: Johan Nordberg <johan@steemit.com>

import Foundation

/// Type representing a Steem block ID.
public struct BlockId: Codable, Equatable {
    /// The block hash.
    public var hash: Data
    /// The block number.
    public var num: UInt32 {
        return UInt32(bigEndian: self.hash.withUnsafeBytes { $0.pointee })
    }

    /// The block prefix.
    public var prefix: UInt32 {
        return UInt32(littleEndian: self.hash.suffix(from: 4).withUnsafeBytes { $0.pointee })
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.hash = try container.decode(Data.self)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.hash)
    }
}

/// Block extensions used for signaling.
public enum BlockExtension: Equatable {
    /// Unknown block extension.
    case unknown
    /// Witness version reporting.
    case version(String)
    /// Witness hardfork vote.
    case hardforkVersionVote(String)
}

/// Internal protocol for a block header.
fileprivate protocol _BlockHeader: Codable {
    /// The block id of the block preceding this one.
    var previous: BlockId { get }
    /// Time when block was generated.
    var timestamp: Date { get }
    /// Witness who produced it.
    var witness: String { get }
    /// Merkle root hash, ripemd160.
    var transactionMerkleRoot: Data { get }
    /// Block extensions.
    var extensions: [BlockExtension] { get }
}

/// A type representing a Steem block header.
public struct BlockHeader: _BlockHeader {
    public let previous: BlockId
    public let timestamp: Date
    public let witness: String
    public let transactionMerkleRoot: Data
    public let extensions: [BlockExtension]
}

/// A type representing a signed Steem block header.
public struct SignedBlockHeader: _BlockHeader, Equatable {
    public let previous: BlockId
    public let timestamp: Date
    public let witness: String
    public let transactionMerkleRoot: Data
    public let extensions: [BlockExtension]
    public let witnessSignature: Signature
}

/// A type representing a Steem block.
public struct SignedBlock: _BlockHeader, Equatable {
    /// The transactions included in this block.
    public let transactions: [Transaction]
    /// The block number.
    public var num: UInt32 {
        return self.header.previous.num + 1
    }

    private let header: SignedBlockHeader

    /// Create a new Signed block.
    public init(header: SignedBlockHeader, transactions: [Transaction]) {
        self.header = header
        self.transactions = transactions
    }

    // Header proxy.
    public var previous: BlockId { return self.header.previous }
    public var timestamp: Date { return self.header.timestamp }
    public var witness: String { return self.header.witness }
    public var transactionMerkleRoot: Data { return self.header.transactionMerkleRoot }
    public var extensions: [BlockExtension] { return self.header.extensions }
    public var witnessSignature: Signature { return self.header.witnessSignature }

    private enum Key: CodingKey {
        case transactions
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        self.transactions = try container.decode([Transaction].self, forKey: .transactions)
        self.header = try SignedBlockHeader(from: decoder)
    }

    public func encode(to encoder: Encoder) throws {
        try self.header.encode(to: encoder)
        var container = encoder.container(keyedBy: Key.self)
        try container.encode(self.transactions, forKey: .transactions)
    }
}

extension BlockExtension: Codable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let type = try container.decode(Int.self)
        switch type {
        case 1:
            self = .version(try container.decode(String.self))
        case 2:
            fatalError("CANT DECODE NUMBER 2 EXTENSION")
            self = .hardforkVersionVote(try container.decode(String.self))
        default:
            self = .unknown
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        switch self {
        case .version(let version):
            try container.encode(1 as Int)
            try container.encode(version)
        case .hardforkVersionVote(let version):
            try container.encode(2 as Int)
            try container.encode(version)
        default:
            break
        }
    }
}

