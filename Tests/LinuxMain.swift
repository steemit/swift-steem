import XCTest

import SteemTests
import SteemIntegrationTests

var tests = [XCTestCaseEntry]()
tests += SteemTests.__allTests()
tests += SteemIntegrationTests.__allTests()

XCTMain(tests)
