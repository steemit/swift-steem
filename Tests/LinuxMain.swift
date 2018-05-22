import SteemIntegrationTests
import SteemTests
import XCTest

var tests = [XCTestCaseEntry]()
tests += SteemTests.__allTests()
tests += SteemIntegrationTests.__allTests()

XCTMain(tests)
