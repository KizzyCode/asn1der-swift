import XCTest
@testable import Asn1Der

final class Asn1DerCoderTest: XCTestCase {
    func testOk() throws {
        for test in TestVectors.Coder.ok {
            let object = try DERDecoder().decode(TestVectors.Coder.Outer.self, data: test.bytes)
            XCTAssertEqual(object, test.value, "@\"\(test.name)\"")
            
            let bytes = try DEREncoder().encode(object)
            XCTAssertEqual(bytes, test.bytes, "@\"\(test.name)\"")
        }
    }
    
    static var allTests = [
        ("testOk", testOk)
    ]
}
