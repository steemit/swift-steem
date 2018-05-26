/// Steem operation types.
/// - Author: Johan Nordberg <johan@steemit.com>

import Foundation

/// A type that represents a operation on the Steem blockchain.
public protocol OperationType: SteemEncodable, Decodable {}

/// Operation ID, used for coding.
fileprivate enum OperationId: UInt8, SteemEncodable, Decodable {
    case vote = 0
    case comment = 1
    case transfer = 2

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let name = try container.decode(String.self)
        switch name {
        case "vote": self = .vote
        case "comment": self = .comment
        case "transfer": self = .transfer
        default:
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid operation")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode("\(self)")
    }

    func binaryEncode(to encoder: SteemEncoder) throws {
        try encoder.encode(self.rawValue)
    }
}

/// A type-erased Steem operation.
internal struct AnyOperation: SteemEncodable, Decodable {
    public let operation: OperationType

    /// Create a new operation wrapper.
    public init<O>(_ operation: O) where O: OperationType {
        self.operation = operation
    }

    public init(_ operation: OperationType) {
        self.operation = operation
    }

    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let id = try container.decode(OperationId.self)
        switch id {
        case .vote:
            self.operation = try container.decode(Operation.Vote.self)
        case .comment:
            self.operation = try container.decode(Operation.Comment.self)
        case .transfer:
            self.operation = try container.decode(Operation.Transfer.self)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        switch self.operation {
        case let op as Operation.Vote:
            try container.encode(OperationId.vote)
            try container.encode(op)
        default:
            throw EncodingError.invalidValue(self.operation, EncodingError.Context(
                codingPath: container.codingPath, debugDescription: "Encountered invalid operation type"))
        }
    }
}

/// Namespace for all available Steem operations.
public struct Operation {
    /// Voting operation, votes for content.
    public struct Vote: OperationType {
        /// The account that is casting the vote.
        public let voter: String
        /// The account name that is receieving the vote.
        public let author: String
        /// The content being voted for.
        public let permlink: String
        /// The vote weight. 100% = 10000. A negative value is a "flag".
        public let weight: Int16

        /// Create a new vote operation.
        /// - Parameter voter: The account that is voting for the content.
        /// - Parameter author: The account that is recieving the vote.
        /// - Parameter permlink: The permalink of the content to be voted on,
        /// - Parameter weight: The weight to use when voting, a percentage expressed as -10000 to 10000.
        public init(voter: String, author: String, permlink: String, weight: Int16 = 10000) {
            self.voter = voter
            self.author = author
            self.permlink = permlink
            self.weight = weight
        }
    }

    /// Comment operation, creates comments and posts.
    public struct Comment: OperationType {
        /// The parent content author, left blank for top level posts.
        let parentAuthor: String
        /// The parent content permalink, left blank for top level posts.
        let parentPermlink: String
        /// The account name of the post creator.
        let author: String
        /// The content permalink.
        let permlink: String
        /// The content title.
        let title: String
        /// The content body.
        let body: String
        /// Additional content metadata.
        let jsonMetadata: String

        /// Parsed content metadata.
        var metadata: Any? {
            guard let data = self.jsonMetadata.data(using: .utf8) else {
                return nil
            }
            return try? JSONSerialization.jsonObject(with: data, options: [])
        }
    }

    /// Transfers assets from one account to another.
    public struct Transfer: OperationType {
        /// Account name of the sender.
        let from: String
        /// Account name of the reciever.
        let to: String
        /// Amount to transfer.
        let amount: Asset
        /// Note attached to transaction.
        let memo: String
    }
}
