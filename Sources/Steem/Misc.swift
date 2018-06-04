/// Misc Steem protocol types.
/// - Author: Johan Nordberg <johan@steemit.com>

import Foundation

/// A type that is decodable to Steem binary format as well as JSON encodable and decodable.
public typealias SteemCodable = SteemEncodable & Decodable

/// Placeholder type for future extensions.
public struct FutureExtensions: SteemCodable, Equatable {}
