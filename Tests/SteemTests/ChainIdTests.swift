//
//  ChainIdTests.swift
//  SteemTests
//
//  Created by im on 10/12/18.
//

import Foundation
import XCTest
@testable import Steem

class ChainIdTest: XCTestCase {
    func testEncodeCustomChainId() {
        let mockChainId = ChainId(string: "11223344")
        XCTAssertEqual(mockChainId, ChainId.custom(Data(hexEncoded: "11223344")))
    }
    func testTestnetId() {
        let mockChainId = ChainId.testNet.data
        XCTAssertEqual(mockChainId, Data(hexEncoded: "46d82ab7d8db682eb1959aed0ada039a6d49afa1602491f93dde9cac3e8e6c32"))
    }
    func testMainnetId() {
        let mockChainId = ChainId.mainNet.data
        XCTAssertEqual(mockChainId, Data(hexEncoded: "0000000000000000000000000000000000000000000000000000000000000000"))
    }
}
