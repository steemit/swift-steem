/// Steem transaction type.
/// - Author: Johan Nordberg <johan@steemit.com>

import Foundation

public struct Transaction {
    public let refBlockNum: UInt16
    public let refBlockPrefix: UInt32
    public let expiration: Date
    public let operations: [Operation]
    
    /// SHA2-256 digest for signing.
    public var digest: Data {
        /// TODO: This hash needs to include CHAIN_ID
        return Serializer.encode(self).sha256Digest()
    }
}

extension Transaction: Serializable {
    public func write(into data: inout Data) {
        self.refBlockNum.write(into: &data)
        self.refBlockPrefix.write(into: &data)
        self.expiration.write(into: &data)
        Serializer.write(varint: UInt64(self.operations.count), into: &data)
        for operation in self.operations {
            operation.write(into: &data)
        }
        data.append(0) // extensions, unused
    }
}

extension Transaction: Equatable  {
    public static func == (lhs: Transaction, rhs: Transaction) -> Bool {
        return lhs.digest == rhs.digest
    }
}
