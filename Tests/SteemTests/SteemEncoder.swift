@testable import Steem
import XCTest

class SteemEncoderTest: XCTestCase {
    func testFixedWidthInteger() {
        AssertEncodes(0 as Int8, Data("00"))
        AssertEncodes(-128 as Int8, Data("80"))
        AssertEncodes(127 as Int8, Data("7f"))
        AssertEncodes(-32768 as Int16, Data("0080"))
        AssertEncodes(255 as Int16, Data("ff00"))
        AssertEncodes(-4162 as Int16, Data("beef"))
        AssertEncodes(-272_707_846 as Int32, Data("facebeef"))
        AssertEncodes(9_007_199_254_740_991 as Int64, Data("ffffffffffff1f00"))
        AssertEncodes(-9_007_199_254_740_991 as Int64, Data("010000000000e0ff"))
        AssertEncodes(255 as UInt8, Data("ff"))
        AssertEncodes(61374 as UInt16, Data("beef"))
        AssertEncodes(4_022_259_450 as UInt32, Data("facebeef"))
        AssertEncodes(9_007_199_254_740_991 as UInt64, Data("ffffffffffff1f00"))
    }

    func testString() {
        AssertEncodes("", Data("00"))
        AssertEncodes("Hellö fröm Swäden!", Data("1548656c6cc3b6206672c3b66d205377c3a464656e21"))
        AssertEncodes("大きなおっぱい", Data("15e5a4a7e3818de381aae3818ae381a3e381b1e38184"))
    }

    func testArray() {
        AssertEncodes(["foo", "bar"], Data("0203666f6f03626172"))
        AssertEncodes([100 as UInt16, 200 as UInt16], Data("026400c800"))
    }

    func testSortedDict() {
        let map1: OrderedDictionary = [(190 as UInt8, 239 as UInt8), (250 as UInt8, 206 as UInt8)]
        AssertEncodes(map1, Data("02beefface"))
        let map2: OrderedDictionary = [("2k", Date(timeIntervalSince1970: 946_684_800))]
        AssertEncodes(map2, Data("0102326b80436d38"))
    }
}
