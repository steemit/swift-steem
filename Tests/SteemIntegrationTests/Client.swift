import Steem
import XCTest

struct TestRequest: Request {
    typealias Response = Any
    
    var params: Any?
    var method = "test"
    
    func response(from result: Any) throws -> Response {
        return result
    }
}

let client = Steem.Client(address: URL(string: "https://api.steemit.com")!)

class ClientTest: XCTestCase {
    
    func testRequest() {
        let test = expectation(description: "Response")
        let req = TestRequest(params: ["name": "foo"], method: "conveyor.hello")
        client.send(request: req) { (res, error) in
            XCTAssertNil(error)
            XCTAssertEqual(res as? String, "I'm sorry, foo, I can't do that.")
            test.fulfill()
        }
        waitForExpectations(timeout: 5) { (error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
}
