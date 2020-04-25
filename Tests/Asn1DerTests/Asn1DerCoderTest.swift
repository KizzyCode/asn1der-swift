import XCTest
@testable import Asn1Der

final class Asn1DerCoderTest: XCTestCase {
	func testOk() throws {
		for test in TestVectors.Coder.ok {
			let _ = test
			/* TODO: there is no DER-`Encoder`/`Decoder` implementation to test yet */
		}
	}
	
	static var allTests = [
		("testOk", testOk)
	]
}
