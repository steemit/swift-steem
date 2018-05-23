@testable import Steem
import XCTest

class Sha2Test: XCTestCase {
    func testDigest() {
        let data = Data(base64Encoded: "A4fYIELZNEcAjf4q92IGih5T/zlKW/j2igRfpkK5nqXR")!
        XCTAssertEqual(data.sha256Digest(), Data(base64Encoded: "nxseRPD/eP7rVE0ceWhzRvPNyfbiNlPKKuS6f+6cHUY="))
    }
}
