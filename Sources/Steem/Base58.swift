/**
 Base58 parser and encoder.
 - author: Johan Nordberg <johan@steemit.com>
 */

import Crypto
import Foundation

internal extension Data {
    /**
     Creates a new data buffer from a Base58Check-encoded string.
     - parameter base58CheckEncoded: String to decode.
     - parameter graphene: Whether the checksum is graphene-style with ripem160 or double-sha256.
     - note: Returns nil if the check fails or if the string decodes to more than 128 bytes.
    */
    init?(base58CheckEncoded str: String, _ graphene: Bool = false) {
        let len = str.count
        let data = UnsafeMutablePointer<UInt8>.allocate(capacity: len)
        defer { data.deallocate() }
        let res = str.withCString { (ptr: UnsafePointer<CChar>) -> Int32 in
            if graphene {
                return base58gph_decode_check(ptr, data, Int32(len))
            } else {
                return base58_decode_check(ptr, HASHER_SHA2D, data, Int32(len))
            }
        }
        guard res > 0 else {
            return nil
        }
        self = Data(bytes: data, count: Int(res))
    }

    /**
     Returns a Base58Check-encoded string.
     - parameter graphene: Whether to encode with graphene-style ripem160 checksum or double-sha256.
     - note: Returns nil for any data buffer larger than 128 bytes.
     */
    func base58CheckEncodedString(_ graphene: Bool = false) -> String? {
        let len = self.count * 2
        let str = UnsafeMutablePointer<Int8>.allocate(capacity: len)
        defer { str.deallocate() }
        let res = self.withUnsafeBytes { (ptr: UnsafePointer<UInt8>) -> Int32 in
            if graphene {
                return base58gph_encode_check(ptr, Int32(self.count), str, Int32(len))
            } else {
                return base58_encode_check(ptr, Int32(self.count), HASHER_SHA2D, str, Int32(len))
            }
        }
        guard res > 0 else {
            return nil
        }
        return String(cString: str)
    }
}
