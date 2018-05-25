/// Steem protocol serialization.
/// - Author: Johan Nordberg <johan@steemit.com>

import Foundation

/// A type that can encode itself to Steem wire format.
public protocol Serializable {
    /// Appends this value into the given data in Steem wire format.
    func write(into data: inout Data)
}

/// Steem protocol encoder.
public struct Serializer {
    /// Encode a Steem-serializable into a byte buffer.
    static func encode(_ value: Serializable) -> Data {
        var data = Data()
        value.write(into: &data)
        return data
    }

    /// Write variable length integer to buffer.
    internal static func write(varint value: UInt64, into data: inout Data) {
        var v = value
        while v > 127 {
            data.append(UInt8(v & 0x7F | 0x80))
            v >>= 7
        }
        data.append(UInt8(v))
    }
}

extension FixedWidthInteger {
    public func write(into data: inout Data) {
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
    public func write(into data: inout Data) {
        Serializer.write(varint: UInt64(self.utf8.count), into: &data)
        data.append(contentsOf: self.utf8)
    }
}

extension Array: Serializable where Element: Serializable {
    public func write(into data: inout Data) {
        Serializer.write(varint: UInt64(self.count), into: &data)
        for item in self {
            item.write(into: &data)
        }
    }
}

extension OrderedDictionary: Serializable where Key: Serializable, Value: Serializable {
    public func write(into data: inout Data) {
        Serializer.write(varint: UInt64(self.count), into: &data)
        for (key, value) in self {
            key.write(into: &data)
            value.write(into: &data)
        }
    }
}

extension Date: Serializable {
    public func write(into data: inout Data) {
        UInt32(self.timeIntervalSince1970).write(into: &data)
    }
}

extension Data: Serializable {
    public func write(into data: inout Data) {
        data.append(self)
    }
}

extension Bool: Serializable {
    public func write(into data: inout Data) {
        data.append(self ? 1 : 0)
    }
}

extension Optional: Serializable where Wrapped: Serializable {
    public func write(into data: inout Data) {
        if let value = self {
            data.append(1)
            value.write(into: &data)
        } else {
            data.append(0)
        }
    }
}

extension PublicKey: Serializable {
    public func write(into data: inout Data) {
        data.append(self.key)
    }
}
