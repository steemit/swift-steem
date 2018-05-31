/// Swift libsecp256k1 bindings
/// - Author: Johan Nordberg <johan@steemit.com>

import Foundation
import secp256k1

internal class Secp256k1Context {
    struct Flags: OptionSet {
        let rawValue: Int32
        static let none = Flags(rawValue: SECP256K1_CONTEXT_NONE)
        static let sign = Flags(rawValue: SECP256K1_CONTEXT_SIGN)
        static let verify = Flags(rawValue: SECP256K1_CONTEXT_VERIFY)
    }

    enum Error: Swift.Error {
        /// The secret key is invalid or the nonce generation failed.
        case signingFailed
        /// Unable to parse compact signature
        case invalidSignature
        /// Unable to recover public key from signature
        case recoveryFailed
        /// Invalid private key
        case invalidSecretKey
    }

    /// Shared context.
    static let shared = Secp256k1Context(flags: [.sign, .verify])

    private let ctx: OpaquePointer

    /// Create a new context.
    /// - Parameter flags: Flags used to initialize the context.
    init(flags: Secp256k1Context.Flags = .none) {
        self.ctx = secp256k1_context_create(UInt32(flags.rawValue))
        let seed = Random.bytes(count: 32)
        _ = seed.withUnsafeBytes {
            secp256k1_context_randomize(self.ctx, $0)
        }
    }

    deinit {
        secp256k1_context_destroy(self.ctx)
    }

    /// Verify a private key.
    /// - Parameter secretKey: 32-byte secret key to verify.
    /// - Returns: true if valid; false otherwise.
    func verify(secretKey key: Data) -> Bool {
        return key.withUnsafeBytes {
            secp256k1_ec_seckey_verify(self.ctx, $0) == 1
        }
    }

    /// Serialize a public key.
    /// - Parameter publicKey: Opaque data structure that holds a parsed and valid public key.
    /// - Parameter compressed: Whether to compress the key when serializing.
    /// - Returns: 33-byte or 65-byte public key.
    func serialize(publicKey pubkey: UnsafePointer<secp256k1_pubkey>, compressed: Bool = true) -> Data {
        var size: Int = compressed ? 33 : 65
        let flags = compressed ? SECP256K1_EC_COMPRESSED : SECP256K1_EC_UNCOMPRESSED
        var rv = Data(count: size)
        _ = rv.withUnsafeMutableBytes {
            secp256k1_ec_pubkey_serialize(self.ctx, $0, &size, pubkey, UInt32(flags))
        }
        return rv
    }

    /// Serialize a signature.
    /// - Parameter recoverableSignature: Opaque data structured that holds a parsed ECDSA signature, supporting pubkey recovery.
    /// - Returns: 64-byte signature and recovery id.
    func serialize(recoverableSignature sig: UnsafePointer<secp256k1_ecdsa_recoverable_signature>) -> (Data, Int32) {
        var signature = Data(count: 64)
        var recid: Int32 = -1
        _ = signature.withUnsafeMutableBytes {
            secp256k1_ecdsa_recoverable_signature_serialize_compact(self.ctx, $0, &recid, sig)
        }
        return (signature, recid)
    }

    /// Compute the public key for a secret key.
    /// - Parameter fromSecret: 32-byte secret key.
    /// - Returns: 33-byte compressed public key.
    func createPublic(fromSecret key: Data) throws -> Data {
        let pubkey = UnsafeMutablePointer<secp256k1_pubkey>.allocate(capacity: 1)
        defer { pubkey.deallocate() }
        let success = key.withUnsafeBytes {
            secp256k1_ec_pubkey_create(self.ctx, pubkey, $0) == 1
        }
        guard success else {
            throw Error.invalidSecretKey
        }
        return self.serialize(publicKey: pubkey)
    }

    /// Sign a message.
    /// - Parameter message: 32-byte message to sign.
    /// - Parameter secretKey: 32-byte secret key to sign message with.
    /// - Parameter ndata: 32-bytes of rfc6979 "Additional data", optional.
    /// - Returns: 64-byte signature and recovery id.
    func sign(message: Data, secretKey key: Data, ndata: Data? = nil) throws -> (Data, Int32) {
        let sig = UnsafeMutablePointer<secp256k1_ecdsa_recoverable_signature>.allocate(capacity: 1)
        defer { sig.deallocate() }
        let success = message.withUnsafeBytes { (msgPtr: UnsafePointer<UInt8>) -> Bool in
            return key.withUnsafeBytes { (keyPtr: UnsafePointer<UInt8>) -> Bool in
                if let ndata = ndata {
                    return ndata.withUnsafeBytes { (ndataPtr: UnsafePointer<UInt8>) -> Bool in
                        return secp256k1_ecdsa_sign_recoverable(self.ctx, sig, msgPtr, keyPtr, nil, ndataPtr) == 1
                    }
                } else {
                    return secp256k1_ecdsa_sign_recoverable(self.ctx, sig, msgPtr, keyPtr, nil, nil) == 1
                }
            }
        }
        guard success else {
            throw Error.signingFailed
        }
        return self.serialize(recoverableSignature: sig)
    }

    /// Recover a public key from a message.
    /// - Parameter message: 32-byte message that was signed.
    /// - Parameter signature: 64-byte signature.
    /// - Parameter recoveryId: The recovery id (0, 1, 2 or 3)
    /// - Returns: 33-byte compressed public key.
    func recover(message: Data, signature: Data, recoveryId recid: Int32) throws -> Data {
        let sig = UnsafeMutablePointer<secp256k1_ecdsa_recoverable_signature>.allocate(capacity: 1)
        defer { sig.deallocate() }
        let parseSuccess = signature.withUnsafeBytes {
            secp256k1_ecdsa_recoverable_signature_parse_compact(self.ctx, sig, $0, recid) == 1
        }
        guard parseSuccess else {
            throw Error.invalidSignature
        }
        let pubkey = UnsafeMutablePointer<secp256k1_pubkey>.allocate(capacity: 1)
        defer { pubkey.deallocate() }
        let recoverSuccess = message.withUnsafeBytes {
            secp256k1_ecdsa_recover(self.ctx, pubkey, sig, $0) == 1
        }
        guard recoverSuccess else {
            throw Error.recoveryFailed
        }
        return self.serialize(publicKey: pubkey)
    }
}
