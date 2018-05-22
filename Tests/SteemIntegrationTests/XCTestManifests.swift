import XCTest

extension ClientTest {
    static let __allTests = [
        ("testRequest", testRequest),
    ]
}

#if !os(macOS)
    public func __allTests() -> [XCTestCaseEntry] {
        return [
            testCase(ClientTest.__allTests),
        ]
    }
#endif
