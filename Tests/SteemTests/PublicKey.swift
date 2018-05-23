@testable import Steem
import XCTest

class PublicKeyTest: XCTestCase {
    func testKey() {
        if let key = PublicKey("STM6672Ei8X4yMfDmEhBD66xfpG177qrbuic8KpUe1GVV9GVGovcv") {
            XCTAssertEqual(String(key), "STM6672Ei8X4yMfDmEhBD66xfpG177qrbuic8KpUe1GVV9GVGovcv")
            XCTAssertEqual(key.prefix, .mainNet)
            XCTAssertEqual(key.prefix, "STM")
        } else {
            XCTFail("Unable to decode key")
        }
    }

    func testTestnetKey() {
        if let key = PublicKey("TST4zDbsttSXXAezyNFz8GhN6zKka1Zh4GwA9sBgdjLjoW9BdnYTD") {
            XCTAssertEqual(String(key), "TST4zDbsttSXXAezyNFz8GhN6zKka1Zh4GwA9sBgdjLjoW9BdnYTD")
            XCTAssertEqual(key.prefix, .testNet)
            XCTAssertEqual(key.prefix, "TST")
        } else {
            XCTFail("Unable to decode key")
        }
    }

    func testCustomKey() {
        if let key = PublicKey("HORSE7yFRm6aoShU2d75oCjU7boRu4TBSwEhVtH3cnU5ZH2vQ9qXspN") {
            XCTAssertEqual(String(key), "HORSE7yFRm6aoShU2d75oCjU7boRu4TBSwEhVtH3cnU5ZH2vQ9qXspN")
            XCTAssertEqual(key.prefix, .custom("HORSE"))
            XCTAssertEqual(key.prefix, "HORSE")
        } else {
            XCTFail("Unable to decode key")
        }
    }

    func testInvalidKeys() {
        // no prefix
        XCTAssertNil(PublicKey("7yFRm6aoShU2d75oCjU7boRu4TBSwEhVtH3cnU5ZH2vQ9qXspN"))
        // bad checksum
        XCTAssertNil(PublicKey("STM7yFRm6aoShU2d75oCjU7boRu4TBSwEhVtH3cnU5ZH2vQ9qXspX"))
        // bad length
        XCTAssertNil(PublicKey("STM7yFRm6aoShU2d75oCjU7boRu4TBSwEhV"))
    }
}
