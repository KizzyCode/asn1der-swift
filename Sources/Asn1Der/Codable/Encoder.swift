import Foundation


/// A generic top-level object
private class GenericObject: DERObject {
    /// The wrapped object
    private var _wrapped: DERObject!
    /// The wrapped object
    public var wrapped: DERObject {
        get { self._wrapped! }
        set { self._wrapped = newValue }
    }
    
    /// Accesses the wrapped object as sequence
    public var sequence: [DERObject] {
        get { (self._wrapped! as! DERSequence).value }
        set { self._wrapped = DERSequence(newValue) }
    }
    
    /// Accesses the wrapped object as octet string
    public var data: Data {
        get { (self._wrapped as! DEROctetString).value }
        set { self._wrapped = DEROctetString(newValue) }
    }
    
    /// Creates a new top-level object by wrapping `object`
    required public init(wrapping object: DERObject! = nil) {
        self._wrapped = object
    }
    
    @available(*, deprecated, message: "Constructor to conform to `DERObject` – will raise a fatal error")
    required public init(with object: DERAny) throws {
        fatalError("Cannot decode a generic top-level object")
    }
    func object() -> DERAny {
        self._wrapped.object()
    }
}


/// A DER sequence builder
private struct SequenceBuilder<Key> {
    var encoder: RealDEREncoder
    var object: GenericObject
    
    /// Encodes any value
    private func encodeAny<T: Encodable>(_ value: T?) throws {
        if let value = value {
        	let encoder = RealDEREncoder(type: T.self)
        	try value.encode(to: encoder)
        	self.object.sequence.append(encoder.topLevel.object())
        } else {
            self.object.sequence.append(DERNull())
        }
    }
}
extension SequenceBuilder: KeyedEncodingContainerProtocol where Key: CodingKey {
    var codingPath: [CodingKey] { [] }
    
    // - MARK: The `encodeIfPresent` functions are necessary to properly encode `nil` values
    
    func encodeIfPresent(_ value: Bool?, forKey key: Key) throws {
        try self.encodeAny(value)
    }
    func encodeIfPresent(_ value: String?, forKey key: Key) throws {
        try self.encodeAny(value)
    }
    func encodeIfPresent(_ value: Double?, forKey key: Key) throws {
        try self.encodeAny(value)
    }
    func encodeIfPresent(_ value: Float?, forKey key: Key) throws {
        try self.encodeAny(value)
    }
    func encodeIfPresent(_ value: Int?, forKey key: Key) throws {
        try self.encodeAny(value)
    }
    func encodeIfPresent(_ value: Int8?, forKey key: Key) throws {
        try self.encodeAny(value)
    }
    func encodeIfPresent(_ value: Int16?, forKey key: Key) throws {
        try self.encodeAny(value)
    }
    func encodeIfPresent(_ value: Int32?, forKey key: Key) throws {
        try self.encodeAny(value)
    }
    func encodeIfPresent(_ value: Int64?, forKey key: Key) throws {
        try self.encodeAny(value)
    }
    func encodeIfPresent(_ value: UInt?, forKey key: Key) throws {
        try self.encodeAny(value)
    }
    func encodeIfPresent(_ value: UInt8?, forKey key: Key) throws {
        try self.encodeAny(value)
    }
    func encodeIfPresent(_ value: UInt16?, forKey key: Key) throws {
        try self.encodeAny(value)
    }
    func encodeIfPresent(_ value: UInt32?, forKey key: Key) throws {
        try self.encodeAny(value)
    }
    func encodeIfPresent(_ value: UInt64?, forKey key: Key) throws {
        try self.encodeAny(value)
    }
    func encodeIfPresent<T: Encodable>(_ value: T?, forKey key: Key) throws {
        try self.encodeAny(value)
    }
    func encodeNil(forKey key: Key) throws {
        try self.encodeAny(Bool?.none)
    }
    func encode<T: Encodable>(_ value: T, forKey key: Key) throws {
        try self.encodeAny(value)
    }
    
    func nestedContainer<NestedKey: CodingKey>(keyedBy keyType: NestedKey.Type, forKey key: Key)
    -> KeyedEncodingContainer<NestedKey> {
        let nestedSequence = DERSequence()
        self.object.sequence.append(nestedSequence)
        return KeyedEncodingContainer(SequenceBuilder<NestedKey>(encoder: self.encoder,
                                                                 object: GenericObject(wrapping: nestedSequence)))
    }
    func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        let nestedSequence = DERSequence()
        self.object.sequence.append(nestedSequence)
        return SequenceBuilder(encoder: self.encoder, object: GenericObject(wrapping: nestedSequence))
    }
    
    func superEncoder() -> Encoder {
        self.encoder
    }
    func superEncoder(forKey key: Key) -> Encoder {
        self.encoder
    }
}
extension SequenceBuilder: UnkeyedEncodingContainer {
    var codingPath: [CodingKey] { [] }
    var count: Int { self.object.sequence.count }
    
    // - MARK: The `encodeIfPresent` functions are necessary to properly encode `nil` values
    
