import XCTest
@testable import Asn1Der


public struct TestVectors {
	/// The test vectors for valid objects
	public struct Ok {
		public struct Length: Decodable {
			public let name: String
			public let bytes: [UInt8]
			public let value: Int
		}
		
		
		public struct Object: Decodable {
			public let name: String
			public let bytes: [UInt8]
			public let tag: UInt8
			public let value: [UInt8]
		}
		
		
		public struct TypedBool: Decodable {
			public let name: String
			public let bytes: [UInt8]
			public let value: [UInt8]
			public let bool: Bool
		}
		public struct TypedInteger: Decodable {
			public let name: String
			public let bytes: [UInt8]
			public let value: [UInt8]
			public let uint: UInt64?
			public let int: Int64?
		}
		public struct TypedNull: Decodable {
			public let name: String
			public let bytes: [UInt8]
		}
		public struct TypedOctetString: Decodable {
			public let name: String
			public let bytes: [UInt8]
			public let value: [UInt8]
		}
		public struct TypedSequence: Decodable {
			public let name: String
			public let bytes: [UInt8]
			public let value: [UInt8]
			public let sequence: [Object]
		}
		public struct TypedUtf8String: Decodable {
			public let name: String
			public let bytes: [UInt8]
			public let value: [UInt8]
			public let utf8str: String
		}
		public struct Typed: Decodable {
			public let bool: [TypedBool]
			public let integer: [TypedInteger]
			public let null: [TypedNull]
			public let octet_string: [TypedOctetString]
			public let sequence: [TypedSequence]
			public let utf8_string: [TypedUtf8String]
		}
		
		
		/// A test vector for valid constructions
		public struct Tests: Decodable {
			public let length: [Length]
			public let object: [Object]
			public let typed: Typed
		}
		public static var tests: Tests = {
			try! JSONDecoder().decode(Tests.self, from: Self.json.data(using: .utf8)!)
		}()
	}
	
	
	/// The test vectors for invalid objects
	public struct Err {
		public struct Length: Decodable {
			public let name: String
			public let bytes: [UInt8]
			public let err: String
		}
		
		
		public struct Object: Decodable {
			public let name: String
			public let bytes: [UInt8]
			private let err: String
			private let err_32bit: String?
			
			public var platformErr: String {
				#if arch(arm64) || arch(x86_64)
					return self.err
				#else
					switch self.err_32bit {
						case .some(let err): return err
						default: return self.err
					}
				#endif
			}
		}
		
		
		public struct TypedAny: Decodable {
			public let name: String
			public let bytes: [UInt8]
			public let err: String
		}
		public struct Typed: Decodable {
			public let bool: [TypedAny]
			public let integer: [TypedAny]
			public let null: [TypedAny]
			public let octet_string: [TypedAny]
			public let sequence: [TypedAny]
			public let utf8_string: [TypedAny]
		}
		
		
		/// A test vector for invalid constructions
		public struct Tests: Decodable {
			public let length: [Length]
			public let object: [Object]
			public let typed: Typed
		}
		public static var tests: Tests = {
			try! JSONDecoder().decode(Tests.self, from: Self.json.data(using: .utf8)!)
		}()
	}
	
	
	public struct Coder {
		public struct Inner: Codable, Equatable {
			public let number: UInt8
			public let null: Bool?
			
			public static func ==(lhs: TestVectors.Coder.Inner, rhs: TestVectors.Coder.Inner) -> Bool {
				lhs.number == rhs.number
			}
		}
	
		public struct Outer: Codable, Equatable {
			public let num: UInt8
			public let data: Data
			public let inner: Inner
			public let optional: String?
		}
		
		public struct TestOk {
			public let name: String
			public let bytes: Data
			public let value: Outer
		}
		
		
		public struct TestErr {
			public let name: String
			public let bytes: Data
			public let err: String
		}
		
		
		static let ok = [
			TestOk(
				name: "Coder with optional: `nil`",
				bytes: Data([0x30, 0x17, 0x02, 0x01, 0x07, 0x04, 0x09, 0x54, 0x65, 0x73, 0x74, 0x6f, 0x6c, 0x6f, 0x70, 0x65, 0x30, 0x05, 0x02, 0x01, 0x04, 0x05, 0x00, 0x05, 0x00]),
				value: Outer(
					num: 7,
					data: Data([0x54, 0x65, 0x73, 0x74, 0x6F, 0x6C, 0x6F, 0x70, 0x65]),
					inner: Inner(number: 4, null: nil),
					optional: nil)),
			TestOk(
				name: "Coder with optional: `\"Testolope\"`",
				bytes: Data([0x30, 0x20, 0x02, 0x01, 0x07, 0x04, 0x09, 0x54, 0x65, 0x73, 0x74, 0x6f, 0x6c, 0x6f, 0x70, 0x65, 0x30, 0x05, 0x02, 0x01, 0x04, 0x05, 0x00, 0x0c, 0x09, 0x54, 0x65, 0x73, 0x74, 0x6f, 0x6c, 0x6f, 0x70, 0x65]),
				value: Outer(
					num: 7,
					data: Data([0x54, 0x65, 0x73, 0x74, 0x6F, 0x6C, 0x6F, 0x70, 0x65]),
					inner: Inner(number: 4, null: nil),
					optional: "Testolope"))
		]
	}
}


extension Error {
	/// The "kind" of this error
	public var kind: String {
		switch self {
			case let error as DERError:
				switch error {
					case .inOutError: return "InOutError"
					case .invalidData: return "InvalidData"
					case .unsupported: return "Unsupported"
					case .unsupportedType: return "UnsupportedType"
					case .other: return "Other"
				}
			default: return "Unexpected non DER-error: \(self)"
		}
	}
}

