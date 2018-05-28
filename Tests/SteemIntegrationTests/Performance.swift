import Foundation
import Steem
import XCTest

class PerformanceTest: XCTestCase {
    func testSign() {
        let key = PrivateKey("5JEB2fkmEqHSfGqL96eTtQ2emYodeTBBnXvETwe2vUSMe4pxdLj")!
        let message = Data(count: 32)
        self.measure {
            for _ in 0 ... 100 {
                _ = try! key.sign(message: message)
            }
        }
    }

    func testEncode() {
        let vote = Operation.Vote(voter: "foo", author: "bar", permlink: "baz")
        let comment = Operation.Comment(title: "foo", body: "bar", author: "baz", permlink: "qux")
        let txn = Transaction(refBlockNum: 0, refBlockPrefix: 0, expiration: Date(), operations: [vote, comment])
        self.measure {
            for _ in 0 ... 1000 {
                _ = try! SteemEncoder.encode(txn)
            }
        }
    }
}
