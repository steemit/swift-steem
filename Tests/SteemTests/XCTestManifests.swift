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

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(ClientTest.__allTests),
    ]
}
#endif