    func encodeIfPresent(_ value: Bool?) throws {
        try self.encodeAny(value)
    }
    func encodeIfPresent(_ value: String?) throws {
        try self.encodeAny(value)
    }
    func encodeIfPresent(_ value: Double?) throws {
        try self.encodeAny(value)
    }
    func encodeIfPresent(_ value: Float?) throws {
        try self.encodeAny(value)
    }
    func encodeIfPresent(_ value: Int?) throws {
        try self.encodeAny(value)
    }
    func encodeIfPresent(_ value: Int8?) throws {
        try self.encodeAny(value)
    }
    func encodeIfPresent(_ value: Int16?) throws {
        try self.encodeAny(value)
    }
    func encodeIfPresent(_ value: Int32?) throws {
        try self.encodeAny(value)
    }
    func encodeIfPresent(_ value: Int64?) throws {
        try self.encodeAny(value)
    }
    func encodeIfPresent(_ value: UInt?) throws {
        try self.encodeAny(value)
    }
    func encodeIfPresent(_ value: UInt8?) throws {
        try self.encodeAny(value)
    }
    func encodeIfPresent(_ value: UInt16?) throws {
        try self.encodeAny(value)
    }
    func encodeIfPresent(_ value: UInt32?) throws {
        try self.encodeAny(value)
    }
    func encodeIfPresent(_ value: UInt64?) throws {
        try self.encodeAny(value)
    }
    func encodeIfPresent<T: Encodable>(_ value: T?) throws {
        try self.encodeAny(value)
    }
    func encodeNil() throws {
        try self.encodeAny(Bool?.none)
    }
    func encode<T: Encodable>(_ value: T) throws {
        try self.encodeAny(value)
    }
    
    func nestedContainer<NestedKey: CodingKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> {
        let nestedSequence = DERSequence()
        self.object.sequence.append(nestedSequence)
        return KeyedEncodingContainer(SequenceBuilder<NestedKey>(encoder: self.encoder,
                                                                 object: GenericObject(wrapping: nestedSequence)))
    }
    func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        let nestedSequence = DERSequence()
        self.object.sequence.append(nestedSequence)
        return SequenceBuilder(encoder: self.encoder, object: GenericObject(wrapping: nestedSequence))
    }
    
    func superEncoder() -> Encoder {
        self.encoder
    }
}


/// A data builder
private struct DataBuilder {
    var encoder: RealDEREncoder
    var object: GenericObject
}
extension DataBuilder: UnkeyedEncodingContainer {
    var codingPath: [CodingKey] { [] }
    var count: Int { self.object.data.count }
    
    func encodeNil() throws {
        fatalError("Cannot encode nil as OctetString")
    }
    func encode(_ value: UInt8) throws {
        self.object.data.append(value)
    }
    func encode<T: Encodable>(_ value: T) throws {
        fatalError("Cannot encode \(T.self) as OctetString")
    }
    
    func nestedContainer<NestedKey: CodingKey>(keyedBy keyType: NestedKey.Type)
    -> KeyedEncodingContainer<NestedKey> {
        fatalError("Cannot encode subelements of an OctetString")
    }
    func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        fatalError("Cannot encode subelements of an OctetString")
    }
    
    func superEncoder() -> Encoder {
        self.encoder
    }
}


/// A single value builder
private struct SingleValueEncoder {
    var object: GenericObject
}
extension SingleValueEncoder: SingleValueEncodingContainer {
    var codingPath: [CodingKey] { [] }
    
    func encodeNil() throws {
        self.object.wrapped = DERNull()
    }
    func encode<T: Encodable & DERObject>(_ value: T) throws {
        self.object.wrapped = value
    }
    func encode<T: Encodable>(_ value: T) throws {
        throw DERError.unsupportedType(T.self)
    }
}


/// A DER encoder
public class DEREncoder {
    /// Creates a new DER encoder instance
    public init() {}
    
    /// Encodes `value`
    public func encode<T: Encodable>(_ value: T) throws -> Data {
        let encoder = RealDEREncoder(type: T.self)
        try value.encode(to: encoder)
        return encoder.topLevel.encode()
    }
}


/// The real encoder
private struct RealDEREncoder {
    public let type: Any.Type
    public let topLevel = GenericObject()
}
extension RealDEREncoder: Encoder {
    public var codingPath: [CodingKey] { [] }
    public var userInfo: [CodingUserInfoKey: Any] { [:] }
    
    public func container<Key: CodingKey>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> {
        self.topLevel.sequence = []
        return KeyedEncodingContainer(SequenceBuilder(encoder: self, object: self.topLevel))
    }
    public func unkeyedContainer() -> UnkeyedEncodingContainer {
        if self.type == Data.self {
            self.topLevel.data = Data()
            return DataBuilder(encoder: self, object: self.topLevel)
        } else {
            self.topLevel.sequence = []
            return SequenceBuilder<Void>(encoder: self, object: self.topLevel)
        }
    }
    public func singleValueContainer() -> SingleValueEncodingContainer {
        SingleValueEncoder(object: self.topLevel)
    }
}
