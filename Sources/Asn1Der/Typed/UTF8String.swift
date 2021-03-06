import Foundation


/// A DER UTF-8 string object
public struct DERUTF8String: DERTyped {
    /// The associated DER tag
    public static let tag: UInt8 = 0x0c

    /// The string value
    public let value: String

    /// Initializes the DER UTF-8 string with `string`
    ///
    ///  - Parameter string: the UTF-8 string to initialize `self` with
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
extension DERUTF8String: Codable {
    public init(from decoder: Decoder) throws {
        self.init(try String(from: decoder))
    }
    public func encode(to encoder: Encoder) throws {
        try self.value.encode(to: encoder)
    }
}


extension String: DERTyped {
    public init(with object: DERAny) throws {
        self = try DERUTF8String(with: object).value
    }
    
    public func object() -> DERAny {
        DERUTF8String(self).object()
    }
}
