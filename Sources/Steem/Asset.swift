/// Steem token types.
/// - Author: Johan Nordberg <johan@steemit.com>

import Foundation

struct Asset {
    enum Symbol {
        /// The STEEM token.
        case steem
        /// Vesting shares.
        case vests
        /// Steem-backed dollars.
        case sbd
        /// Custom token.
        case custom(name: String, precision: UInt8)
    }

    let amount: Int64
    let symbol: Symbol

    init(_ value: Double, symbol: Symbol = .steem) {
        self.amount = Int64(round(value * pow(10, Double(symbol.precision))))
        self.symbol = symbol
    }

    init?(_ value: String) {
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
            let precision: UInt8 = ap.count == 2 ? UInt8(ap[1].count) : 1
            symbol = .custom(name: String(parts[1]), precision: precision)
        }
        guard let val = Double(parts[0]) else {
            return nil
        }
        self.init(val, symbol: symbol)
    }
}

extension Asset: Serializable {
    func write(into data: inout Data) {
        self.amount.write(into: &data)
        self.symbol.precision.write(into: &data)
        let chars = self.symbol.name.utf8
        for char in chars {
            data.append(char)
        }
        for _ in 0 ..< 7 - chars.count {
            data.append(0)
        }
    }
}

extension Asset.Symbol {
    /// Symbol precision.
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
