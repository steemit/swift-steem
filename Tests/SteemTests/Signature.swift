@testable import Steem
import XCTest

let sig1 = "207a6fa349f1f624643119f667f394a435c1d31d6f39d8191389305e519a0c051222df037180dc86e00ca4fe43ab638f1e8a96403b3857780abaad4017e03d1ef0"

class SignatureTest: XCTestCase {
    func testEncodeDecode() {
        if let sig = Signature(sig1) {
            XCTAssertEqual(String(sig), sig1)
        } else {
            XCTFail("Unable to decode signature")
        }
        XCTAssertEqual(String(Signature(signature:
            Data(hexEncoded: "7a6fa349f1f624643119f667f394a435c1d31d6f39d8191389305e519a0c051222df037180dc86e00ca4fe43ab638f1e8a96403b3857780abaad4017e03d1ef0"), recoveryId: 1)), sig1)
    }

    func testRecover() {
        if let sig = Signature(sig1) {
            let key = sig.recover(message: Data(count: 32))
            XCTAssertEqual(key, PublicKey("STM6BohVaUq55WgAD38pYVMZE4oxmoX7hAgxsni5EdNdgaKJ8FQDR"))
        } else {
            XCTFail("Unable to decode signature")
        }
    }
}
