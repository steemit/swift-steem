/// Steem RPC requests and responses.
/// - Author: Johan Nordberg <johan@steemit.com>

import Foundation

/// Steem RPC API request- and response-types.
public struct API {
    /// Wrapper for pre-appbase steemd calls.
    public struct CallParams<T: Encodable>: Encodable {
        let api: String
        let method: String
        let params: [T]
        init(_ api: String, _ method: String, _ params: [T]) {
            self.api = api
            self.method = method
            self.params = params
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.unkeyedContainer()
            try container.encode(api)
            try container.encode(method)
            try container.encode(params)
        }
    }

    public struct DynamicGlobalProperties: Decodable {
        public let headBlockNumber: UInt32
        public let headBlockId: BlockId
        public let virtualSupply: Asset
        public let currentSupply: Asset
        public let time: Date
    }

    public struct GetDynamicGlobalProperties: Request {
        public typealias Response = DynamicGlobalProperties
        public let method = "get_dynamic_global_properties"
        public init() {}
    }

    public struct TransactionConfirmation: Decodable {
        public let id: Data
        public let blockNum: Int32
        public let trxNum: Int32
        public let expired: Bool
    }

    public struct BroadcastTransaction: Request {
        public typealias Response = TransactionConfirmation
        public let method = "call"
        public let params: CallParams<SignedTransaction>?
        public init(transaction: SignedTransaction) {
            self.params = CallParams("network_broadcast_api", "broadcast_transaction_synchronous", [transaction])
        }
    }

    public struct GetBlock: Request {
        public typealias Response = SignedBlock
        public let method = "get_block"
        public let params: RequestParams<Int>?
        public init(blockNum: Int) {
            self.params = RequestParams([blockNum])
        }
    }
}
