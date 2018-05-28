/// Steem operation types.
/// - Author: Johan Nordberg <johan@steemit.com>

import Foundation

/// A type that represents a operation on the Steem blockchain.
public protocol OperationType: SteemEncodable, Decodable {}

/// Namespace for all available Steem operations.
public struct Operation {
    /// Voting operation, votes for content.
    public struct Vote: OperationType, Equatable {
        /// The account that is casting the vote.
        public var voter: String
        /// The account name that is receieving the vote.
        public var author: String
        /// The content being voted for.
        public var permlink: String
        /// The vote weight. 100% = 10000. A negative value is a "flag".
        public var weight: Int16 = 10000

        /// Create a new vote operation.
        /// - Parameter voter: The account that is voting for the content.
        /// - Parameter author: The account that is recieving the vote.
        /// - Parameter permlink: The permalink of the content to be voted on,
        /// - Parameter weight: The weight to use when voting, a percentage expressed as -10000 to 10000.
        public init(voter: String, author: String, permlink: String, weight: Int16 = 10000) {
            self.voter = voter
            self.author = author
            self.permlink = permlink
            self.weight = weight
        }
    }

    /// Comment operation, creates comments and posts.
    public struct Comment: OperationType, Equatable {
        /// The parent content author, left blank for top level posts.
        public var parentAuthor: String = ""
        /// The parent content permalink, left blank for top level posts.
        public var parentPermlink: String = ""
        /// The account name of the post creator.
        public var author: String
        /// The content permalink.
        public var permlink: String
        /// The content title.
        public var title: String
        /// The content body.
        public var body: String
        /// Additional content metadata.
        public var jsonMetadata: String

        public init(
            title: String,
            body: String,
            author: String,
            permlink: String,
            parentAuthor: String = "",
            parentPermlink: String = "",
            jsonMetadata: String = ""
        ) {
            self.parentAuthor = parentAuthor
            self.parentPermlink = parentPermlink
            self.author = author
            self.permlink = permlink
            self.title = title
            self.body = body
            self.jsonMetadata = jsonMetadata
        }

        /// Parsed content metadata.
        var metadata: [String: Any]? {
            guard let data = self.jsonMetadata.data(using: .utf8) else {
                return nil
            }
            let decoded = try? JSONSerialization.jsonObject(with: data, options: [])
            return decoded as? [String: Any]
        }
    }

    /// Transfers assets from one account to another.
    public struct Transfer: OperationType, Equatable {
        /// Account name of the sender.
        public var from: String
        /// Account name of the reciever.
        public var to: String
        /// Amount to transfer.
        public var amount: Asset
        /// Note attached to transaction.
        public var memo: String
    }

    public struct TransferToVesting: OperationType {}
    public struct WithdrawVesting: OperationType {}
    public struct LimitOrderCreate: OperationType {}
    public struct LimitOrderCancel: OperationType {}
    public struct FeedPublish: OperationType {}
    public struct Convert: OperationType {}
    public struct AccountCreate: OperationType {}
    public struct AccountUpdate: OperationType {}
    public struct WitnessUpdate: OperationType {}
    public struct AccountWitnessVote: OperationType {}
    public struct AccountWitnessProxy: OperationType {}
    public struct Pow: OperationType {}
    public struct Custom: OperationType {}
    public struct ReportOverProduction: OperationType {}
    public struct DeleteComment: OperationType {}
    public struct CustomJson: OperationType {}
    public struct CommentOptions: OperationType {}
    public struct SetWithdrawVestingRoute: OperationType {}
    public struct LimitOrderCreate2: OperationType {}
    public struct ChallengeAuthority: OperationType {}
    public struct ProveAuthority: OperationType {}
    public struct RequestAccountRecovery: OperationType {}
    public struct RecoverAccount: OperationType {}
    public struct ChangeRecoveryAccount: OperationType {}
    public struct EscrowTransfer: OperationType {}
    public struct EscrowDispute: OperationType {}
    public struct EscrowRelease: OperationType {}
    public struct Pow2: OperationType {}
    public struct EscrowApprove: OperationType {}
    public struct TransferToSavings: OperationType {}
    public struct TransferFromSavings: OperationType {}
    public struct CancelTransferFromSavings: OperationType {}
    public struct CustomBinary: OperationType {}
    public struct DeclineVotingRights: OperationType {}
    public struct ResetAccount: OperationType {}
    public struct SetResetAccount: OperationType {}
    public struct ClaimRewardBalance: OperationType {}
    public struct DelegateVestingShares: OperationType {}
    public struct AccountCreateWithDelegation: OperationType {}

