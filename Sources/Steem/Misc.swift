/// Misc Steem protocol types.
/// - Author: Johan Nordberg <johan@steemit.com>

import Foundation

/// A type that is decodable to Steem binary format as well as JSON encodable and decodable.
public typealias SteemCodable = SteemEncodable & Decodable

/// Placeholder type for future extensions.
public struct FutureExtensions: SteemCodable, Equatable {}

/// Type representing an optional JSON string.
public struct JSONString: Equatable {
    /// The JSON string value, an empty string denotes a nil object.
    public var value: String

    /// The decoded JSON object.
    public var object: [String: Any]? {
        get { return decodeMeta(self.value) }
        set { self.value = encodeMeta(newValue) }
    }

    public init(jsonString: String) {
        self.value = jsonString
    }

    public init(jsonObject: [String: Any]) {
        self.value = encodeMeta(jsonObject)
    }
}

extension JSONString: SteemCodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.value = try container.decode(String.self)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.value)
    }
}

extension JSONString: ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    public init(stringLiteral: String) {
        self.value = stringLiteral
    }
}

fileprivate func encodeMeta(_ value: [String: Any]?) -> String {
    if let object = value,
        let encoded = try? JSONSerialization.data(withJSONObject: object, options: []) {
        return String(bytes: encoded, encoding: .utf8) ?? ""
    } else {
        return ""
    }
}

fileprivate func decodeMeta(_ value: String) -> [String: Any]? {
    guard let data = value.data(using: .utf8) else {
        return nil
    }
    let decoded = try? JSONSerialization.jsonObject(with: data, options: [])
    return decoded as? [String: Any]
}
