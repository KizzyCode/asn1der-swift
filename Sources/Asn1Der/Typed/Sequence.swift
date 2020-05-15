import Foundation


/// An iterator over a DER sequence object
final public class DERSequenceIterator {
	private let sequence: DERSequence
	private var position = 0
	
	/// Initializes the iterator with a `sequence`
	init(sequence: DERSequence) {
		self.sequence = sequence
	}
	
	/// Returns the next element as `T`
	public func next<T: DERObject>() throws -> T {
		guard let next = self.next() else {
			throw DERError.invalidData("Not enough elements in sequence")
		}
		return try T(with: next.object())
	}
}
extension DERSequenceIterator: IteratorProtocol {
	public typealias Element = DERObject
	
	public func next() -> DERObject? {
		switch self.sequence.value.count {
			case let count where self.position < count:
				defer{ self.position += 1 }
				return self.sequence.value[self.position]
			default:
				return nil
		}
	}
}


/// A DER sequence object
final public class DERSequence: DERObject {
	/// The associated DER tag
	public static let tag: UInt8 = 0x30
	
	/// The subobjects
	public var value: [DERObject]
	
	
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
		var source = object.value
		
		// Read elements as long as the source is not empty
		while !source.isEmpty {
			value.append(try DERAny(decode: { try source.read() }, limit: Int.max))
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
