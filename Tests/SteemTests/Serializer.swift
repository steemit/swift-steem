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

func write<T: Serializable>(_ value: T) -> TestData {
    var data = Data()
    value.toWire(&data)
    return TestData(data)
}

class SerializerTest: XCTestCase {
    func testFixedWidthIntegers() {
        XCTAssertEqual(write(0 as Int8), "00")
        XCTAssertEqual(write(-128 as Int8), "80")
        XCTAssertEqual(write(127 as Int8), "7f")
        XCTAssertEqual(write(-32768 as Int16), "0080")
        XCTAssertEqual(write(255 as Int16), "ff00")
        XCTAssertEqual(write(-4162 as Int16), "beef")
        XCTAssertEqual(write(-272_707_846 as Int32), "facebeef")
        XCTAssertEqual(write(9_007_199_254_740_991 as Int64), "ffffffffffff1f00")
        XCTAssertEqual(write(-9_007_199_254_740_991 as Int64), "010000000000e0ff")
        XCTAssertEqual(write(255 as UInt8), "ff")
        XCTAssertEqual(write(61374 as UInt16), "beef")
        XCTAssertEqual(write(4_022_259_450 as UInt32), "facebeef")
        XCTAssertEqual(write(9_007_199_254_740_991 as UInt64), "ffffffffffff1f00")
    }

    func testStrings() {
        XCTAssertEqual(write(""), "00")
        XCTAssertEqual(write("Hellö fröm Swäden!"), "1548656c6cc3b6206672c3b66d205377c3a464656e21")
        XCTAssertEqual(write("大きなおっぱい"), "15e5a4a7e3818de381aae3818ae381a3e381b1e38184")
    }

    func testArrays() {
        XCTAssertEqual(write(["foo", "bar"]), "0203666f6f03626172")
        XCTAssertEqual(write([100 as UInt16, 200 as UInt16]), "026400c800")
    }

    func testSortedDict() {
        let map1: OrderedDictionary = [(190 as UInt8, 239 as UInt8), (250 as UInt8, 206 as UInt8)]
        XCTAssertEqual(write(map1), "02beefface")
        let map2: OrderedDictionary = [("2k", Date(timeIntervalSince1970: 946_684_800))]
        XCTAssertEqual(write(map2), "0102326b80436d38")
    }
}
