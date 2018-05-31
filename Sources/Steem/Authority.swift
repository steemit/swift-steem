/// Steem authority types.
/// - Author: Johan Nordberg <johan@steemit.com>

import Foundation
import OrderedDictionary

/// Type representing a Steem authority.
///
/// Authorities are a collection of accounts and keys that need to sign
/// a message for it to be considered valid.
public struct Authority: Equatable, SteemEncodable, Decodable {
    /// Minimum signing threshold.
    public var weightThreshold: UInt32
    /// Account auths.
    public var accountAuths: OrderedDictionary<String, UInt16>
    /// Key auths.
    public var keyAuths: OrderedDictionary<PublicKey, UInt16>
}