    /// Unknown operation, seen if the decoder encounters operation which has no type defined.
    /// - Note: Not encodable, the encoder will throw if encountering this operation.
    public struct Unknown: OperationType {}
}

/// Operation ID, used for coding.
fileprivate enum OperationId: UInt8, SteemEncodable, Decodable {
    case vote = 0
    case comment = 1
    case transfer = 2
    case transfer_to_vesting = 3
    case withdraw_vesting = 4
    case limit_order_create = 5
    case limit_order_cancel = 6
    case feed_publish = 7
    case convert = 8
    case account_create = 9
    case account_update = 10
    case witness_update = 11
    case account_witness_vote = 12
    case account_witness_proxy = 13
    case pow = 14
    case custom = 15
    case report_over_production = 16
    case delete_comment = 17
    case custom_json = 18
    case comment_options = 19
    case set_withdraw_vesting_route = 20
    case limit_order_create2 = 21
    case challenge_authority = 22
    case prove_authority = 23
    case request_account_recovery = 24
    case recover_account = 25
    case change_recovery_account = 26
    case escrow_transfer = 27
    case escrow_dispute = 28
    case escrow_release = 29
    case pow2 = 30
    case escrow_approve = 31
    case transfer_to_savings = 32
    case transfer_from_savings = 33
    case cancel_transfer_from_savings = 34
    case custom_binary = 35
    case decline_voting_rights = 36
    case reset_account = 37
    case set_reset_account = 38
    case claim_reward_balance = 39
    case delegate_vesting_shares = 40
    case account_create_with_delegation = 41
    case unknown = 255

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let name = try container.decode(String.self)
        switch name {
        case "vote": self = .vote
        case "comment": self = .comment
        case "transfer": self = .transfer
        case "transfer_to_vesting": self = .transfer_to_vesting
        case "withdraw_vesting": self = .withdraw_vesting
        case "limit_order_create": self = .limit_order_create
        case "limit_order_cancel": self = .limit_order_cancel
        case "feed_publish": self = .feed_publish
        case "convert": self = .convert
        case "account_create": self = .account_create
        case "account_update": self = .account_update
        case "witness_update": self = .witness_update
        case "account_witness_vote": self = .account_witness_vote
        case "account_witness_proxy": self = .account_witness_proxy
        case "pow": self = .pow
        case "custom": self = .custom
        case "report_over_production": self = .report_over_production
        case "delete_comment": self = .delete_comment
        case "custom_json": self = .custom_json
        case "comment_options": self = .comment_options
        case "set_withdraw_vesting_route": self = .set_withdraw_vesting_route
        case "limit_order_create2": self = .limit_order_create2
        case "challenge_authority": self = .challenge_authority
        case "prove_authority": self = .prove_authority
        case "request_account_recovery": self = .request_account_recovery
        case "recover_account": self = .recover_account
        case "change_recovery_account": self = .change_recovery_account
        case "escrow_transfer": self = .escrow_transfer
        case "escrow_dispute": self = .escrow_dispute
        case "escrow_release": self = .escrow_release
        case "pow2": self = .pow2
        case "escrow_approve": self = .escrow_approve
        case "transfer_to_savings": self = .transfer_to_savings
        case "transfer_from_savings": self = .transfer_from_savings
        case "cancel_transfer_from_savings": self = .cancel_transfer_from_savings
        case "custom_binary": self = .custom_binary
        case "decline_voting_rights": self = .decline_voting_rights
        case "reset_account": self = .reset_account
        case "set_reset_account": self = .set_reset_account
        case "claim_reward_balance": self = .claim_reward_balance
        case "delegate_vesting_shares": self = .delegate_vesting_shares
        case "account_create_with_delegation": self = .account_create_with_delegation
        default: self = .unknown
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode("\(self)")
    }

    func binaryEncode(to encoder: SteemEncoder) throws {
        try encoder.encode(self.rawValue)
    }
}

/// A type-erased Steem operation.
internal struct AnyOperation: SteemEncodable, Decodable {
    public let operation: OperationType

    /// Create a new operation wrapper.
    public init<O>(_ operation: O) where O: OperationType {
        self.operation = operation
    }

