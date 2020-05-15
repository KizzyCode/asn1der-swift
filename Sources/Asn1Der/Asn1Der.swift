import Foundation


/// A DER coding related error
public enum DERError: Error {
	/// An in-out error occurred (e.g. failed to read/write some bytes)
	case inOutError(String, StaticString = #file, Int = #line)
	/// The data has an invalid encoding
	case invalidData(String, StaticString = #file, Int = #line)
	/// The object type or length is not supported by this implementation
	case unsupported(String, StaticString = #file, Int = #line)
	/// The object type or length is not supported by this implementation
	case unsupportedType(Any.Type, String = "The requested type is unsupported", StaticString = #file, Int = #line)
	/// An unspecified error
	case other(String, StaticString = #file, Int = #line)
}


/// A typed DER object
public protocol DERObject {
	/// Inits `Self` with `object`
	init(with object: DERAny) throws
	/// DER decodes `Self` from `data`
	init<D: DataProtocol>(decode data: D) throws
	/// DER decodes `Self` from `source` if the total encoded size of `self` does not exceed limit
	init(decode source: @escaping () throws -> UInt8, limit: Int) throws
	
	/// Creates an untyped/generic DER object from `self`
	func object() -> DERAny
	/// DER encodes `self` to `data`
	func encode(to data: inout Data) throws
	/// DER encodes `self`
	func encode() -> Data
}
public extension DERObject {
	/// DER decodes `Self` from `data`
	init<D: DataProtocol>(decode data: D) throws {
		var data = Data(data)
		try self.init(decode: { try data.read() }, limit: Int.max)
	}
	/// DER decodes `Self` from `source` if the total encoded size of `self` does not exceed limit
	init(decode source: @escaping () throws -> UInt8, limit: Int) throws {
		let object = try DERAny(decode: source, limit: limit)
		try self.init(with: object)
	}
	
	/// DER encodes `self` to `data`
	func encode(to data: inout Data) throws {
		self.object().encode(to: &data)
	}
	/// DER encodes `self`
	func encode() -> Data {
		var data = Data()
		try! self.encode(to: &data)
		return data
	}
}


/// An untyped/generic DER object
final public class DERAny {
	/// The object tag
	public let tag: UInt8
	/// The object value
	public let value: Data
	
	
	/// Creates a new DER object with `tag` and `value`
	public init<D: DataProtocol>(tag: UInt8, value: D) {
		self.tag = tag
		self.value = Data(value)
	}
}
extension DERAny: DERObject {
	public convenience init(with object: DERAny) {
		self.init(tag: object.tag, value: object.value)
	}
	public convenience init(decode nextByte: @escaping () throws -> UInt8, limit: Int) throws {
		// Read tag
		let tag = try nextByte()
		
		// Read length
		var lengthSize = 0
		let length = try Int(decodeLength: {
			lengthSize += 1
			return try nextByte()
		})
		
		// Validate limit
		guard let total = Int(checkedSum: 1, lengthSize, length) else {
			throw DERError.unsupported("Cannot decode object because it's length would exceed `Int.max`")
		}
		guard total <= limit else {
			throw DERError.other("Cannot decode object because it's length would exceed the given limit")
		}
		
		// Read value and create object
		let value = try Data(from: nextByte, length: length)
		self.init(tag: tag, value: value)
	}
	
	public func object() -> DERAny {
		self
	}
	// "Override" the propagating default implementation with the real implementationb here
	public func encode(to data: inout Data) {
		data.write(self.tag)
		data.writeLength(self.value.count)
		data.write(self.value)
	}
}
