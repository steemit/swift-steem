import XCTest

extension ClientTest {
    static let __allTests = [
        ("testBadRpcResponse", testBadRpcResponse),
        ("testBadServerResponse", testBadServerResponse),
        ("testRequest", testRequest),
        ("testRequestWithParams", testRequestWithParams),
        ("testRpcError", testRpcError),
        ("testSeqIdGenerator", testSeqIdGenerator),
    ]
}

extension Secp256k1Test {
    static let __allTests = [
        ("testPublicFromPrivate", testPublicFromPrivate),
        ("testSignAndRecover", testSignAndRecover),
        ("testVerifiesSecret", testVerifiesSecret),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(ClientTest.__allTests),
        testCase(Secp256k1Test.__allTests),
    ]
}
#endif
