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

fileprivate func AssertSerializes(_ value: Serializable, _ data: TestData, file: StaticString = #file, line: UInt = #line) {
    XCTAssertEqual(TestData(Serializer.encode(value)), data, file: file, line: line)
}

class SerializerTest: XCTestCase {

    func testFixedWidthInteger() {
        AssertSerializes(0 as Int8, "00")
        AssertSerializes(-128 as Int8, "80")
        AssertSerializes(127 as Int8, "7f")
        AssertSerializes(-32768 as Int16, "0080")
        AssertSerializes(255 as Int16, "ff00")
        AssertSerializes(-4162 as Int16, "beef")
        AssertSerializes(-272_707_846 as Int32, "facebeef")
        AssertSerializes(9_007_199_254_740_991 as Int64, "ffffffffffff1f00")
        AssertSerializes(-9_007_199_254_740_991 as Int64, "010000000000e0ff")
        AssertSerializes(255 as UInt8, "ff")
        AssertSerializes(61374 as UInt16, "beef")
        AssertSerializes(4_022_259_450 as UInt32, "facebeef")
        AssertSerializes(9_007_199_254_740_991 as UInt64, "ffffffffffff1f00")
    }

    func testString() {
        AssertSerializes("", "00")
        AssertSerializes("Hellö fröm Swäden!", "1548656c6cc3b6206672c3b66d205377c3a464656e21")
        AssertSerializes("大きなおっぱい", "15e5a4a7e3818de381aae3818ae381a3e381b1e38184")
    }

    func testArray() {
        AssertSerializes(["foo", "bar"], "0203666f6f03626172")
        AssertSerializes([100 as UInt16, 200 as UInt16], "026400c800")
    }

    func testSortedDict() {
        let map1: OrderedDictionary = [(190 as UInt8, 239 as UInt8), (250 as UInt8, 206 as UInt8)]
        AssertSerializes(map1, "02beefface")
        let map2: OrderedDictionary = [("2k", Date(timeIntervalSince1970: 946_684_800))]
        AssertSerializes(map2, "0102326b80436d38")
    }

    func testPublicKey() {
        if let key = PublicKey("STM5832HKCJzs6K3rRCsZ1PidTKgjF38ZJb718Y3pCW92HEMsCGPf") {
            AssertSerializes(key, "021ec205b7c084b96814310c8acb4a0048e82b236f1878acc273fd1cfd03dac7e1")
        } else {
            XCTFail("Unable to decode public key")
        }

    }

    func testOperation() {
        AssertSerializes(VoteOperation(voter: "foo", author: "foo", permlink: "foo", weight: 1000), "0003666f6f03666f6f03666f6fe803")
    }
    
    func testTransaction() {
        let vote = VoteOperation(voter: "foo", author: "foo", permlink: "foo", weight: 1000)
        let tx = Transaction(refBlockNum: 0, refBlockPrefix: 0, expiration: Date(timeIntervalSince1970: 946684800), operations: [vote])
        AssertSerializes(tx, "00000000000080436d38010003666f6f03666f6f03666f6fe80300")
    }

}
