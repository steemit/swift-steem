@testable import Steem
import XCTest

fileprivate let sig = Signature(
    signature: Data("7a6fa349f1f624643119f667f394a435c1d31d6f39d8191389305e519a0c051222df037180dc86e00ca4fe43ab638f1e8a96403b3857780abaad4017e03d1ef0"),
    recoveryId: 1
)

class SeemURLTest: XCTestCase {
    func testEncodeDecode() {
        let url = SteemURL(operation: Operation.Vote(voter: "foo", author: "bar", permlink: "baz"))
        XCTAssertEqual(url?.url?.absoluteString, "steem://sign/op/WyJ2b3RlIix7InZvdGVyIjoiZm9vIiwiYXV0aG9yIjoiYmFyIiwicGVybWxpbmsiOiJiYXoiLCJ3ZWlnaHQiOjEwMDAwfV0.")
        XCTAssertEqual(url, SteemURL(string: "steem://sign/op/WyJ2b3RlIix7InZvdGVyIjoiZm9vIiwiYXV0aG9yIjoiYmFyIiwicGVybWxpbmsiOiJiYXoiLCJ3ZWlnaHQiOjEwMDAwfV0."))
        let options = SteemURL.ResolveOptions(refBlockNum: 0, refBlockPrefix: 1, expiration: Date(timeIntervalSinceReferenceDate: 0), signers: ["foo"], preferredSigner: "foo")
        let result = try? url?.resolve(with: options)
        XCTAssertEqual(result??.signer, "foo")
        XCTAssertEqual(result??.tx, Transaction(refBlockNum: 0, refBlockPrefix: 1, expiration: Date(timeIntervalSinceReferenceDate: 0), operations: [Operation.Vote(voter: "foo", author: "bar", permlink: "baz")], extensions: []))
    }

    func testParams() throws {
        let operations: [OperationType] = [
            Operation.Vote(voter: "foo", author: "bar", permlink: "baz"),
            Operation.Transfer(from: "foo", to: "bar", amount: Asset(10, .steem), memo: "baz"),
        ]
        var params = SteemURL.Params()
        params.signer = "foo"
        params.callback = "https://example.com/sign?sig={{sig}}"
        params.noBroadcast = true
        let url = SteemURL(operations: operations, params: params)
        XCTAssertNotNil(url)
        let options = SteemURL.ResolveOptions(refBlockNum: 0, refBlockPrefix: 1, expiration: Date(timeIntervalSinceReferenceDate: 0), signers: ["foo", "baz"], preferredSigner: "baz")
        let result = try url?.resolve(with: options)
        XCTAssertEqual(result?.signer, "foo")
        XCTAssertEqual(result?.tx, Transaction(refBlockNum: 0, refBlockPrefix: 1, expiration: Date(timeIntervalSinceReferenceDate: 0), operations: operations, extensions: []))
        let ctx = SteemURL.CallbackContext(signature: sig)
        let cbUrl = url?.resolveCallback(with: ctx)
        XCTAssertEqual(cbUrl?.absoluteString, "https://example.com/sign?sig=207a6fa349f1f624643119f667f394a435c1d31d6f39d8191389305e519a0c051222df037180dc86e00ca4fe43ab638f1e8a96403b3857780abaad4017e03d1ef0")
        XCTAssertEqual(url?.description, "steem://sign/ops/W1sidm90ZSIseyJ2b3RlciI6ImZvbyIsImF1dGhvciI6ImJhciIsInBlcm1saW5rIjoiYmF6Iiwid2VpZ2h0IjoxMDAwMH1dLFsidHJhbnNmZXIiLHsiYW1vdW50IjoiMTAuMDAwIFNURUVNIiwibWVtbyI6ImJheiIsInRvIjoiYmFyIiwiZnJvbSI6ImZvbyJ9XV0.?cb=aHR0cHM6Ly9leGFtcGxlLmNvbS9zaWduP3NpZz17e3NpZ319&nb&s=foo")
        let reparsed = SteemURL(string: "steem://sign/ops/W1sidm90ZSIseyJ2b3RlciI6ImZvbyIsImF1dGhvciI6ImJhciIsInBlcm1saW5rIjoiYmF6Iiwid2VpZ2h0IjoxMDAwMH1dLFsidHJhbnNmZXIiLHsiYW1vdW50IjoiMTAuMDAwIFNURUVNIiwibWVtbyI6ImJheiIsInRvIjoiYmFyIiwiZnJvbSI6ImZvbyJ9XV0.?cb=aHR0cHM6Ly9leGFtcGxlLmNvbS9zaWduP3NpZz17e3NpZ319&nb&s=foo")
        XCTAssertEqual(reparsed, url)
        XCTAssertEqual(reparsed?.params, url?.params)
    }
}
