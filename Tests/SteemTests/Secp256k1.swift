@testable import Steem
import XCTest

let secretKey = Data(base64Encoded: "LPJNul+wow4m6DsqxbninhsWHlwfp0JecwQzYpOLmCQ=")!

class Secp256k1Test: XCTestCase {
    func testVerifiesSecret() {
        XCTAssertTrue(Secp256k1Context.shared.verify(secretKey: secretKey))
    }

    func testPublicFromPrivate() {
        let publicKey = try? Secp256k1Context.shared.createPublic(fromSecret: secretKey)
        XCTAssertNotNil(publicKey)
        XCTAssertEqual(publicKey?.base64EncodedString(), "A4fYIELZNEcAjf4q92IGih5T/zlKW/j2igRfpkK5nqXR")
    }

    func testSignAndRecover() {
        let message = Data(base64Encoded: "sEoPAwEAAAAYSg8DAQAAABBLDwMBAAAAaEoPAwEAAAA=")!
        let result = try? Secp256k1Context.shared.sign(message: message, secretKey: secretKey)
        XCTAssertNotNil(result)
        let publicKey = try? Secp256k1Context.shared.recover(message: message, signature: result!.0, recoveryId: result!.1)
        XCTAssertEqual(publicKey?.base64EncodedString(), "A4fYIELZNEcAjf4q92IGih5T/zlKW/j2igRfpkK5nqXR")
    }
}
