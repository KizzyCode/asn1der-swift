import XCTest
@testable import Asn1Der


final class Asn1DerTestErr: XCTestCase {
    func testLengthErr() {
        for test in TestVectors.Err.tests.length {
            var source = Data(test.bytes)
            XCTAssertThrowsError(try Int(derLength: &source), "@\"\(test.name)\"", {
                XCTAssertEqual($0.kind, test.err, "@\"\(test.name)\"")
            })
        }
    }
    
    func testObjectErr() {
        for test in TestVectors.Err.tests.object {
            XCTAssertThrowsError(try DERAny(decode: test.bytes), "@\"\(test.name)\"", {
                XCTAssertEqual($0.kind, test.platformErr, "@\"\(test.name)\"")
            })
        }
    }
    
    func testBooleanErr() {
        for test in TestVectors.Err.tests.typed.bool {
            XCTAssertThrowsError(try DERBoolean(decode: test.bytes), "@\"\(test.name)\"", {
                XCTAssertEqual($0.kind, test.err, "@\"\(test.name)\"")
            })
            
            XCTAssertThrowsError(try Bool(decode: test.bytes), "@\"\(test.name)\"", {
                XCTAssertEqual($0.kind, test.err, "@\"\(test.name)\"")
            })
        }
    }
    
    func testIntegerErr() {
        func testNative<T: DERObject & FixedWidthInteger>(_ type: T.Type, _ test: TestVectors.Err.TypedAny) {
            XCTAssertThrowsError(try T(decode: test.bytes), "@\"\(test.name)\"", {
                XCTAssertEqual($0.kind, test.err, "@\"\(test.name)\"")
            })
        }
    
        for test in TestVectors.Err.tests.typed.integer {
            XCTAssertThrowsError(try DERInteger(decode: test.bytes), "@\"\(test.name)\"", {
                XCTAssertEqual($0.kind, test.err, "@\"\(test.name)\"")
            })
            
            testNative(UInt.self, test)
            testNative(UInt8.self, test)
            testNative(UInt16.self, test)
            testNative(UInt32.self, test)
            testNative(UInt64.self, test)
        }
    }
    
    func testNullErr() {
        for test in TestVectors.Err.tests.typed.null {
            XCTAssertThrowsError(try DERNull(decode: test.bytes), "@\"\(test.name)\"", {
                XCTAssertEqual($0.kind, test.err, "@\"\(test.name)\"")
            })
            
            XCTAssertThrowsError(try Bool?(decode: test.bytes), "@\"\(test.name)\"", {
                XCTAssertEqual($0.kind, test.err, "@\"\(test.name)\"")
            })
        }
    }
    
    func testOctetStringErr() {
        for test in TestVectors.Err.tests.typed.octet_string {
            XCTAssertThrowsError(try DEROctetString(decode: test.bytes), "@\"\(test.name)\"", {
                XCTAssertEqual($0.kind, test.err, "@\"\(test.name)\"")
            })
            
            XCTAssertThrowsError(try Data(decode: test.bytes), "@\"\(test.name)\"", {
                XCTAssertEqual($0.kind, test.err, "@\"\(test.name)\"")
            })
        }
    }
    
    func testSequenceErr() {
        for test in TestVectors.Err.tests.typed.sequence {
            XCTAssertThrowsError(try DERSequence(decode: test.bytes), "@\"\(test.name)\"", {
                XCTAssertEqual($0.kind, test.err, "@\"\(test.name)\"")
            })
            
            XCTAssertThrowsError(try [Data](decode: test.bytes), "@\"\(test.name)\"", {
                XCTAssertEqual($0.kind, test.err, "@\"\(test.name)\"")
            })
        }
    }

    func testUTF8StringErr() {
        for test in TestVectors.Err.tests.typed.utf8_string {
            XCTAssertThrowsError(try DERUTF8String(decode: test.bytes), "@\"\(test.name)\"", {
                XCTAssertEqual($0.kind, test.err, "@\"\(test.name)\"")
            })
            
            XCTAssertThrowsError(try String(decode: test.bytes), "@\"\(test.name)\"", {
                XCTAssertEqual($0.kind, test.err, "@\"\(test.name)\"")
            })
        }
    }

    static var allTests = [
        ("testLengthErr", testLengthErr),
        ("testObjectErr", testObjectErr),
        ("testBooleanErr", testBooleanErr),
        ("testIntegerErr", testIntegerErr),
        ("testNullErr", testNullErr),
        ("testOctetStringErr", testOctetStringErr),
        ("testSequenceErr", testSequenceErr),
        ("testUTF8StringErr", testUTF8StringErr)
    ]
}
