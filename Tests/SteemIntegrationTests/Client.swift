import Steem
import XCTest

struct HelloRequest: Request {
    typealias Response = String
    let method = "conveyor.hello"
    let params: RequestParams<String>? = RequestParams(["name": "foo"])
}

let client = Steem.Client(address: URL(string: "https://api.steemit.com")!)
let testnetClient = Steem.Client(address: URL(string: "https://testnet.steem.vc")!)

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
            XCTAssertEqual(res!.currentSupply.symbol.name, "STEEM")
            test.fulfill()
        }
        waitForExpectations(timeout: 5) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
}
