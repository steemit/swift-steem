/// Steem authority types.
/// - Author: Johan Nordberg <johan@steemit.com>

import Foundation

/// Type representing a Steem authority.
///
/// Authorities are a collection of accounts and keys that need to sign
/// a message for it to be considered valid.
public struct Authority: SteemCodable, Equatable {
    /// A type representing a key or account auth and its weight.
    public struct Auth<T: SteemCodable & Equatable>: Equatable {
        public let value: T
        public let weight: UInt16
    }

    /// Minimum signing threshold.
    public var weightThreshold: UInt32
    /// Account auths.
    public var accountAuths: [Auth<String>]
    /// Key auths.
    public var keyAuths: [Auth<PublicKey>]
}

extension Authority.Auth {
    public init(_ value: T, weight: UInt16 = 1) {
        self.value = value
        self.weight = weight
    }
}

extension Authority.Auth: SteemCodable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.value = try container.decode(T.self)
        self.weight = try container.decode(UInt16.self)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(self.value)
        try container.encode(self.weight)
    }
}

extension Authority.Auth: ExpressibleByDictionaryLiteral {
    public typealias Key = T
    public typealias Value = UInt16
    public init(dictionaryLiteral elements: (T, UInt16)...) {
        precondition(elements.count == 1, "Account auth dictionary literal can only have one entry")
        self.value = elements[0].0
        self.weight = elements[0].1
    }
}
