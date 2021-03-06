
import Foundation
@testable import Steem
import XCTest

class AssetTest: XCTestCase {
    func testEncodable() {
        AssertEncodes(Asset(10, .steem), Data("102700000000000003535445454d0000"))
        AssertEncodes(Asset(123_456.789, .vests), Data("081a99be1c0000000656455354530000"))
        AssertEncodes(Asset(10, .steem), "10.000 STEEM")
        AssertEncodes(Asset(123_456.789, .vests), "123456.789000 VESTS")
        AssertEncodes(Asset(42, .custom(name: "TOWELS", precision: 0)), "42 TOWELS")
        AssertEncodes(Asset(0.001, .sbd), "0.001 SBD")
    }

    func testDecodable() throws {
        AssertDecodes(string: "10.000 STEEM", Asset(10, .steem))
        AssertDecodes(string: "0.001 SBD", Asset(0.001, .sbd))
        AssertDecodes(string: "1.20 DUCKS", Asset(1.2, .custom(name: "DUCKS", precision: 2)))
        AssertDecodes(string: "0 BOO", Asset(0, .custom(name: "BOO", precision: 0)))
        AssertDecodes(string: "123456789.999999 VESTS", Asset(123_456_789.999999, .vests))
    }
}
