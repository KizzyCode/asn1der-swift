import Foundation


/// A DER UTF-8 string object
final public class DERUTF8String: DERObject {
	/// The associated DER tag
	public static let tag: UInt8 = 0x0c

	/// The string value
	let value: String


	/// Initializes the DER UTF-8 string with `string`
	public init(_ string: String) {
		self.value = string
	}
	public init(with object: DERAny) throws {
		guard object.tag == Self.tag else {
			throw DERError.invalidData("Object is not a UTF-8 string")
		}
		switch String(bytes: object.value, encoding: .utf8) {
			case .some(let string): self.value = string
			case .none: throw DERError.invalidData("Object is not a valid UTF-8 string")
		}
	}

	public func object() -> DERAny {
		DERAny(tag: Self.tag, value: self.value.data(using: .utf8)!)
	}
}


extension String: DERObject {
	public init(with object: DERAny) throws {
		self = try DERUTF8String(with: object).value
	}
	
	public func object() -> DERAny {
		DERUTF8String(self).object()
	}
}
