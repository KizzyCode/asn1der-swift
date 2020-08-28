import Foundation


/// A DER octet string object
final public class DEROctetString: DERTyped {
    /// The associated DER tag
    public static let tag: UInt8 = 0x04

    /// The data value
    public var value: Data

    /// Initializes the DER octet string with `data`
    ///
    ///  - Parameter data: The bytes to initialize the OctetString with
    public init<D: DataProtocol>(_ data: D) {
        self.value = Data(data)
    }
    public init(with object: DERAny) throws {
        guard object.tag == Self.tag else {
            throw DERError.invalidData("Object is not a octet string")
        }
        self.value = object.value
    }
    
    public func object() -> DERAny {
        DERAny(tag: Self.tag, value: self.value)
    }
}


extension Data: DERTyped {
    public init(with object: DERAny) throws {
        self = try DEROctetString(with: object).value
    }
    
    public func object() -> DERAny {
        DEROctetString(self).object()
    }
}
