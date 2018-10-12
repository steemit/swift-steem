/// Steem chain identifiers.
/// - Author: Johan Nordberg <johan@steemit.com>

import Foundation

/// Chain id, used to sign transactions.
public enum ChainId: Equatable {
    /// The main Steem network.
    case mainNet
    /// Defualt testing network id.
    case testNet
    /// Custom chain id.
    case custom(Data)
}

fileprivate let mainNetId = Data(hexEncoded: "0000000000000000000000000000000000000000000000000000000000000000")
fileprivate let testNetId = Data(hexEncoded: "9afbce9f2416520733bacb370315d32b6b2c43d6097576df1c1222859d91eecc")

extension ChainId {
    /// The 32-byte chain id.
    public var data: Data {
        switch self {
        case .mainNet:
            return mainNetId
        case .testNet:
            return testNetId
        case let .custom(id):
            return id
        }
    }
}
