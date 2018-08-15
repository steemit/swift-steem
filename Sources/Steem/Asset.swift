/// Steem token types.
/// - Author: Johan Nordberg <johan@steemit.com>

import Foundation

/// The Steem asset type.
public struct Asset: Equatable {
    /// Asset symbol type, containing the symbol name and precision.
    public enum Symbol: Equatable {
        /// The STEEM token.
        case steem
        /// Vesting shares.
        case vests
        /// Steem-backed dollars.
        case sbd
        /// Custom token.
        case custom(name: String, precision: UInt8)

        /// Number of decimal points represented.
        var precision: UInt8 {
            switch self {
            case .steem, .sbd:
                return 3
            case .vests:
                return 6
            case let .custom(_, precision):
                return precision
            }
        }

        /// String representation of symbol prefix, e.g. "STEEM".
        public var name: String {
            switch self {
            case .steem:
                return "STEEM"
            case .sbd:
                return "SBD"
            case .vests:
                return "VESTS"
            case let .custom(name, _):
                return name.uppercased()
            }
        }
    }

    /// The asset symbol.
    public let symbol: Symbol

    internal let amount: Int64
    /// Create a new `Asset`.
    /// - Parameter value: Amount of tokens.
    /// - Parameter symbol: Token symbol.
    public init(_ value: Double, _ symbol: Symbol = .steem) {
        self.amount = Int64(round(value * pow(10, Double(symbol.precision))))
        self.symbol = symbol
    }

    /// Create a new `Asset` from a string representation.
    /// - Parameter value: String to parse into asset, e.g. `1.000 STEEM`.
    public init?(_ value: String) {
        let parts = value.split(separator: " ")
        guard parts.count == 2 else {
            return nil
        }
        let symbol: Symbol
        switch parts[1] {
        case "STEEM":
            symbol = .steem
        case "VESTS":
            symbol = .vests
        case "SBD":
            symbol = .sbd
        default:
            let ap = parts[0].split(separator: ".")
            let precision: UInt8 = ap.count == 2 ? UInt8(ap[1].count) : 0
            symbol = .custom(name: String(parts[1]), precision: precision)
        }
        guard let val = Double(parts[0]) else {
            return nil
        }
        self.init(val, symbol)
    }
}

/// Type representing a quotation of the relative value of asset against another asset.
public struct Price: Equatable, SteemEncodable, Decodable {
    /// The base asset.
    public var base: Asset
    /// The quote asset.
    public var quote: Asset
}

extension Asset {
    public var formattedAmount: Double {
        return Double(self.amount) / pow(10, Double(self.symbol.precision))
    }
}

extension Asset: LosslessStringConvertible {
    public var description: String {
        let value = self.formattedAmount
        let formatter = NumberFormatter()
        formatter.decimalSeparator = "."
        formatter.usesGroupingSeparator = false
        formatter.minimumIntegerDigits = 1
        formatter.minimumFractionDigits = Int(self.symbol.precision)
        formatter.maximumFractionDigits = Int(self.symbol.precision)
        let formatted = formatter.string(from: NSNumber(value: value))!
        return "\(formatted) \(self.symbol.name)"
    }
}



extension Asset: SteemEncodable, Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        guard let asset = Asset(value) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Not a valid asset string")
        }
        self = asset
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(String(self))
    }

    public func binaryEncode(to encoder: SteemEncoder) throws {
        try encoder.encode(self.amount)
        try encoder.encode(self.symbol.precision)
        let chars = self.symbol.name.utf8
        for char in chars {
            encoder.data.append(char)
        }
        for _ in 0 ..< 7 - chars.count {
            encoder.data.append(0)
        }
    }
}
