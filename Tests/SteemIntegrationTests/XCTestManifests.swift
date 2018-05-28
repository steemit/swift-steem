import XCTest

extension ClientTest {
    static let __allTests = [
        ("testBroadcast", testBroadcast),
        ("testGetBlock", testGetBlock),
        ("testGlobalProps", testGlobalProps),
        ("testRequest", testRequest),
    ]
}

extension PerformanceTest {
    static let __allTests = [
        ("testEncode", testEncode),
        ("testSign", testSign),
    ]
}

#if !os(macOS)
    public func __allTests() -> [XCTestCaseEntry] {
        return [
            testCase(ClientTest.__allTests),
            testCase(PerformanceTest.__allTests),
        ]
    }
#endif
