/// Steem PrivateKey implementation.
/// - Author: Johan Nordberg <johan@steemit.com>

import Foundation

/// A Steem private key.
public struct PrivateKey: Equatable {
    private let secret: Data

    /// For testing, wether to use a counter or random value for ndata when signing.
    internal static var determenisticSignatures: Bool = false

    /// Create a new private key instance from a byte buffer.
    /// - Parameter data: The 33-byte private key where the first byte is the network id (0x80).
    public init?(_ data: Data) {
        guard data.first == 0x80 && data.count == 33 else {
            return nil
        }
        let secret = data.suffix(from: 1)
        guard Secp256k1Context.shared.verify(secretKey: secret) else {
            return nil
        }
        self.secret = secret
    }

    /// Create a new private key instance from a WIF-encoded string.
    /// - Parameter wif: The base58check-encoded string.
    public init?(_ wif: String) {
        guard let data = Data(base58CheckEncoded: wif) else {
            return nil
        }
        self.init(data)
    }

    /// Create a new private key instance from a seed.
    /// - Parameter seed: String that is hashed and used as secret.
    public init?(seed: String) {
        guard let data = seed.data(using: .utf8) else {
            return nil
        }
        self.secret = data.sha256Digest()
    }

    /// Sign a message.
    /// - Parameter message: The 32-byte message to sign.
    public func sign(message: Data) throws -> Signature {
        var result: (Data, Int32)
        var ndata = Data(count: 32)
        repeat {
            if PrivateKey.determenisticSignatures {
                ndata[0] += 1
            } else {
                ndata = Random.bytes(count: 32)
            }
            result = try Secp256k1Context.shared.sign(message: message, secretKey: self.secret, ndata: ndata)
        } while (!isCanonicalSignature(result.0))
        return Signature(signature: result.0, recoveryId: UInt8(result.1))
    }

    /// Derive the public key for this private key.
    /// - Parameter prefix: Address prefix to use when creating key, defaults to main net (STM).
    public func createPublic(prefix: PublicKey.AddressPrefix = .mainNet) -> PublicKey {
        let result = try! Secp256k1Context.shared.createPublic(fromSecret: self.secret)
        return PublicKey(key: result, prefix: prefix)!
    }

    /// The 33-byte private key where the first byte is the network id (0x80).
    public var data: Data {
        var data = self.secret
        data.insert(0x80, at: data.startIndex)
        return data
    }

    /// WIF-encoded string representation of private key.
    public var wif: String {
        return self.data.base58CheckEncodedString()!
    }
}

extension PrivateKey: LosslessStringConvertible {
    public var description: String {
        return self.wif
    }
}

/// Return true if signature is canonical, otherwise false.
internal func isCanonicalSignature(_ signature: Data) -> Bool {
    return (
        (signature[0] & 0x80 == 0) &&
            !(signature[0] == 0 && (signature[1] & 0x80 == 0)) &&
            (signature[32] & 0x80 == 0) &&
            !(signature[32] == 0 && (signature[33] & 0x80 == 0))
    )
}
