import Foundation


/// A DER coding related error
public enum DERError: Error {
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
	init(decode data: inout Data) throws
	
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
        try self.init(decode: &data)
	}
	/// DER decodes `Self` from `source` if the total encoded size of `self` does not exceed limit
	init(decode data: inout Data) throws {
		let object = try DERAny(decode: data)
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
    public convenience init(decode data: inout Data) throws {
		// Read tag and length
        guard let tag = data.popFirst() else {
            throw DERError.invalidData("DER object is truncated")
        }
        let length = try Int(derLength: &data)
        
		// Read value and create object
        guard data.count >= length else {
            throw DERError.invalidData("DER object is truncated")
        }
        let value = Data(data.prefix(length))
        
        data = Data(data.dropFirst(length))
        self.init(tag: tag, value: value)
	}
	
	public func object() -> DERAny {
		self
	}
	// "Override" the propagating default implementation with the real implementationb here
	public func encode(to data: inout Data) {
        data.append(self.tag)
        data.append(self.value.count.derLength)
        data.append(self.value)
	}
}
