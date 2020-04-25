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
	
	/// Creates an untyped/generic DER object from `self`
	func object() -> DERAny
}
public extension DERObject {
	/// DER decodes `Self` from `source` if the total encoded size of `self` does not exceed limit
	init<S: DataSource>(decode source: inout S, limit: Int) throws {
		let object = try DERAny(decode: &source, limit: limit)
		try self.init(with: object)
	}
	/// DER decodes `Self` from `data`
	init<D: DataProtocol>(decode data: D) throws {
		var source = SwiftDataSource(data)
		try self.init(decode: &source, limit: Int.max)
	}
	
	/// DER encodes `self` to `sink`
	func encode<S: DataSink>(to sink: inout S) throws {
		try self.object().encode(to: &sink)
	}
	/// DER encodes `self`
	func encode() -> Data {
		var data = Data()
		try! self.encode(to: &data)
		return data
	}
}


/// An untyped/generic DER object
final public class DERAny: DERObject {
	/// The object tag
	public let tag: UInt8
	/// The object value
	public let value: Data
	
	
	/// Creates a new DER object with `tag` and `value`
	public init<D: DataProtocol>(tag: UInt8, value: D) {
		self.tag = tag
		self.value = Data(value)
	}
	public init(with object: DERAny) {
		self.tag = object.tag
		self.value = object.value
	}
	/// Decodes `Self` from `source` if the total encoded size of `self` does not exceed limit
	public init<S: DataSource>(decode source: inout S, limit: Int) throws {
		// Read tag
		self.tag = try source.read()
		let (length, lengthFieldSize) = try source.readLength()
		
		// Validate limit and read value
		guard let total = Int(checkedSum: 1, lengthFieldSize, length) else {
			throw DERError.unsupported("Cannot decode object because it's length would exceed `Int.max`")
		}
		guard total <= limit else {
			throw DERError.other("Cannot decode object because it's length would exceed the given limit")
		}
		self.value = try source.read(count: length)
	}
	
	public func object() -> DERAny {
		self
	}
	
	/// Encodes `self` to `sink`
	public func encode<S: DataSink>(to sink: inout S) throws {
		try sink.write(self.tag)
		try! sink.writeLength(length: self.value.count)
		try sink.write(self.value)
	}
}
