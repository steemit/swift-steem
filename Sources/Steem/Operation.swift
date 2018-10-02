/// Steem operation types.
/// - Author: Johan Nordberg <johan@steemit.com>

import Foundation

/// A type that represents a operation on the Steem blockchain.
public protocol OperationType: SteemCodable {
    /// Whether the operation is virtual or not.
    var isVirtual: Bool { get }
}

extension OperationType {
    public var isVirtual: Bool { return false }
}

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
        public var jsonMetadata: JSONString

        public init(
            title: String,
            body: String,
            author: String,
            permlink: String,
            parentAuthor: String = "",
            parentPermlink: String = "",
            jsonMetadata: JSONString = ""
        ) {
            self.parentAuthor = parentAuthor
            self.parentPermlink = parentPermlink
            self.author = author
            self.permlink = permlink
            self.title = title
            self.body = body
            self.jsonMetadata = jsonMetadata
        }

        /// Content metadata.
        var metadata: [String: Any]? {
            set { self.jsonMetadata.object = newValue }
            get { return self.jsonMetadata.object }
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

        public init(from: String, to: String, amount: Asset, memo: String = "") {
            self.from = from
            self.to = to
            self.amount = amount
            self.memo = memo
        }
    }

    /// Converts STEEM to VESTS, aka. "Powering Up".
    public struct TransferToVesting: OperationType, Equatable {
        /// Account name of sender.
        public var from: String
        /// Account name of reciever.
        public var to: String
        /// Amount to power up, must be STEEM.
        public var amount: Asset

        public init(from: String, to: String, amount: Asset) {
            self.from = from
            self.to = to
            self.amount = amount
        }
    }

    /// Starts a vesting withdrawal, aka. "Powering Down".
    public struct WithdrawVesting: OperationType, Equatable {
        /// Account that is powering down.
        public var account: String
        /// Amount that is powered down, must be VESTS.
        public var vestingShares: Asset

        public init(account: String, vestingShares: Asset) {
            self.account = account
            self.vestingShares = vestingShares
        }
    }

    /// This operation creates a limit order and matches it against existing open orders.
    public struct LimitOrderCreate: OperationType, Equatable {
        public var owner: String
        public var orderid: UInt32
        public var amountToSell: Asset
        public var minToReceive: Asset
        public var fillOrKill: Bool
        public var expiration: Date

        public init(
            owner: String,
            orderid: UInt32,
            amountToSell: Asset,
            minToReceive: Asset,
            fillOrKill: Bool,
            expiration: Date
        ) {
            self.owner = owner
            self.orderid = orderid
            self.amountToSell = amountToSell
            self.minToReceive = minToReceive
            self.fillOrKill = fillOrKill
            self.expiration = expiration
        }
    }

    /// Cancels an order and returns the balance to owner.
    public struct LimitOrderCancel: OperationType, Equatable {
        public var owner: String
        public var orderid: UInt32

        public init(owner: String, orderid: UInt32) {
            self.owner = owner
            self.orderid = orderid
        }
    }

    /// Publish a price feed.
    public struct FeedPublish: OperationType, Equatable {
        public var publisher: String
        public var exchangeRate: Price

        public init(publisher: String, exchangeRate: Price) {
            self.publisher = publisher
            self.exchangeRate = exchangeRate
        }
    }

    /// Convert operation.
    public struct Convert: OperationType, Equatable {
        public var owner: String
        public var requestid: UInt32
        public var amount: Asset

        public init(owner: String, requestid: UInt32, amount: Asset) {
            self.owner = owner
            self.requestid = requestid
            self.amount = amount
        }
    }

    /// Creates a new account.
    public struct AccountCreate: OperationType, Equatable {
        public var fee: Asset
        public var creator: String
        public var newAccountName: String
        public var owner: Authority
        public var active: Authority
        public var posting: Authority
        public var memoKey: PublicKey
        public var jsonMetadata: JSONString

        public init(
            fee: Asset,
            creator: String,
            newAccountName: String,
            owner: Authority,
            active: Authority,
            posting: Authority,
            memoKey: PublicKey,
            jsonMetadata: JSONString = ""
        ) {
            self.fee = fee
            self.creator = creator
            self.newAccountName = newAccountName
            self.owner = owner
            self.active = active
            self.posting = posting
            self.memoKey = memoKey
            self.jsonMetadata = jsonMetadata
        }

        /// Account metadata.
        var metadata: [String: Any]? {
            set { self.jsonMetadata.object = newValue }
            get { return self.jsonMetadata.object }
        }
    }

    /// Updates an account.
    public struct AccountUpdate: OperationType, Equatable {
        public var account: String
        public var owner: Authority?
        public var active: Authority?
        public var posting: Authority?
        public var memoKey: PublicKey
        public var jsonMetadata: String

        public init(
            account: String,
            owner: Authority?,
            active: Authority?,
            posting: Authority?,
            memoKey: PublicKey,
            jsonMetadata: String = ""
        ) {
            self.account = account
            self.owner = owner
            self.active = active
            self.posting = posting
            self.memoKey = memoKey
            self.jsonMetadata = jsonMetadata
        }
    }

    /// Registers or updates witnesses.
    public struct WitnessUpdate: OperationType, Equatable {
        /// Witness chain properties.
        public struct Properties: SteemCodable, Equatable {
//            public var accountCreationFee: Asset
//            public var maximumBlockSize: UInt32
//            public var sbdInterestRate: UInt16
        }

        public var owner: String
        public var url: String
        public var blockSigningKey: PublicKey
        public var props: Properties
        public var fee: Asset

        public init(
            owner: String,
            url: String,
            blockSigningKey: PublicKey,
            props: Properties,
            fee: Asset
        ) {
            self.owner = owner
            self.url = url
            self.blockSigningKey = blockSigningKey
            self.props = props
            self.fee = fee
        }
    }

    /// Votes for a witness.
    public struct AccountWitnessVote: OperationType, Equatable {
        public var account: String
        public var witness: String
        public var approve: Bool

        public init(account: String, witness: String, approve: Bool) {
            self.account = account
            self.witness = witness
            self.approve = approve
        }
    }

    /// Sets a witness voting proxy.
    public struct AccountWitnessProxy: OperationType, Equatable {
        public var account: String
        public var proxy: String

        public init(account: String, proxy: String) {
            self.account = account
            self.proxy = proxy
        }
    }

    /// Submits a proof of work, legacy.
    public struct Pow: OperationType, Equatable {}

    /// Custom operation.
    public struct Custom: OperationType, Equatable {
        public var requiredAuths: [String]
        public var id: UInt16
        public var data: Data

        public init(
            requiredAuths: [String],
            id: UInt16,
            data: Data
        ) {
            self.requiredAuths = requiredAuths
            self.id = id
            self.data = data
        }
    }

    /// Reports a producer who signs two blocks at the same time.
    public struct ReportOverProduction: OperationType, Equatable {
        public var reporter: String
        public var firstBlock: SignedBlockHeader
        public var secondBlock: SignedBlockHeader

        public init(
            reporter: String,
            firstBlock: SignedBlockHeader,
            secondBlock: SignedBlockHeader
        ) {
            self.reporter = reporter
            self.firstBlock = firstBlock
            self.secondBlock = secondBlock
        }
    }

    /// Deletes a comment.
    public struct DeleteComment: OperationType, Equatable {
        public var author: String
        public var permlink: String

        public init(author: String, permlink: String) {
            self.author = author
            self.permlink = permlink
        }
    }

    /// A custom JSON operation.
    public struct CustomJson: OperationType, Equatable {
        public var requiredAuths: [String]
        public var requiredPostingAuths: [String]
        public var id: String
        public var json: JSONString

        public init(
            requiredAuths: [String],
            requiredPostingAuths: [String],
            id: String,
            json: JSONString
        ) {
            self.requiredAuths = requiredAuths
            self.requiredPostingAuths = requiredPostingAuths
            self.id = id
            self.json = json
        }
    }

    /// Sets comment options.
    public struct CommentOptions: OperationType, Equatable {
        public struct BeneficiaryRoute: SteemCodable, Equatable {
            public var account: String
            public var weight: UInt16
        }

        /// Comment option extensions.
        public enum Extension: SteemCodable, Equatable {
            /// Unknown extension.
            case unknown
            /// Comment payout routing.
            case commentPayoutBeneficiaries([BeneficiaryRoute])
        }

        public var author: String
        public var permlink: String
        public var maxAcceptedPayout: Asset
        public var percentSteemDollars: UInt16
        public var allowVotes: Bool
        public var allowCurationRewards: Bool
        public var extensions: [Extension]

        public init(
            author: String,
            permlink: String,
            maxAcceptedPayout: Asset,
            percentSteemDollars: UInt16,
            allowVotes: Bool = true,
            allowCurationRewards: Bool = true,
            extensions: [Extension] = []
        ) {
            self.author = author
            self.permlink = permlink
            self.maxAcceptedPayout = maxAcceptedPayout
            self.percentSteemDollars = percentSteemDollars
            self.allowVotes = allowVotes
            self.allowCurationRewards = allowCurationRewards
            self.extensions = extensions
        }
    }

    /// Sets withdraw vesting route for account.
    public struct SetWithdrawVestingRoute: OperationType, Equatable {
        public var fromAccount: String
        public var toAccount: String
        public var percent: UInt16
        public var autoVest: Bool

        public init(
            fromAccount: String,
            toAccount: String,
            percent: UInt16,
            autoVest: Bool
        ) {
            self.fromAccount = fromAccount
            self.toAccount = toAccount
            self.percent = percent
            self.autoVest = autoVest
        }
    }

    /// Creates a limit order using a exchange price.
    public struct LimitOrderCreate2: OperationType, Equatable {
        public var owner: String
        public var orderid: UInt32
        public var amountToSell: Asset
        public var fillOrKill: Bool
        public var exchangeRate: Price
        public var expiration: Date

        public init(
            owner: String,
            orderid: UInt32,
            amountToSell: Asset,
            fillOrKill: Bool,
            exchangeRate: Price,
            expiration: Date
        ) {
            self.owner = owner
            self.orderid = orderid
            self.amountToSell = amountToSell
            self.fillOrKill = fillOrKill
            self.exchangeRate = exchangeRate
            self.expiration = expiration
        }
    }

    public struct ChallengeAuthority: OperationType, Equatable {
        public var challenger: String
        public var challenged: String
        public var requireOwner: Bool

        public init(
            challenger: String,
            challenged: String,
            requireOwner: Bool
        ) {
            self.challenger = challenger
            self.challenged = challenged
            self.requireOwner = requireOwner
        }
    }

    public struct ProveAuthority: OperationType, Equatable {
        public var challenged: String
        public var requireOwner: Bool

        public init(
            challenged: String,
            requireOwner: Bool
        ) {
            self.challenged = challenged
            self.requireOwner = requireOwner
        }
    }

    public struct RequestAccountRecovery: OperationType, Equatable {
        public var recoveryAccount: String
        public var accountToRecover: String
        public var newOwnerAuthority: Authority
        public var extensions: [FutureExtensions]

        public init(
            recoveryAccount: String,
            accountToRecover: String,
            newOwnerAuthority: Authority,
            extensions: [FutureExtensions] = []
        ) {
            self.recoveryAccount = recoveryAccount
            self.accountToRecover = accountToRecover
            self.newOwnerAuthority = newOwnerAuthority
            self.extensions = extensions
        }
    }

    public struct RecoverAccount: OperationType, Equatable {
        public var accountToRecover: String
        public var newOwnerAuthority: Authority
        public var recentOwnerAuthority: Authority
        public var extensions: [FutureExtensions]

        public init(
            accountToRecover: String,
            newOwnerAuthority: Authority,
            recentOwnerAuthority: Authority,
            extensions: [FutureExtensions] = []
        ) {
            self.accountToRecover = accountToRecover
            self.newOwnerAuthority = newOwnerAuthority
            self.recentOwnerAuthority = recentOwnerAuthority
            self.extensions = extensions
        }
    }

    public struct ChangeRecoveryAccount: OperationType, Equatable {
        public var accountToRecover: String
        public var newRecoveryAccount: String
        public var extensions: [FutureExtensions]

        public init(
            accountToRecover: String,
            newRecoveryAccount: String,
            extensions: [FutureExtensions] = []
        ) {
            self.accountToRecover = accountToRecover
            self.newRecoveryAccount = newRecoveryAccount
            self.extensions = extensions
        }
    }

    public struct EscrowTransfer: OperationType, Equatable {
        public var from: String
        public var to: String
        public var agent: String
        public var escrowId: UInt32
        public var sbdAmount: Asset
        public var steemAmount: Asset
        public var fee: Asset
        public var ratificationDeadline: Date
        public var escrowExpiration: Date
        public var jsonMeta: JSONString

        public init(
            from: String,
            to: String,
            agent: String,
            escrowId: UInt32,
            sbdAmount: Asset,
            steemAmount: Asset,
            fee: Asset,
            ratificationDeadline: Date,
            escrowExpiration: Date,
            jsonMeta: JSONString = ""
        ) {
            self.from = from
            self.to = to
            self.agent = agent
            self.escrowId = escrowId
            self.sbdAmount = sbdAmount
            self.steemAmount = steemAmount
            self.fee = fee
            self.ratificationDeadline = ratificationDeadline
            self.escrowExpiration = escrowExpiration
            self.jsonMeta = jsonMeta
        }

        /// Metadata.
        var metadata: [String: Any]? {
            set { self.jsonMeta.object = newValue }
            get { return self.jsonMeta.object }
        }
    }

    public struct EscrowDispute: OperationType, Equatable {
        public var from: String
        public var to: String
        public var agent: String
        public var who: String
        public var escrowId: UInt32

        public init(
            from: String,
            to: String,
            agent: String,
            who: String,
            escrowId: UInt32
        ) {
            self.from = from
            self.to = to
            self.agent = agent
            self.who = who
            self.escrowId = escrowId
        }
    }

    public struct EscrowRelease: OperationType, Equatable {
        public var from: String
        public var to: String
        public var agent: String
        public var who: String
        public var receiver: String
        public var escrowId: UInt32
        public var sbdAmount: Asset
        public var steemAmount: Asset

        public init(
            from: String,
            to: String,
            agent: String,
            who: String,
            receiver: String,
            escrowId: UInt32,
            sbdAmount: Asset,
            steemAmount: Asset
        ) {
            self.from = from
            self.to = to
            self.agent = agent
            self.who = who
            self.receiver = receiver
            self.escrowId = escrowId
            self.sbdAmount = sbdAmount
            self.steemAmount = steemAmount
        }
    }

    /// Submits equihash proof of work, legacy.
    public struct Pow2: OperationType, Equatable {}

    public struct EscrowApprove: OperationType, Equatable {
        public var from: String
        public var to: String
        public var agent: String
        public var who: String
        public var escrowId: UInt32
        public var approve: Bool

        public init(
            from: String,
            to: String,
            agent: String,
            who: String,
            escrowId: UInt32,
            approve: Bool
        ) {
            self.from = from
            self.to = to
            self.agent = agent
            self.who = who
            self.escrowId = escrowId
            self.approve = approve
        }
    }

    public struct TransferToSavings: OperationType, Equatable {
        public var from: String
        public var to: String
        public var amount: Asset
        public var memo: String

        public init(
            from: String,
            to: String,
            amount: Asset,
            memo: String
        ) {
            self.from = from
            self.to = to
            self.amount = amount
            self.memo = memo
        }
    }

    public struct TransferFromSavings: OperationType, Equatable {
        public var from: String
        public var requestId: UInt32
        public var to: String
        public var amount: Asset
        public var memo: String

        public init(
            from: String,
            requestId: UInt32,
            to: String,
            amount: Asset,
            memo: String = ""
        ) {
            self.from = from
            self.requestId = requestId
            self.to = to
            self.amount = amount
            self.memo = memo
        }
    }

    public struct CancelTransferFromSavings: OperationType, Equatable {
        public var from: String
        public var requestId: UInt32

        public init(
            from: String,
            requestId: UInt32
        ) {
            self.from = from
            self.requestId = requestId
        }
    }

    public struct CustomBinary: OperationType, Equatable {
        public var requiredOwnerAuths: [String]
        public var requiredActiveAuths: [String]
        public var requiredPostingAuths: [String]
        public var requiredAuths: [Authority]
        public var id: String
        public var data: Data

        public init(
            requiredOwnerAuths: [String],
            requiredActiveAuths: [String],
            requiredPostingAuths: [String],
            requiredAuths: [Authority],
            id: String,
            data: Data
        ) {
            self.requiredOwnerAuths = requiredOwnerAuths
            self.requiredActiveAuths = requiredActiveAuths
            self.requiredPostingAuths = requiredPostingAuths
            self.requiredAuths = requiredAuths
            self.id = id
            self.data = data
        }
    }

    public struct DeclineVotingRights: OperationType, Equatable {
        public var account: String
        public var decline: Bool

        public init(
            account: String,
            decline: Bool
        ) {
            self.account = account
            self.decline = decline
        }
    }

    public struct ResetAccount: OperationType, Equatable {
        public var resetAccount: String
        public var accountToReset: String
        public var newOwnerAuthority: Authority

        public init(
            resetAccount: String,
            accountToReset: String,
            newOwnerAuthority: Authority
        ) {
            self.resetAccount = resetAccount
            self.accountToReset = accountToReset
            self.newOwnerAuthority = newOwnerAuthority
        }
    }

    public struct SetResetAccount: OperationType, Equatable {
        public var account: String
        public var currentResetAccount: String
        public var resetAccount: String

        public init(
            account: String,
            currentResetAccount: String,
            resetAccount: String
        ) {
            self.account = account
            self.currentResetAccount = currentResetAccount
            self.resetAccount = resetAccount
        }
    }

    public struct ClaimRewardBalance: OperationType, Equatable {
        public var account: String
        public var rewardSteem: Asset
        public var rewardSbd: Asset
        public var rewardVests: Asset

        public init(
            account: String,
            rewardSteem: Asset,
            rewardSbd: Asset,
            rewardVests: Asset
        ) {
            self.account = account
            self.rewardSteem = rewardSteem
            self.rewardSbd = rewardSbd
            self.rewardVests = rewardVests
        }
    }

    public struct DelegateVestingShares: OperationType, Equatable {
        public var delegator: String
        public var delegatee: String
        public var vestingShares: Asset

        public init(
            delegator: String,
            delegatee: String,
            vestingShares: Asset
        ) {
            self.delegator = delegator
            self.delegatee = delegatee
            self.vestingShares = vestingShares
        }
    }

    public struct AccountCreateWithDelegation: OperationType, Equatable {
        public var fee: Asset
        public var delegation: Asset
        public var creator: String
        public var newAccountName: String
        public var owner: Authority
        public var active: Authority
        public var posting: Authority
        public var memoKey: PublicKey
        public var jsonMetadata: JSONString
        public var extensions: [FutureExtensions]

        public init(
            fee: Asset,
            delegation: Asset,
            creator: String,
            newAccountName: String,
            owner: Authority,
            active: Authority,
            posting: Authority,
            memoKey: PublicKey,
            jsonMetadata: JSONString = "",
            extensions: [FutureExtensions] = []
        ) {
            self.fee = fee
            self.delegation = delegation
            self.creator = creator
            self.newAccountName = newAccountName
            self.owner = owner
            self.active = active
            self.posting = posting
            self.memoKey = memoKey
            self.jsonMetadata = jsonMetadata
            self.extensions = extensions
        }

        /// Account metadata.
        var metadata: [String: Any]? {
            set { self.jsonMetadata.object = newValue }
            get { return self.jsonMetadata.object }
        }
    }

    // Virtual operations.

    public struct AuthorReward: OperationType, Equatable {
        public var isVirtual: Bool { return true }
        public let author: String
        public let permlink: String
        public let sbdPayout: Asset
        public let steemPayout: Asset
        public let vestingPayout: Asset
    }

    public struct CurationReward: OperationType, Equatable {
        public var isVirtual: Bool { return true }
        public let curator: String
        public let reward: Asset
        public let commentAuthor: String
        public let commentPermlink: String
    }

    public struct CommentReward: OperationType, Equatable {
        public var isVirtual: Bool { return true }
        public let author: String
        public let permlink: String
        public let payout: Asset
    }

    public struct LiquidityReward: OperationType, Equatable {
        public var isVirtual: Bool { return true }
        public let owner: String
        public let payout: Asset
    }

    public struct Interest: OperationType, Equatable {
        public var isVirtual: Bool { return true }
        public let owner: String
        public let interest: Asset
    }

    public struct FillConvertRequest: OperationType, Equatable {
        public var isVirtual: Bool { return true }
        public let owner: String
        public let requestid: UInt32
        public let amountIn: Asset
        public let amountOut: Asset
    }

    public struct FillVestingWithdraw: OperationType, Equatable {
        public var isVirtual: Bool { return true }
        public let fromAccount: String
        public let toAccount: String
        public let withdrawn: Asset
        public let deposited: Asset
    }

    public struct ShutdownWitness: OperationType, Equatable {
        public var isVirtual: Bool { return true }
        public let owner: String
    }

    public struct FillOrder: OperationType, Equatable {
        public var isVirtual: Bool { return true }
        public let currentOwner: String
        public let currentOrderid: UInt32
        public let currentPays: Asset
        public let openOwner: String
        public let openOrderid: UInt32
        public let openPays: Asset
    }

    public struct FillTransferFromSavings: OperationType, Equatable {
        public var isVirtual: Bool { return true }
        public let from: String
        public let to: String
        public let amount: Asset
        public let requestId: UInt32
        public let memo: String
    }

    public struct Hardfork: OperationType, Equatable {
        public var isVirtual: Bool { return true }
        public let hardforkId: UInt32
    }

    public struct CommentPayoutUpdate: OperationType, Equatable {
        public var isVirtual: Bool { return true }
        public let author: String
        public let permlink: String
    }

    public struct ReturnVestingDelegation: OperationType, Equatable {
        public var isVirtual: Bool { return true }
        public let account: String
        public let vestingShares: Asset
    }

    public struct CommentBenefactorReward: OperationType, Equatable {
        public var isVirtual: Bool { return true }
        public let benefactor: String
        public let author: String
        public let permlink: String
        public let reward: Asset
    }

    public struct ProducerReward: OperationType, Equatable {
        public var isVirtual: Bool { return true }
        public let producer: String
        public let vestingShares: Asset
    }

    /// Unknown operation, seen if the decoder encounters operation which has no type defined.
    /// - Note: Not encodable, the encoder will throw if encountering this operation.
    public struct Unknown: OperationType, Equatable {}
}

