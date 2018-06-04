/// Hex encoding extensions.
/// - Author: Johan Nordberg <johan@steemit.com>

import Foundation

internal extension Data {
    init(hexEncoded string: String) {
        let nibbles = string.unicodeScalars
            .map { $0.hexNibble }
            .filter { $0 != nil }
        var bytes = Array<UInt8>(repeating: 0, count: (nibbles.count + 1) >> 1)
        for (index, nibble) in nibbles.enumerated() {
            var n = nibble!
            if index & 1 == 0 {
                n <<= 4
            }
            bytes[index >> 1] |= n
        }
        self = Data(bytes: bytes)
    }

    struct HexEncodingOptions: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }

    func hexEncodedString(options: HexEncodingOptions = []) -> String {
        let hexDigits = Array((options.contains(.upperCase) ? "0123456789ABCDEF" : "0123456789abcdef").utf16)
        var chars: [unichar] = []
        chars.reserveCapacity(2 * count)
        for byte in self {
            chars.append(hexDigits[Int(byte / 16)])
            chars.append(hexDigits[Int(byte % 16)])
        }
        return String(utf16CodeUnits: chars, count: chars.count)
    }
}

internal extension UnicodeScalar {
    var hexNibble: UInt8? {
        let value = self.value
        if 48 <= value && value <= 57 {
            return UInt8(value - 48)
        } else if 65 <= value && value <= 70 {
            return UInt8(value - 55)
        } else if 97 <= value && value <= 102 {
            return UInt8(value - 87)
        }
        return nil
    }
}
