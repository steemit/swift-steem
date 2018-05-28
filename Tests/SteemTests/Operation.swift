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

class OperationTest: XCTestCase {
    func testEncodable() {
        AssertEncodes(vote.0, Data("03666f6f036261720362617ae803"))
        AssertEncodes(vote.0, ["voter": "foo", "author": "bar", "permlink": "baz"])
        AssertEncodes(vote.0, ["weight": 1000])
        AssertEncodes(transfer.0, Data("03666f6f03626172102700000000000003535445454d00000362617a"))
        AssertEncodes(transfer.0, ["from": "foo", "to": "bar", "amount": "10.000 STEEM", "memo": "baz"])
    }

    func testDecodable() {
        AssertDecodes(json: vote.1, vote.0)
        AssertDecodes(json: transfer.1, transfer.0)
    }
}
