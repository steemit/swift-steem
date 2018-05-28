@testable import Steem
import XCTest

fileprivate let sig = Signature(
    signature: Data("7a6fa349f1f624643119f667f394a435c1d31d6f39d8191389305e519a0c051222df037180dc86e00ca4fe43ab638f1e8a96403b3857780abaad4017e03d1ef0"),
    recoveryId: 1
)

fileprivate let sigHex = "207a6fa349f1f624643119f667f394a435c1d31d6f39d8191389305e519a0c051222df037180dc86e00ca4fe43ab638f1e8a96403b3857780abaad4017e03d1ef0"

class SignatureTest: XCTestCase {
    func testEncodable() {
        AssertEncodes(sig, sigHex)
    }

    func testEncodeDecode() {
        AssertDecodes(string: sigHex, sig)
    }

    func testRecover() {
        XCTAssertEqual(sig.recover(message: Data(count: 32)), PublicKey("STM6BohVaUq55WgAD38pYVMZE4oxmoX7hAgxsni5EdNdgaKJ8FQDR"))
    }
}
