/**
 Steem PublicKey implementation.
 - author: Johan Nordberg <johan@steemit.com>
 */

import Foundation

/// A Steem public key.
public struct PublicKey: Equatable, LosslessStringConvertible {
    /// Chain address prefix.
    public enum AddressPrefix: Equatable {
        case mainNet
        case testNet
        case custom(String)
    }

    /// Address prefix.
    public let prefix: AddressPrefix

    /// The 33-byte compressed public key.
    public let key: Data

    /**
     Create a new PublicKey instance.
     - parameter key: 33-byte compressed public key.
     - parameter prefix: Network address prefix.
     */
    public init?(key: Data, prefix: AddressPrefix = .mainNet) {
        guard key.count == 33 else {
            return nil
        }
        self.key = key
        self.prefix = prefix
    }

    /**
     Create a new PublicKey instance.
     - parameter address: The public key in Steem address format.
     */
    public init?(_ address: String) {
        let key = address.suffix(50)
        guard key.count == 50 else {
            return nil
        }
        let prefix = address.prefix(upTo: key.startIndex)
        guard prefix.count > 0 else {
            return nil
        }
        guard let keyData = Data(base58CheckEncoded: String(key), options: .grapheneChecksum) else {
            return nil
        }
        self.prefix = AddressPrefix(String(prefix))
        self.key = keyData
        print(keyData.count)
    }

    /// Public key address string.
    public var description: String {
        return String(self.prefix) + self.key.base58CheckEncodedString(options: .grapheneChecksum)!
    }
}

extension PublicKey.AddressPrefix: ExpressibleByStringLiteral, LosslessStringConvertible {
    public typealias StringLiteralType = String

    public init(_ value: String) {
        if value == "STM" {
            self = .mainNet
        } else if value == "TST" {
            self = .testNet
        } else {
            self = .custom(value)
        }
    }

    public init(stringLiteral value: String) {
        self.init(value)
    }

    public var description: String {
        switch self {
        case .mainNet:
            return "STM"
        case .testNet:
            return "TST"
        case let .custom(prefix):
            return prefix.uppercased()
        }
    }
}
