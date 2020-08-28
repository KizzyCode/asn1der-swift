import Foundation


/// A boxed integer to provide interior mutability
public class BoxedInt {
    /// The boxed value
    public var value: Int
    
    /// Initializes the boxed integer with `value`
    public init(_ value: Int = 0) {
        self.value = value
    }
}


/// A DER sequence walker
private struct SequenceWalker<Key> {
	let decoder: RealDERDecoder
	let objects: [DERObject]
	var position = BoxedInt()
	
    public init(decoder: RealDERDecoder, objects: [DERObject] = []) {
        self.decoder = decoder
        self.objects = objects
    }
    
	func superDecoder() throws -> Decoder {
		self.decoder
	}
	
	/// Returns the next object in the sequence
    func next(_ key: String? = nil) throws -> DERAny {
		switch self.isAtEnd {
			case false:
                defer { self.position.value += 1 }
				return self.objects[self.currentIndex].object()
			default:
				throw DERError.invalidData("The DER sequence has no field left to decode key \"\(key ?? "<unkeyed>")\"")
		}
	}
}
extension SequenceWalker: KeyedDecodingContainerProtocol where Key: CodingKey {
    var codingPath: [CodingKey] { [] }
    var allKeys: [Key] { [] }
    
    func decodeNil(forKey key: Key) throws -> Bool {
        let isNil = (try? DERNull(with: try self.next())) != nil
        if !isNil {
            // Rewind the index if because if we don't have nil the field is read twice
            self.position.value -= 1
        }
        return isNil
	}
    func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T: Decodable {
		let decoder = RealDERDecoder(object: try self.next(key.stringValue))
		return try T(from: decoder)
	}
	
    func nestedContainer<NestedKey: CodingKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws
    -> KeyedDecodingContainer<NestedKey> {
		let sequence = try DERSequence(with: try self.next(key.stringValue))
		return KeyedDecodingContainer(SequenceWalker<NestedKey>(decoder: self.decoder, objects: sequence.value))
	}
    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
		let sequence = try DERSequence(with: try self.next(key.stringValue))
		return SequenceWalker(decoder: self.decoder, objects: sequence.value)
	}
	
	func contains(_ key: Key) -> Bool {
		true
	}
	
	func superDecoder(forKey key: Key) throws -> Decoder {
		self.decoder
	}
}
extension SequenceWalker: UnkeyedDecodingContainer {
    var codingPath: [CodingKey] { [] }
    var currentIndex: Int { self.position.value }
    var count: Int? { self.objects.count }
    var isAtEnd: Bool { self.currentIndex >= self.objects.count }
    
    func decodeNil() throws -> Bool {
        let isNil = (try? DERNull(with: try self.next())) != nil
        if !isNil {
            // Rewind the index if because if we don't have nil the field is read twice
            self.position.value -= 1
        }
        return isNil
	}
    func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
		let decoder = RealDERDecoder(object: try self.next())
		return try T(from: decoder)
	}
	
    func nestedContainer<NestedKey: CodingKey>(keyedBy type: NestedKey.Type) throws
    -> KeyedDecodingContainer<NestedKey> {
		let sequence = try DERSequence(with: try self.next())
		return KeyedDecodingContainer(SequenceWalker<NestedKey>(decoder: self.decoder, objects: sequence.value))
	}
    func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
		let sequence = try DERSequence(with: try self.next())
		return SequenceWalker(decoder: self.decoder, objects: sequence.value)
	}
}


/// A DER data walker
private struct DataWalker {
	let decoder: RealDERDecoder
	let data: Data
	var position = BoxedInt()
}
extension DataWalker: UnkeyedDecodingContainer {
    var currentIndex: Int { self.position.value }
    var codingPath: [CodingKey] { [] }
    var count: Int? { self.data.count }
    var isAtEnd: Bool { self.currentIndex >= self.data.count }
    
    func decodeNil() throws -> Bool {
        throw DERError.invalidData("Cannot decode a non-byte element from an OctetString")
    }
    func decode(_ type: UInt8.Type) throws -> UInt8 {
        switch self.isAtEnd {
            case false:
                defer { self.position.value += 1 }
                return self.data[self.currentIndex]
            default:
                throw DERError.invalidData("There are no more bytes in the OctetString left")
        }
    }
    func decode<T: Decodable>(_ type: T.Type) throws -> T {
        throw DERError.invalidData("Cannot decode a non-byte element from an OctetString")
    }
    
    func nestedContainer<NestedKey: CodingKey>(keyedBy type: NestedKey.Type) throws
    -> KeyedDecodingContainer<NestedKey> {
        throw DERError.invalidData("Cannot decode subobjects because an OctetString is not a nested type")
    }
    func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        throw DERError.invalidData("Cannot decode subobjects because an OctetString is not a nested type")
    }
    
    func superDecoder() throws -> Decoder {
        self.decoder
    }
}


/// A single value decoder
private struct SingleValueDecoder {
	let object: DERAny
}
extension SingleValueDecoder: SingleValueDecodingContainer {
    var codingPath: [CodingKey] { [] }
    
    func decodeNil() -> Bool {
        (try? DERNull(with: self.object)) != nil
    }
    func decode<T: Decodable & DERObject>(_ type: T.Type) throws -> T {
        try T(with: self.object)
    }
    func decode<T: Decodable>(_ type: T.Type) throws -> T {
        throw DERError.unsupportedType(type)
    }
}


/// A DER decoder
public class DERDecoder {
	/// The decoder options
	public struct Options: OptionSet {
		/// The raw value
		public var rawValue: UInt
		
		/// Creates a new decoder option set
		public init(rawValue: RawValue = 0) {
			self.rawValue = rawValue
		}
		
		/// Allows trailing bytes after decoding the first top-level object
		public static let allowTrailingBytes = Self(rawValue: 1 << 0)
	}
	
	/// The decoder options for this instance
	public let options: Options
	
	/// Creates a new `DERDecoder`
	public init(options: Options = Options()) {
		self.options = options
	}
	
	/// DER decodes an object of type `T` from `data`
	public func decode<T: Decodable, D: DataProtocol>(_ type: T.Type = T.self, data: D) throws -> T {
        // Decode object
        var data = Data(data)
        let object = try DERAny(decode: &data)
        
        // Validate that there are no trailing bytes left if the corresponding option is set
        if !self.options.contains(.allowTrailingBytes) && !data.isEmpty {
            throw DERError.other("Trailing bytes after first top-level object")
        }
        
        // Create decoder
        let decoder = RealDERDecoder(object: object)
		return try T(from: decoder)
	}
}


/// The real decoder
private struct RealDERDecoder {
	public let object: DERAny
}
extension RealDERDecoder: Decoder {
	public var codingPath: [CodingKey] { [] }
	public var userInfo: [CodingUserInfoKey: Any] { [:] }
	
    public func container<Key: CodingKey>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> {
		let sequence = try DERSequence(with: self.object)
		return KeyedDecodingContainer(SequenceWalker<Key>(decoder: self, objects: sequence.value))
	}
	public func unkeyedContainer() throws -> UnkeyedDecodingContainer {
		switch self.object.tag {
			case DEROctetString.tag:
				let octetString = try DEROctetString(with: self.object)
				return DataWalker(decoder: self, data: octetString.value)
			default:
				let sequence = try DERSequence(with: self.object)
				return SequenceWalker<Void>(decoder: self, objects: sequence.value)
		}
	}
	public func singleValueContainer() throws -> SingleValueDecodingContainer {
		SingleValueDecoder(object: self.object)
	}
}