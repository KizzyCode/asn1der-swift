import Foundation


/// A DER boolean object
final public class DERBoolean: DERObject {
    /// The associated DER tag
    public static let tag: UInt8 = 0x01
    
    /// The boolean value
    public var value: Bool

    /// Initializes the DER boolean with `value`
    ///
    ///  - Parameter value: The value to initialize the boolean with
    public init(_ value: Bool) {
        self.value = value
    }
    public init(with object: DERAny) throws {
        guard object.tag == Self.tag else {
            throw DERError.invalidData("Object is not a boolean")
        }
        switch object.value {
            case Data([0xff]): self.value = true
            case Data([0x00]): self.value = false
            default: throw DERError.invalidData("Object is not a valid boolean")
        }
    }
    
    public func object() -> DERAny {
        switch self.value {
            case true: return DERAny(tag: Self.tag, value: Data([0xff]))
            case false: return DERAny(tag: Self.tag, value: Data([0x00]))
        }
    }
}


extension Bool: DERObject {
    public init(with object: DERAny) throws {
        self = try DERBoolean(with: object).value
    }
    
    public func object() -> DERAny {
        DERBoolean(self).object()
    }
}