// MARK: - Encoding

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
    // Virtual operations
    case fill_convert_request
    case author_reward
    case curation_reward
    case comment_reward
    case liquidity_reward
    case interest
    case fill_vesting_withdraw
    case fill_order
    case shutdown_witness
    case fill_transfer_from_savings
    case hardfork
    case comment_payout_update
    case return_vesting_delegation
    case comment_benefactor_reward
    case producer_reward
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
        case "fill_convert_request": self = .fill_convert_request
        case "author_reward": self = .author_reward
        case "curation_reward": self = .curation_reward
        case "comment_reward": self = .comment_reward
        case "liquidity_reward": self = .liquidity_reward
        case "interest": self = .interest
        case "fill_vesting_withdraw": self = .fill_vesting_withdraw
        case "fill_order": self = .fill_order
        case "shutdown_witness": self = .shutdown_witness
        case "fill_transfer_from_savings": self = .fill_transfer_from_savings
        case "hardfork": self = .hardfork
        case "comment_payout_update": self = .comment_payout_update
        case "return_vesting_delegation": self = .return_vesting_delegation
        case "comment_benefactor_reward": self = .comment_benefactor_reward
        case "producer_reward": self = .producer_reward
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
        case .fill_convert_request: op = try container.decode(Operation.FillConvertRequest.self)
        case .author_reward: op = try container.decode(Operation.AuthorReward.self)
        case .curation_reward: op = try container.decode(Operation.CurationReward.self)
        case .comment_reward: op = try container.decode(Operation.CommentReward.self)
        case .liquidity_reward: op = try container.decode(Operation.LiquidityReward.self)
        case .interest: op = try container.decode(Operation.Interest.self)
        case .fill_vesting_withdraw: op = try container.decode(Operation.FillVestingWithdraw.self)
        case .fill_order: op = try container.decode(Operation.FillOrder.self)
        case .shutdown_witness: op = try container.decode(Operation.ShutdownWitness.self)
        case .fill_transfer_from_savings: op = try container.decode(Operation.FillTransferFromSavings.self)
        case .hardfork: op = try container.decode(Operation.Hardfork.self)
        case .comment_payout_update: op = try container.decode(Operation.CommentPayoutUpdate.self)
        case .return_vesting_delegation: op = try container.decode(Operation.ReturnVestingDelegation.self)
        case .comment_benefactor_reward: op = try container.decode(Operation.CommentBenefactorReward.self)
        case .producer_reward: op = try container.decode(Operation.ProducerReward.self)
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
                codingPath: container.codingPath, debugDescription: "Encountered unknown operation type"
            ))
        }
    }
}

fileprivate struct BeneficiaryWrapper: SteemEncodable, Equatable, Decodable {
    var beneficiaries: [Operation.CommentOptions.BeneficiaryRoute]
}

extension Operation.CommentOptions.Extension {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let type = try container.decode(Int.self)
        switch type {
        case 0:
            let wrapper = try BeneficiaryWrapper(from: container.superDecoder())
            self = .commentPayoutBeneficiaries(wrapper.beneficiaries)
        default:
            self = .unknown
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        switch self {
        case let .commentPayoutBeneficiaries(routes):
            try container.encode(0 as Int)
            try container.encode(BeneficiaryWrapper(beneficiaries: routes))
        case .unknown:
            throw EncodingError.invalidValue(self, EncodingError.Context(codingPath: container.codingPath, debugDescription: "Encountered unknown comment extension"))
        }
    }
}
