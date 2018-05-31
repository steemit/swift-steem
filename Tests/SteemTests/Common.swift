import Foundation
@testable import Steem
import XCTest

extension Data: LosslessStringConvertible {
    public init(_ hex: String) {
        self.init(hexEncoded: hex)
    }

    public var description: String {
        return self.hexEncodedString()
    }
}

fileprivate struct EncodeWrapper<T: Encodable>: Encodable { let value: T }
fileprivate struct DecodeWrapper<T: Decodable>: Decodable { let value: T }

fileprivate enum TestError: Error {
    case unableToDecodeString
    case unableToDecodeResult
}

func TestDecode<T: Decodable>(_ type: T.Type, json: Data) throws -> T {
    let decoder = Client.JSONDecoder()
    return try decoder.decode(type, from: json)
}

func TestDecode<T: Decodable>(_ type: T.Type, json: String) throws -> T {
    guard let data = json.data(using: .utf8) else {
        throw TestError.unableToDecodeString
    }
    return try TestDecode(type, json: data)
}

func TestDecode<T: Decodable>(_: T.Type, string: String) throws -> T {
    return try TestDecode(DecodeWrapper<T>.self, json: "{\"value\":\"\(string)\"}").value
}

func TestEncode<T: Encodable>(_ value: T) throws -> Any {
    let encoder = Client.JSONEncoder()
    let data = try encoder.encode(value)
    return try JSONSerialization.jsonObject(with: data, options: [])
}

func AssertEncodes<T: SteemEncodable>(_ value: T, _ expected: Data, file: StaticString = #file, line: UInt = #line) {
    do {
        let encoded = try SteemEncoder.encode(value)
        XCTAssertEqual(encoded.hexEncodedString(), expected.hexEncodedString(), file: file, line: line)
    } catch {
        XCTFail("Encoding error: \(error)", file: file, line: line)
    }
}

func AssertEncodes<T: Encodable, E: Equatable>(_ value: T, _ expected: [String: E], file: StaticString = #file, line: UInt = #line) {
    do {
        let encoder = Client.JSONEncoder()
        let data = try encoder.encode(value)
        guard let result = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            throw TestError.unableToDecodeResult
        }
        for (key, value) in expected {
            XCTAssertEqual(result[key] as? E, value, "For key \(key)", file: file, line: line)
        }
    } catch {
        XCTFail("Encoding error: \(error)", file: file, line: line)
    }
}

func AssertEncodes<T: Encodable>(_ value: T, _ expected: String, file: StaticString = #file, line: UInt = #line) {
    AssertEncodes(EncodeWrapper(value: value), ["value": expected], file: file, line: line)
}

func AssertDecodes<T: Decodable & Equatable>(string: String, _ expected: T, file: StaticString = #file, line: UInt = #line) {
    do {
        let result = try TestDecode(T.self, string: string)
        XCTAssertEqual(result, expected, file: file, line: line)
    } catch {
        XCTFail("Decoding error: \(error)", file: file, line: line)
    }
}

func AssertDecodes<T: Decodable & Equatable>(json: String, _ expected: T, file: StaticString = #file, line: UInt = #line) {
    do {
        let result = try TestDecode(T.self, json: json)
        XCTAssertEqual(result, expected, file: file, line: line)
    } catch {
        XCTFail("Decoding error: \(error)", file: file, line: line)
    }
}
