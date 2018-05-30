@testable import Steem
import XCTest

class TransactionTest: XCTestCase {
    override class func setUp() {
        PrivateKey.determenisticSignatures = true
    }

    override class func tearDown() {
        PrivateKey.determenisticSignatures = false
    }

    func testDecodable() throws {
        let tx = try TestDecode(Transaction.self, json: txJson)
        XCTAssertEqual(tx.refBlockNum, 12345)
        XCTAssertEqual(tx.refBlockPrefix, 1_122_334_455)
        XCTAssertEqual(tx.expiration, Date(timeIntervalSince1970: 0))
        XCTAssertEqual(tx.extensions.count, 0)
        XCTAssertEqual(tx.operations.count, 2)
        let vote = tx.operations.first as? Steem.Operation.Vote
        let transfer = tx.operations.last as? Steem.Operation.Transfer
        XCTAssertEqual(vote, Steem.Operation.Vote(voter: "foo", author: "bar", permlink: "baz", weight: 1000))
        XCTAssertEqual(transfer, Steem.Operation.Transfer(from: "foo", to: "bar", amount: Asset(10, symbol: .steem), memo: "baz"))
    }

    func testSigning() throws {
        guard let key = PrivateKey("5JEB2fkmEqHSfGqL96eTtQ2emYodeTBBnXvETwe2vUSMe4pxdLj") else {
            return XCTFail("Unable to parse private key")
        }
        let operations: [OperationType] = [
            Operation.Vote(voter: "foo", author: "foo", permlink: "baz", weight: 1000),
            Operation.Transfer(from: "foo", to: "bar", amount: Asset(10, symbol: .steem), memo: "baz"),
        ]
        let expiration = Date(timeIntervalSince1970: 0)
        let transaction = Transaction(refBlockNum: 0, refBlockPrefix: 0, expiration: expiration, operations: operations)
        AssertEncodes(transaction, Data("00000000000000000000020003666f6f03666f6f0362617ae8030203666f6f03626172102700000000000003535445454d00000362617a00"))
        XCTAssertEqual(try transaction.digest(forChain: .mainNet), Data("44424a1259aba312780ca6957a91dbd8a8eef8c2c448d89eccee34a425c77512"))
        let customChain = Data("79276aea5d4877d9a25892eaa01b0adf019d3e5cb12a97478df3298ccdd01673")
        XCTAssertEqual(try transaction.digest(forChain: .custom(customChain)), Data("43ca08db53ad0289ccb268654497e0799c02b50ac8535e0c0f753067417be953"))
        var signedTransaction = try transaction.sign(usingKey: key)
        try signedTransaction.appendSignature(usingKey: key, forChain: .custom(customChain))
        XCTAssertEqual(signedTransaction.signatures, [
            Signature("20598c2f2301db5559d42663f8f79cbc4258697cd645b6df56be2e83d786a66590437acf0041bda94c4ff4d8e5bce0ac1765a2c32bd796cb1d002081e4a5f8691a"),
            Signature("1f15c78daabdbc30866897f7d01d61ba385b599f1438fe8b501ee4982eaba969f371474d0c4bd6ed927d74f5e94f59565506bdf4478400d5fe2330f61473d6ae8f"),
        ])
    }
}

fileprivate let txJson = """
{
  "ref_block_num": 12345,
  "ref_block_prefix": 1122334455,
  "expiration": "1970-01-01T00:00:00",
  "extensions": [],
  "operations": [
    ["vote", {"voter": "foo", "author": "bar", "permlink": "baz", "weight": 1000}],
    ["transfer", {"from": "foo", "to": "bar", "amount": "10.000 STEEM", "memo": "baz"}]
  ]
}
"""
