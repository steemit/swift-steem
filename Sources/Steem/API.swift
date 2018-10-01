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
    
    public struct TestnetGetDynamicGlobalProperties: Request {
        public typealias Response = DynamicGlobalProperties
        public let method = "call"
        public let params: CallParams<SignedTransaction>?
        public init() {
            self.params = CallParams("condenser_api", "get_dynamic_global_properties", [])
        }
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
    
    public struct TestnetBroadcastTransaction: Request {
        public typealias Response = TransactionConfirmation
        public let method = "call"
        public let params: CallParams<SignedTransaction>?
        public init(transaction: SignedTransaction) {
            self.params = CallParams("condenser_api", "broadcast_transaction_synchronous", [transaction])
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

    public struct Share: Decodable {
        public let value: Int64
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let intValue = try? container.decode(Int64.self) {
                self.value = intValue
            } else {
                self.value = Int64(try container.decode(String.self)) ?? 0
            }
        }
    }

    /// The "extended" account object returned by get_accounts.
    public struct ExtendedAccount: Decodable {
        public let id: Int
        public let name: String
        public let owner: Authority
        public let active: Authority
        public let posting: Authority
        public let memoKey: PublicKey
        public let jsonMetadata: String
        public let proxy: String
        public let lastOwnerUpdate: Date
        public let lastAccountUpdate: Date
        public let created: Date
        public let mined: Bool
        public let recoveryAccount: String
        public let resetAccount: String
        public let lastAccountRecovery: Date
        public let commentCount: UInt32
        public let lifetimeVoteCount: UInt32
        public let postCount: UInt32
        public let canVote: Bool
        public let votingPower: UInt16
        public let lastVoteTime: Date
        public let balance: Asset
        public let savingsBalance: Asset
        public let sbdBalance: Asset
        public let sbdSeconds: String // uint128_t
        public let sbdSecondsLastUpdate: Date
        public let sbdLastInterestPayment: Date
        public let savingsSbdBalance: Asset
        public let savingsSbdSeconds: String // uint128_t
        public let savingsSbdSecondsLastUpdate: Date
        public let savingsSbdLastInterestPayment: Date
        public let savingsWithdrawRequests: UInt8
        public let rewardSbdBalance: Asset
        public let rewardSteemBalance: Asset
        public let rewardVestingBalance: Asset
        public let rewardVestingSteem: Asset
        public let curationRewards: Share
        public let postingRewards: Share
        public let vestingShares: Asset
        public let delegatedVestingShares: Asset
        public let receivedVestingShares: Asset
        public let vestingWithdrawRate: Asset
        public let nextVestingWithdrawal: Date
        public let withdrawn: Share
        public let toWithdraw: Share
        public let withdrawRoutes: UInt16
        public let proxiedVsfVotes: [Share]
        public let witnessesVotedFor: UInt16
        public let lastPost: Date
        public let lastRootPost: Date
    }

    /// Fetch accounts.
    public struct GetAccounts: Request {
        public typealias Response = [ExtendedAccount]
        public let method = "get_accounts"
        public let params: RequestParams<[String]>?
        public init(names: [String]) {
            self.params = RequestParams([names])
        }
    }
}
