import XCTest

extension AssetTest {
    static let __allTests = [
        ("testDecodable", testDecodable),
        ("testEncodable", testEncodable),
    ]
}

extension Base58Test {
    static let __allTests = [
        ("testDecode", testDecode),
        ("testEncode", testEncode),
    ]
}

extension BlockTest {
    static let __allTests = [
        ("testCodable", testCodable),
    ]
}

extension ClientTest {
    static let __allTests = [
        ("testBadRpcResponse", testBadRpcResponse),
        ("testBadServerResponse", testBadServerResponse),
        ("testRequest", testRequest),
        ("testRequestWithParams", testRequestWithParams),
        ("testRpcError", testRpcError),
        ("testSeqIdGenerator", testSeqIdGenerator),
    ]
}

extension OperationTest {
    static let __allTests = [
        ("testDecodable", testDecodable),
        ("testEncodable", testEncodable),
    ]
}

extension PrivateKeyTest {
    static let __allTests = [
        ("testCreatePublic", testCreatePublic),
        ("testDecodeWif", testDecodeWif),
        ("testEquatable", testEquatable),
        ("testHandlesInvalid", testHandlesInvalid),
        ("testSign", testSign),
    ]
}

extension PublicKeyTest {
    static let __allTests = [
        ("testCustomKey", testCustomKey),
        ("testDecodable", testDecodable),
        ("testEncodable", testEncodable),
        ("testInvalidKeys", testInvalidKeys),
        ("testKey", testKey),
        ("testNullKey", testNullKey),
        ("testTestnetKey", testTestnetKey),
    ]
}

extension Secp256k1Test {
    static let __allTests = [
        ("testPublicFromPrivate", testPublicFromPrivate),
        ("testSignAndRecover", testSignAndRecover),
        ("testVerifiesSecret", testVerifiesSecret),
    ]
}

extension SeemURLTest {
    static let __allTests = [
        ("testEncodeDecode", testEncodeDecode),
        ("testParams", testParams),
    ]
}

extension Sha2Test {
    static let __allTests = [
        ("testDigest", testDigest),
    ]
}

extension SignatureTest {
    static let __allTests = [
        ("testEncodable", testEncodable),
        ("testEncodeDecode", testEncodeDecode),
        ("testRecover", testRecover),
    ]
}

extension SteemEncoderTest {
    static let __allTests = [
        ("testArray", testArray),
        ("testFixedWidthInteger", testFixedWidthInteger),
        ("testSortedDict", testSortedDict),
        ("testString", testString),
    ]
}

extension TransactionTest {
    static let __allTests = [
        ("testDecodable", testDecodable),
        ("testSigning", testSigning),
    ]
}

#if !os(macOS)
    public func __allTests() -> [XCTestCaseEntry] {
        return [
            testCase(AssetTest.__allTests),
            testCase(Base58Test.__allTests),
            testCase(BlockTest.__allTests),
            testCase(ClientTest.__allTests),
            testCase(OperationTest.__allTests),
            testCase(PrivateKeyTest.__allTests),
            testCase(PublicKeyTest.__allTests),
            testCase(Secp256k1Test.__allTests),
            testCase(SeemURLTest.__allTests),
            testCase(Sha2Test.__allTests),
            testCase(SignatureTest.__allTests),
            testCase(SteemEncoderTest.__allTests),
            testCase(TransactionTest.__allTests),
        ]
    }
#endif
