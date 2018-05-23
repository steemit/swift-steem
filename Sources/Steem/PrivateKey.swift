/**
 Steem PrivateKey implementation.
 - author: Johan Nordberg <johan@steemit.com>
 */

import Foundation

/// A Steem private key.
public struct PrivateKey: Equatable, LosslessStringConvertible {
    private let secret: Data

    /**
     Create a new public key instance from a byte buffer.
     - parameter data: The 65-byte private key where the first byte is the network id (0x80).
    */
    public init?(_ data: Data) {
        guard data[0] == 0x80 else {
            return nil
        }
        let secret = data.suffix(from: 1)
        guard Secp256k1Context.shared.verify(secretKey: secret) else {
            return nil
        }
        self.secret = secret
    }

    /**
     Create a new public key instance from a WIF-encoded string.
     - parameter wif: The base58check-encoded string.
     */
    public init?(_ wif: String) {
        guard let data = Data(base58CheckEncoded: wif) else {
            return nil
        }
        self.init(data)
    }

    /**
     Sign a message.
     - parameter message: The 32-byte message to sign.
     */
    func sign(message: Data) throws -> Signature {
        var result: (Data, Int32)
        repeat {
            result = try Secp256k1Context.shared.sign(message: message, secretKey: self.secret, ndata: Random.bytes(count: 32))
        } while (!isCanonicalSignature(result.0))
        return Signature(signature: result.0, recoveryId: UInt8(result.1))
    }

    /**
     Derive the public key for this private key.
     - parameter prefix: Address prefix to use when creating key, defaults to main net (STM).
     */
    func createPublic(prefix: PublicKey.AddressPrefix = .mainNet) -> PublicKey {
        let result = try! Secp256k1Context.shared.createPublic(fromSecret: self.secret)
        return PublicKey(key: result, prefix: prefix)!
    }

    /// WIF string representation of private key.
    public var description: String {
        var data = self.secret
        data.insert(0x80, at: data.startIndex)
        return Data(data).base58CheckEncodedString()!
    }
}

/**
 Return true if signature is canonical, otherwise false.
 */
internal func isCanonicalSignature(_ signature: Data) -> Bool {
    return (
        (signature[0] & 0x80 == 0) &&
            !(signature[0] == 0 && (signature[1] & 0x80 == 0)) &&
            (signature[32] & 0x80 == 0) &&
            !(signature[32] == 0 && (signature[33] & 0x80 == 0))
    )
}
