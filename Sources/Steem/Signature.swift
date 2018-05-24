/**
 Steem Signature implementation.
 - author: Johan Nordberg <johan@steemit.com>
 */

import Foundation

/// A Steem signature.
public struct Signature: Equatable, LosslessStringConvertible {
    private let signature: Data
    private let recoveryId: UInt8

    internal init(signature: Data, recoveryId: UInt8) {
        self.signature = signature
        self.recoveryId = recoveryId
    }

    /**
     Create a new signature from a byte buffer.
     - parameter data: The 65-byte signature.
     */
    public init?(_ data: Data) {
        guard data.count == 65 else {
            return nil
        }
        self.init(signature: data.suffix(from: 1), recoveryId: data[0] - 31)
    }

    /**
     Create a new signature from a hex encoded string.
     - parameter hex: The 65-byte hex string.
     */
    public init?(_ hex: String) {
        self.init(Data(hexEncoded: hex))
    }

    /**
     Recover public key used to sign the message.
     - parameter message: The 32-byte message that was signed.
     - parameter prefix: The address prefix to use for the resulting public key, optional.
     - returns: The public key used to create the signature or nil if the recovery was unsucessful.
     */
    public func recover(message: Data, prefix: PublicKey.AddressPrefix = .mainNet) -> PublicKey? {
        guard let key = try? Secp256k1Context.shared.recover(message: message, signature: self.signature, recoveryId: Int32(self.recoveryId)) else {
            return nil
        }
        return PublicKey(key: key, prefix: prefix)!
    }

    /// Hex string representation of signature.
    public var description: String {
        var data = self.signature
        data.insert(self.recoveryId + 31, at: data.startIndex)
        return data.hexEncodedString()
    }
}
