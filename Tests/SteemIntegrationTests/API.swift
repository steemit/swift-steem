@testable import Steem
import XCTest

struct HelloRequest: Request {
    typealias Response = String
    let method = "conveyor.hello"
    let params: RequestParams<String>? = RequestParams(["name": "foo"])
}

let client = Steem.Client(address: URL(string: "https://api.steemit.com")!)

let testnetClient = Steem.Client(address: URL(string: "https://testnet.steem.vc")!)
let testnetId = ChainId.custom(Data(hexEncoded: "79276aea5d4877d9a25892eaa01b0adf019d3e5cb12a97478df3298ccdd01673"))

class ClientTest: XCTestCase {
    func testRequest() {
        let test = expectation(description: "Response")
        client.send(request: HelloRequest()) { res, error in
            XCTAssertNil(error)
            XCTAssertEqual(res, "I'm sorry, foo, I can't do that.")
            test.fulfill()
        }
        waitForExpectations(timeout: 5) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }

    func testGlobalProps() {
        let test = expectation(description: "Response")
        let req = API.GetDynamicGlobalProperties()
        client.send(request: req) { res, error in
            XCTAssertNil(error)
            XCTAssertNotNil(res)
            XCTAssertEqual(res?.currentSupply.symbol.name, "STEEM")
            test.fulfill()
        }
        waitForExpectations(timeout: 5) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }

    func testGetBlock() {
        let test = expectation(description: "Response")
        let req = API.GetBlock(blockNum: 12_345_678)
        client.send(request: req) { block, error in
            XCTAssertNil(error)
            XCTAssertEqual(block?.previous.num, 12_345_677)
            XCTAssertEqual(block?.transactions.count, 7)
            test.fulfill()
        }
        waitForExpectations(timeout: 5) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }

    func testBroadcast() {
        let test = expectation(description: "Response")
        let key = PrivateKey("5JQzF7rejVDDFYqCtm4ypcNHhP8Zru6hY1bpALxjNWKtm2yBqC9")!
        var comment = Operation.Comment(
            title: "Hello from Swift",
            body: "The time is \(Date()) and I'm running tests.",
            author: "swift",
            permlink: "hey-eveyone-im-running-swift-tests-and-the-time-is-\(UInt32(Date().timeIntervalSinceReferenceDate))"
        )
        comment.parentPermlink = "test"
        let vote = Operation.Vote(voter: "swift", author: "swift", permlink: comment.permlink)
        testnetClient.send(request: API.GetDynamicGlobalProperties()) { props, error in
            XCTAssertNil(error)
            guard let props = props else {
                return XCTFail("Unable to get props")
            }
            let expiry = props.time.addingTimeInterval(60)
            let tx = Transaction(
                refBlockNum: UInt16(props.headBlockNumber & 0xFFFF),
                refBlockPrefix: props.headBlockId.prefix,
                expiration: expiry,
                operations: [comment, vote])
            guard let stx = try? tx.sign(usingKey: key, forChain: testnetId) else {
                return XCTFail("Unable to sign tx")
            }
            testnetClient.send(request: API.BroadcastTransaction(transaction: stx)) { res, error in
                XCTAssertNil(error)
                if let res = res {
                    XCTAssertFalse(res.expired)
                    XCTAssert(res.blockNum > props.headBlockId.num)
                } else {
                    XCTFail("No response")
                }
                test.fulfill()
            }
        }
        waitForExpectations(timeout: 10) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }

    func testGetAccount() throws {
        let result = try client.sendSynchronous(request: API.GetAccounts(names: ["almost-digital"]))
        guard let account = result?.first else {
            XCTFail("No account returned")
            return
        }
        XCTAssertEqual(account.id, 180_270)
        XCTAssertEqual(account.name, "almost-digital")
        XCTAssertEqual(account.created, Date(timeIntervalSince1970: 1_496_691_060))
    }
}
