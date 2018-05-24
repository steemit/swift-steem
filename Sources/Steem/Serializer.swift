/**
 Steem protocol serialization.
 - author: Johan Nordberg <johan@steemit.com>
 */

import Foundation

internal protocol Serializable {
    func toWire(_ data: inout Data)
}

extension FixedWidthInteger {
    func toWire(_ data: inout Data) {
        var value = self.littleEndian
        data.append(UnsafeBufferPointer(start: &value, count: 1))
    }
}

extension UInt8: Serializable {}
extension UInt16: Serializable {}
extension UInt32: Serializable {}
extension UInt64: Serializable {}
extension Int8: Serializable {}
extension Int16: Serializable {}
extension Int32: Serializable {}
extension Int64: Serializable {}

extension String: Serializable {
    func toWire(_ data: inout Data) {
        putVarint(&data, value: UInt64(self.utf8.count))
        data.append(contentsOf: self.utf8)
    }
}

extension Array: Serializable where Element: Serializable {
    func toWire(_ data: inout Data) {
        putVarint(&data, value: UInt64(self.count))
        for item in self {
            item.toWire(&data)
        }
    }
}

extension OrderedDictionary: Serializable where Key: Serializable, Value: Serializable {
    func toWire(_ data: inout Data) {
        putVarint(&data, value: UInt64(self.count))
        for (key, value) in self {
            key.toWire(&data)
            value.toWire(&data)
        }
    }
}

extension Date: Serializable {
    func toWire(_ data: inout Data) {
        UInt32(self.timeIntervalSince1970).toWire(&data)
    }
}

func putVarint(_ data: inout Data, value: UInt64) {
    var v = value
    while v > 127 {
        data.append(UInt8(v & 0x7F | 0x80))
        v >>= 7
    }
    data.append(UInt8(v))
}
