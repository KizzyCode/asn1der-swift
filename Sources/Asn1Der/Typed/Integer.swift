import Foundation


/// A DER integer object
final public class DERInteger: DERObject {
	/// The associated DER tag
	public static let tag: UInt8 = 0x02

	/// The raw number bytes
	public let raw: Data
	/// Indicates whether the number is negative or not
	public var isNegative: Bool { self.raw[0] & 0b1000_0000 != 0 }
	/// The number bytes without leading zero bytes
	///
	///  - Warning: since any leading zero-byte that might indicate a positive number is stripped off, a return value of
    ///    e.g. `0b1111_1111` can be either `255` or `-1` depending on whether the number is negative or not. Use
	///    `isNegative` to determine the correct sign.
	public var bigEndianBytes: Data { self.raw.drop(while: { $0 == 0 }) }
	
	/// Creates a new integer object with the big-endian encoded `numBytesBE`
    ///
    ///  - Parameters:
    ///     - bigEndianBytes: The raw big-endian encoded number bytes
    ///     - isNegative: A flag indicating whether `bigEndianBytes` represents a negative value or not (this is
    ///       necessary to prepend a leading zero byte in case the number is positive but the first bit is set)
	public init(bigEndianBytes: Data, isNegative: Bool) {
		// Remove all leading zero bytes and re-add a leading zero byte if necessary
		switch bigEndianBytes.drop(while: { $0 == 0 }) {
			case let raw where raw.isEmpty:
				self.raw = Data([0x00])
			case let raw where raw[0] & 0b1000_0000 != 0 && !isNegative:
				self.raw = [0x00] + raw
			case let raw:
				self.raw = raw
		}
	}
	public init(with object: DERAny) throws {
		guard object.tag == Self.tag else {
			throw DERError.invalidData("Object is not an integer")
		}
		
		// Validate the number
		switch object.value {
			case let value where value.isEmpty:
				throw DERError.invalidData("Object is not a valid integer")
			case let value where value.count > 1 && value[0] == 0x00 && value[1] & 0b1000_0000 == 0:
				throw DERError.invalidData("Object is not a valid integer")
			case let value where value.count > 1 && value[0] == 0xff && value[1] & 0b1000_0000 != 0:
				throw DERError.invalidData("Object is not a valid integer")
			case let value:
				self.raw = value
		}
	}
	
	public func object() -> DERAny {
		DERAny(tag: Self.tag, value: self.raw)
	}
}


// Implement DER coding for any binary Integer
public extension BinaryInteger where Self: FixedWidthInteger, Self: UnsignedInteger {
	init(with object: DERAny) throws {
		switch try DERInteger(with: object) {
			case let integer where integer.isNegative:
				throw DERError.unsupported("Integer is negative")
			case let integer:
				self = try Self(bigEndianBytes: integer.bigEndianBytes)
		}
	}
	
	func object() -> DERAny {
        DERInteger(bigEndianBytes: self.bigEndianBytes, isNegative: self < 0).object()
	}
}


// Implement DER coding protocols for common unsigned integer types
extension UInt: DERObject {}
extension UInt8: DERObject {}
extension UInt16: DERObject {}
extension UInt32: DERObject {}
extension UInt64: DERObject {}