    public init(_ operation: OperationType) {
        self.operation = operation
    }

    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let id = try container.decode(OperationId.self)
        let op: OperationType
        switch id {
        case .vote: op = try container.decode(Operation.Vote.self)
        case .comment: op = try container.decode(Operation.Comment.self)
        case .transfer: op = try container.decode(Operation.Transfer.self)
        case .transfer_to_vesting: op = try container.decode(Operation.TransferToVesting.self)
        case .withdraw_vesting: op = try container.decode(Operation.WithdrawVesting.self)
        case .limit_order_create: op = try container.decode(Operation.LimitOrderCancel.self)
        case .limit_order_cancel: op = try container.decode(Operation.LimitOrderCancel.self)
        case .feed_publish: op = try container.decode(Operation.FeedPublish.self)
        case .convert: op = try container.decode(Operation.Convert.self)
        case .account_create: op = try container.decode(Operation.AccountCreate.self)
        case .account_update: op = try container.decode(Operation.AccountUpdate.self)
        case .witness_update: op = try container.decode(Operation.WitnessUpdate.self)
        case .account_witness_vote: op = try container.decode(Operation.AccountWitnessVote.self)
        case .account_witness_proxy: op = try container.decode(Operation.AccountWitnessProxy.self)
        case .pow: op = try container.decode(Operation.Pow.self)
        case .custom: op = try container.decode(Operation.Custom.self)
        case .report_over_production: op = try container.decode(Operation.ReportOverProduction.self)
        case .delete_comment: op = try container.decode(Operation.DeleteComment.self)
        case .custom_json: op = try container.decode(Operation.CustomJson.self)
        case .comment_options: op = try container.decode(Operation.CommentOptions.self)
        case .set_withdraw_vesting_route: op = try container.decode(Operation.SetWithdrawVestingRoute.self)
        case .limit_order_create2: op = try container.decode(Operation.LimitOrderCreate2.self)
        case .challenge_authority: op = try container.decode(Operation.ChallengeAuthority.self)
        case .prove_authority: op = try container.decode(Operation.ProveAuthority.self)
        case .request_account_recovery: op = try container.decode(Operation.RequestAccountRecovery.self)
        case .recover_account: op = try container.decode(Operation.RecoverAccount.self)
        case .change_recovery_account: op = try container.decode(Operation.ChangeRecoveryAccount.self)
        case .escrow_transfer: op = try container.decode(Operation.EscrowTransfer.self)
        case .escrow_dispute: op = try container.decode(Operation.EscrowDispute.self)
        case .escrow_release: op = try container.decode(Operation.EscrowRelease.self)
        case .pow2: op = try container.decode(Operation.Pow2.self)
        case .escrow_approve: op = try container.decode(Operation.EscrowApprove.self)
        case .transfer_to_savings: op = try container.decode(Operation.TransferToSavings.self)
        case .transfer_from_savings: op = try container.decode(Operation.TransferFromSavings.self)
        case .cancel_transfer_from_savings: op = try container.decode(Operation.CancelTransferFromSavings.self)
        case .custom_binary: op = try container.decode(Operation.CustomBinary.self)
        case .decline_voting_rights: op = try container.decode(Operation.DeclineVotingRights.self)
        case .reset_account: op = try container.decode(Operation.ResetAccount.self)
        case .set_reset_account: op = try container.decode(Operation.SetResetAccount.self)
        case .claim_reward_balance: op = try container.decode(Operation.ClaimRewardBalance.self)
        case .delegate_vesting_shares: op = try container.decode(Operation.DelegateVestingShares.self)
        case .account_create_with_delegation: op = try container.decode(Operation.AccountCreateWithDelegation.self)
        case .unknown: op = Operation.Unknown()
        }
        self.operation = op
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        switch self.operation {
        case let op as Operation.Vote:
            try container.encode(OperationId.vote)
            try container.encode(op)
        case let op as Operation.Comment:
            try container.encode(OperationId.comment)
            try container.encode(op)
        case let op as Operation.Transfer:
            try container.encode(OperationId.transfer)
            try container.encode(op)
        case let op as Operation.TransferToVesting:
            try container.encode(OperationId.transfer_to_vesting)
            try container.encode(op)
        case let op as Operation.WithdrawVesting:
            try container.encode(OperationId.withdraw_vesting)
            try container.encode(op)
        case let op as Operation.LimitOrderCreate:
            try container.encode(OperationId.limit_order_create)
            try container.encode(op)
        case let op as Operation.LimitOrderCancel:
            try container.encode(OperationId.limit_order_cancel)
            try container.encode(op)
        case let op as Operation.FeedPublish:
            try container.encode(OperationId.feed_publish)
            try container.encode(op)
        case let op as Operation.Convert:
            try container.encode(OperationId.convert)
            try container.encode(op)
        case let op as Operation.AccountCreate:
            try container.encode(OperationId.account_create)
            try container.encode(op)
        case let op as Operation.AccountUpdate:
            try container.encode(OperationId.account_update)
            try container.encode(op)
        case let op as Operation.WitnessUpdate:
            try container.encode(OperationId.witness_update)
            try container.encode(op)
        case let op as Operation.AccountWitnessVote:
            try container.encode(OperationId.account_witness_vote)
            try container.encode(op)
        case let op as Operation.AccountWitnessProxy:
            try container.encode(OperationId.account_witness_proxy)
            try container.encode(op)
        case let op as Operation.Pow:
            try container.encode(OperationId.pow)
            try container.encode(op)
        case let op as Operation.Custom:
            try container.encode(OperationId.custom)
            try container.encode(op)
        case let op as Operation.ReportOverProduction:
            try container.encode(OperationId.report_over_production)
            try container.encode(op)
        case let op as Operation.DeleteComment:
            try container.encode(OperationId.delete_comment)
            try container.encode(op)
        case let op as Operation.CustomJson:
            try container.encode(OperationId.custom_json)
            try container.encode(op)
        case let op as Operation.CommentOptions:
            try container.encode(OperationId.comment_options)
            try container.encode(op)
        case let op as Operation.SetWithdrawVestingRoute:
            try container.encode(OperationId.set_withdraw_vesting_route)
            try container.encode(op)
        case let op as Operation.LimitOrderCreate2:
            try container.encode(OperationId.limit_order_create2)
            try container.encode(op)
        case let op as Operation.ChallengeAuthority:
            try container.encode(OperationId.challenge_authority)
            try container.encode(op)
        case let op as Operation.ProveAuthority:
            try container.encode(OperationId.prove_authority)
            try container.encode(op)
        case let op as Operation.RequestAccountRecovery:
            try container.encode(OperationId.request_account_recovery)
            try container.encode(op)
        case let op as Operation.RecoverAccount:
            try container.encode(OperationId.recover_account)
            try container.encode(op)
        case let op as Operation.ChangeRecoveryAccount:
            try container.encode(OperationId.change_recovery_account)
            try container.encode(op)
        case let op as Operation.EscrowTransfer:
            try container.encode(OperationId.escrow_transfer)
            try container.encode(op)
        case let op as Operation.EscrowDispute:
            try container.encode(OperationId.escrow_dispute)
            try container.encode(op)
        case let op as Operation.EscrowRelease:
            try container.encode(OperationId.escrow_release)
            try container.encode(op)
        case let op as Operation.Pow2:
            try container.encode(OperationId.pow2)
            try container.encode(op)
        case let op as Operation.EscrowApprove:
            try container.encode(OperationId.escrow_approve)
            try container.encode(op)
        case let op as Operation.TransferToSavings:
            try container.encode(OperationId.transfer_to_savings)
            try container.encode(op)
        case let op as Operation.TransferFromSavings:
            try container.encode(OperationId.transfer_from_savings)
            try container.encode(op)
        case let op as Operation.CancelTransferFromSavings:
            try container.encode(OperationId.cancel_transfer_from_savings)
            try container.encode(op)
        case let op as Operation.CustomBinary:
            try container.encode(OperationId.custom_binary)
            try container.encode(op)
        case let op as Operation.DeclineVotingRights:
            try container.encode(OperationId.decline_voting_rights)
            try container.encode(op)
        case let op as Operation.ResetAccount:
            try container.encode(OperationId.reset_account)
            try container.encode(op)
        case let op as Operation.SetResetAccount:
            try container.encode(OperationId.set_reset_account)
            try container.encode(op)
        case let op as Operation.ClaimRewardBalance:
            try container.encode(OperationId.claim_reward_balance)
            try container.encode(op)
        case let op as Operation.DelegateVestingShares:
            try container.encode(OperationId.delegate_vesting_shares)
            try container.encode(op)
        case let op as Operation.AccountCreateWithDelegation:
            try container.encode(OperationId.account_create_with_delegation)
            try container.encode(op)
        default:
            throw EncodingError.invalidValue(self.operation, EncodingError.Context(
                codingPath: container.codingPath, debugDescription: "Encountered unknown operation type"))
        }
    }
}
