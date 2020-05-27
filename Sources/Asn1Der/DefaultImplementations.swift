import Foundation


// Provide a default DER coding implementation for raw-representable enums
//
//  - Note: Because you cannot extend Swift protocols directly, we can only provide a default implementation. You still have to "implement" `DERObject` for your `enum` etc.
extension DERObject where Self: RawRepresentable, Self.RawValue: DERObject {
	public init(with object: DERAny) throws {
		let value = try RawValue(with: object)
		switch Self(rawValue: value) {
			case .some(let this): self = this
			case .none: throw DERError.invalidData("Invalid enum value")
		}
	}
	public func object() -> DERAny {
		self.rawValue.object()
	}
}
