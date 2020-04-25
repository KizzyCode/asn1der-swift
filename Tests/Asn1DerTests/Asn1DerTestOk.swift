import XCTest
@testable import Asn1Der

final class Asn1DerTestOk: XCTestCase {
	func testLengthOk() throws {
		for test in TestVectors.Ok.tests.length {
			var source = SwiftDataSource(test.bytes)
			let (value, _) = try source.readLength()
			XCTAssertEqual(value, test.value, "@\"\(test.name)\"")
			
			var bytes = Data()
			try bytes.writeLength(length: test.value)
			XCTAssertEqual(bytes, Data(test.bytes), "@\"\(test.name)\"")
		}
	}


	func testObjectOk() throws {
		for test in TestVectors.Ok.tests.object {
			let object = try DERAny(decode: test.bytes)
			XCTAssertEqual(object.value, Data(test.value), "@\"\(test.name)\"")
			
			let bytes = object.encode()
			XCTAssertEqual(bytes, Data(test.bytes))
		}
	}


	func testBooleanOk() throws {
		for test in TestVectors.Ok.tests.typed.bool {
			let object = try DERBoolean(decode: test.bytes)
			XCTAssertEqual(object.value, test.bool, "@\"\(test.name)\"")
			
			let native = try Bool(decode: test.bytes)
			XCTAssertEqual(native, test.bool, "@\"\(test.name)\"")
			
			XCTAssertEqual(object.encode(), Data(test.bytes))
			XCTAssertEqual(native.encode(), Data(test.bytes))
		}
	}
	
	
	func testIntegerOk() throws {
		func testNative<T: DERObject & UnsignedInteger>(_ type: T.Type, _ test: TestVectors.Ok.TypedInteger) throws {
			if let uint = test.uint.map({ T(exactly: $0) }) as? T {
				let native = try T(decode: test.bytes)
				XCTAssertEqual(native, uint, "@\"\(test.name)\"")
				
				XCTAssertEqual(native.encode(), Data(test.bytes), "@\"\(test.name)\"")
			}
		}
	
		for test in TestVectors.Ok.tests.typed.integer {
			let object = try DERInteger(decode: test.bytes)
			XCTAssertEqual(object.raw, Data(test.value), "@\"\(test.name)\"")
			
			XCTAssertEqual(object.encode(), Data(test.bytes))
			
			try testNative(UInt.self, test)
			try testNative(UInt8.self, test)
			try testNative(UInt16.self, test)
			try testNative(UInt32.self, test)
			try testNative(UInt64.self, test)
		}
	}
	
	
	func testNullOk() throws {
		for test in TestVectors.Ok.tests.typed.null {
			let object = try DERNull(decode: test.bytes)
			
			let native = try Bool?(decode: test.bytes)
			XCTAssertNil(native, "@\"\(test.name)\"")
			
			XCTAssertEqual(object.encode(), Data(test.bytes))
			XCTAssertEqual(native.encode(), Data(test.bytes))
		}
	}
	
	
	func testOctetStringOk() throws {
		for test in TestVectors.Ok.tests.typed.octet_string {
			let object = try DEROctetString(decode: test.bytes)
			XCTAssertEqual(object.value, Data(test.value), "@\"\(test.name)\"")
			
			let native = try Data(decode: test.bytes)
			XCTAssertEqual(native, Data(test.value), "@\"\(test.name)\"")
			
			XCTAssertEqual(object.encode(), Data(test.bytes))
			XCTAssertEqual(native.encode(), Data(test.bytes))
		}
	}
	
	
	func testSequenceOk() throws {
		for test in TestVectors.Ok.tests.typed.sequence {
			let object = try DERSequence(decode: test.bytes)
			XCTAssertEqual(object.value.count, test.sequence.count, "@\"\(test.name)\"")
			for (object, testObject) in zip(object.value as! [DERAny], test.sequence) {
				XCTAssertEqual(object.tag, testObject.tag)
				XCTAssertEqual(object.value, Data(testObject.value))
			}
			
			let native = try [Data](decode: test.bytes)
			XCTAssertEqual(native.count, test.sequence.count, "@\"\(test.name)\"")
			for (native, testObject) in zip(native, test.sequence) {
				XCTAssertEqual(native, Data(testObject.value))
			}
			
			XCTAssertEqual(object.encode(), Data(test.bytes))
			XCTAssertEqual(native.encode(), Data(test.bytes))
		}
	}


	func testUTF8StringOk() throws {
		for test in TestVectors.Ok.tests.typed.utf8_string {
			let object = try DERUTF8String(decode: test.bytes)
			XCTAssertEqual(object.value, test.utf8str, "@\"\(test.name)\"")
			
			let native = try String(decode: test.bytes)
			XCTAssertEqual(native, test.utf8str, "@\"\(test.name)\"")
			
			XCTAssertEqual(object.encode(), Data(test.bytes))
			XCTAssertEqual(native.encode(), Data(test.bytes))
		}
	}
	
	
	func assertExample() {
		// Declare an encoded integer with value `7`
		let encoded = Data([0x02, 0x01, 0x07])

		// Decode a generic DER object
		let object = try! DERAny(decode: encoded)

		// Reencode the object
		let encodedObject = object.encode()
		precondition(encoded == encodedObject)


		// Decode an UInt32
		let uint = try! UInt32(decode: encoded)
		precondition(uint == 7)

		// Reencode the integer
		let encodedInteger = uint.encode()
		precondition(encoded == encodedInteger)
	}


	static var allTests = [
		("testLengthOk", testLengthOk),
		("testObjectOk", testObjectOk),
		("testBooleanOk", testBooleanOk),
		("testIntegerOk", testIntegerOk),
		("testNullOk", testNullOk),
		("testOctetStringOk", testOctetStringOk),
		("testSequenceOk", testSequenceOk),
		("testUTF8StringOk", testUTF8StringOk)
	]
}
