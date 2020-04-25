import Foundation


/// A DER sequence object
final public class DERSequence: DERObject {
	/// The associated DER tag
	public static let tag: UInt8 = 0x30
	
	/// The subobjects
	var value: [DERObject]
	
	
	/// Initializes the DER sequence with `subobjects`
	public init(_ subobjects: [DERObject] = []) {
		self.value = subobjects
	}
	public init(with object: DERAny) throws {
		guard object.tag == Self.tag else {
			throw DERError.invalidData("Object is not a sequence")
		}
		
		// Create array and counting source
		var value: [DERObject] = []
		var source = SwiftDataSource(object.value)
		
		// Read elements as long as the source is not empty
		while !source.isExhausted {
			value.append(try DERAny(decode: &source, limit: Int.max))
		}
		self.value = value
	}

	public func object() -> DERAny {
		var value = Data()
		self.value.forEach({ try! $0.encode(to: &value) })
		return DERAny(tag: Self.tag, value: value)
	}
}


extension Array: DERObject where Element: DERObject {
	public init(with object: DERAny) throws {
		let sequence = try DERSequence(with: object)
		self = try sequence.value.map({ try Element(with: $0.object()) })
	}
	
	public func object() -> DERAny {
		DERSequence(self).object()
	}
}
