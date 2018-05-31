@testable import Steem
import XCTest

fileprivate let vote = (
    Operation.Vote(voter: "foo", author: "bar", permlink: "baz", weight: 1000),
    "{\"voter\":\"foo\",\"author\":\"bar\",\"permlink\":\"baz\",\"weight\":1000}"
)

fileprivate let transfer = (
    Operation.Transfer(from: "foo", to: "bar", amount: Asset(10, symbol: .steem), memo: "baz"),
    "{\"from\":\"foo\",\"to\":\"bar\",\"amount\":\"10.000 STEEM\",\"memo\":\"baz\"}"
)

fileprivate let commentOptions = (
    Operation.CommentOptions(author: "foo", permlink: "bar", maxAcceptedPayout: Asset(10, symbol: .sbd), percentSteemDollars: 41840, allowVotes: true, allowCurationRewards: true, extensions: [.commentPayoutBeneficiaries([Operation.CommentOptions.BeneficiaryRoute(account: "baz", weight: 5000)])]),
    "{\"author\":\"foo\",\"permlink\":\"bar\",\"max_accepted_payout\":\"10.000 SBD\",\"percent_steem_dollars\":41840,\"allow_votes\":true,\"allow_curation_rewards\":true,\"extensions\":[[0,{\"beneficiaries\":[{\"account\":\"baz\",\"weight\":5000}]}]]}"
)

class OperationTest: XCTestCase {
    func testEncodable() throws {
        AssertEncodes(vote.0, Data("03666f6f036261720362617ae803"))
        AssertEncodes(vote.0, ["voter": "foo", "author": "bar", "permlink": "baz"])
        AssertEncodes(vote.0, ["weight": 1000])
        AssertEncodes(transfer.0, Data("03666f6f03626172102700000000000003535445454d00000362617a"))
        AssertEncodes(transfer.0, ["from": "foo", "to": "bar", "amount": "10.000 STEEM", "memo": "baz"])
        AssertEncodes(commentOptions.0, Data("03666f6f036261721027000000000000035342440000000070a301010100010362617a8813"))
    }

    func testDecodable() {
        AssertDecodes(json: vote.1, vote.0)
        AssertDecodes(json: transfer.1, transfer.0)
        AssertDecodes(json: commentOptions.1, commentOptions.0)
    }
}
