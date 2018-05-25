/// Steem operation types.
/// - Author: Johan Nordberg <johan@steemit.com>

import Foundation

/// A Steem operation.
public protocol Operation: Serializable, Codable {}

/// Voting operation, votes for content.
public struct VoteOperation: Operation {
    /// The account that is casting the vote.
    let voter: String
    /// The account name that is receieving the vote.
    let author: String
    /// The content being voted for.
    let permlink: String
    /// The vote weight. 100% = 10000. A negative value is a "flag".
    let weight: Int16

    /// Create a new vote operation.
    /// - Parameter voter: The account that is voting for the content.
    /// - Parameter author: The account that is recieving the vote.
    /// - Parameter permlink: The permalink of the content to be voted on,
    /// - Parameter weight: The weight to use when voting, a percentage expressed as -10000 to 10000.
    init(voter: String, author: String, permlink: String, weight: Int16 = 10000) {
        self.voter = voter
        self.author = author
        self.permlink = permlink
        self.weight = weight
    }

    public func write(into data: inout Data) {
        Serializer.write(varint: 0, into: &data) // operation id
        self.voter.write(into: &data)
        self.author.write(into: &data)
        self.permlink.write(into: &data)
        self.weight.write(into: &data)
    }
}

/// Comment operation, creates comments and posts.
public struct CommentOperation: Operation {
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

    public func write(into data: inout Data) {
        Serializer.write(varint: 1, into: &data) // operation id
        self.parentAuthor.write(into: &data)
        self.parentPermlink.write(into: &data)
        self.author.write(into: &data)
        self.permlink.write(into: &data)
        self.title.write(into: &data)
        self.body.write(into: &data)
        self.jsonMetadata.write(into: &data)
    }
}
