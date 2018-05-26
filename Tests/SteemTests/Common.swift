import Foundation
@testable import Steem
import XCTest

struct TestData: ExpressibleByStringLiteral, Equatable, CustomStringConvertible {
    let data: Data
    init(_ data: Data) {
        self.data = data
    }

    typealias StringLiteralType = String
    init(stringLiteral value: String) {
        self.data = Data(hexEncoded: value)
    }

    var description: String {
        return self.data.hexEncodedString()
    }
}

func AssertEncodes(_ value: SteemEncodable, _ data: TestData, file: StaticString = #file, line: UInt = #line) {
    XCTAssertEqual(TestData(try! SteemEncoder.encode(value)), data, file: file, line: line)
}
