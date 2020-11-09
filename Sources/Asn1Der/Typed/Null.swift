import Foundation


/// A DER null object
public struct DERNull: DERTyped {
    /// The associated DER tag
    public static let tag: UInt8 = 0x05

    /// Initializes the DER null object
    public init() {}
    public init(with object: DERAny) throws {
        guard object.tag == Self.tag else {
            throw DERError.invalidData("Object is not a null object")
        }
        guard object.value.isEmpty else {
            throw DERError.invalidData("Object is not a valid null object")
        }
    }
    
    public func object() -> DERAny {
        DERAny(tag: Self.tag, value: Data())
    }
}
extension DERNull: Codable {
    public init(from decoder: Decoder) throws {
        guard try Bool?(from: decoder) == nil else {
            throw DERError.invalidData("Object is not a valid null object")
        }
        self.init()
    }
    public func encode(to encoder: Encoder) throws {
        try Bool?.none.encode(to: encoder)
    }
}


extension Optional: DERTyped where Wrapped: DERTyped {
    public init(with object: DERAny) throws {
        switch object.tag {
            case DERNull.tag:
                _ = try DERNull(with: object)
                self = .none
            default:
                let wrapped = try Wrapped(with: object)
                self = .some(wrapped)
        }
    }
    
    public func object() -> DERAny {
        switch self {
            case .none: return DERNull().object()
            case .some(let wrapped): return wrapped.object()
        }
    }
}
