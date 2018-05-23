@testable import Steem
import XCTest

class PrivateKeyTest: XCTestCase {
    func testWif() {
        if let key = PrivateKey("5HsQCyqCw61VPQ9tN4ttasHW3AH6cJ6tJdneAXR8gUJ2MWyxxpA") {
            XCTAssertEqual(String(key), "5HsQCyqCw61VPQ9tN4ttasHW3AH6cJ6tJdneAXR8gUJ2MWyxxpA")
        } else {
            XCTFail("Unable to decode WIF")
        }
    }

    func testEquatable() {
        if let a = PrivateKey("5HsQCyqCw61VPQ9tN4ttasHW3AH6cJ6tJdneAXR8gUJ2MWyxxpA"),
            let b = PrivateKey("5HsQCyqCw61VPQ9tN4ttasHW3AH6cJ6tJdneAXR8gUJ2MWyxxpA"),
            let c = PrivateKey(Data(hexEncoded: "8007123e1f482356c415f684407a3b8723e10b2cbbc0b8fcd6282c49d37c9c1abc")),
            let d = PrivateKey("5KD8rrHmtdaLcLjsFcK57AHd6ko4E3QC31jb2na37A49Y6YJtav") {
            XCTAssert(a == b)
            XCTAssert(a == c)
            XCTAssert(d != a)
            XCTAssert(d != b)
        } else {
            XCTFail("Unable to decode WIFs")
        }
    }

    func testCreatePublic() {
        if let key = PrivateKey("5HsQCyqCw61VPQ9tN4ttasHW3AH6cJ6tJdneAXR8gUJ2MWyxxpA") {
            XCTAssertEqual(key.createPublic(), PublicKey("STM6BohVaUq55WgAD38pYVMZE4oxmoX7hAgxsni5EdNdgaKJ8FQDR"))
            XCTAssertEqual(key.createPublic(prefix: .testNet), PublicKey("TST6BohVaUq55WgAD38pYVMZE4oxmoX7hAgxsni5EdNdgaKJ8FQDR"))
            XCTAssertEqual(key.createPublic(prefix: "FOO"), PublicKey("FOO6BohVaUq55WgAD38pYVMZE4oxmoX7hAgxsni5EdNdgaKJ8FQDR"))
        } else {
            XCTFail("Unable to decode WIF")
        }
    }

    func testSign() {
        if let key = PrivateKey("5HsQCyqCw61VPQ9tN4ttasHW3AH6cJ6tJdneAXR8gUJ2MWyxxpA") {
            XCTAssertNoThrow(try key.sign(message: Data(count: 32)))
        } else {
            XCTFail("Unable to decode WIF")
        }
    }
}
