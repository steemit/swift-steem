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
        if let key = PublicKey("XXX7yFRm6aoShU2d75oCjU7boRu4TBSwEhVtH3cnU5ZH2vQ9qXspN") {
            XCTAssertEqual(String(key), "XXX7yFRm6aoShU2d75oCjU7boRu4TBSwEhVtH3cnU5ZH2vQ9qXspN")
            XCTAssertEqual(key.prefix, .custom("XXX"))
            XCTAssertEqual(key.prefix, "XXX")
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

    func testEncodable() {
        guard let key = PublicKey("STM5832HKCJzs6K3rRCsZ1PidTKgjF38ZJb718Y3pCW92HEMsCGPf") else {
            return XCTFail("Unable to decode public key")
        }
        AssertEncodes(key, Data("021ec205b7c084b96814310c8acb4a0048e82b236f1878acc273fd1cfd03dac7e1"))
        AssertEncodes(key, "STM5832HKCJzs6K3rRCsZ1PidTKgjF38ZJb718Y3pCW92HEMsCGPf")
    }

    func testDecodable() {
        AssertDecodes(string: "STM5832HKCJzs6K3rRCsZ1PidTKgjF38ZJb718Y3pCW92HEMsCGPf", PublicKey("STM5832HKCJzs6K3rRCsZ1PidTKgjF38ZJb718Y3pCW92HEMsCGPf"))
        AssertDecodes(string: "TST5832HKCJzs6K3rRCsZ1PidTKgjF38ZJb718Y3pCW92HEMsCGPf", PublicKey("TST5832HKCJzs6K3rRCsZ1PidTKgjF38ZJb718Y3pCW92HEMsCGPf"))
        AssertDecodes(string: "XXX5832HKCJzs6K3rRCsZ1PidTKgjF38ZJb718Y3pCW92HEMsCGPf", PublicKey("XXX5832HKCJzs6K3rRCsZ1PidTKgjF38ZJb718Y3pCW92HEMsCGPf"))
    }
}
