import Foundation


/// An iterator over a DER sequence object
public struct DERSequenceIterator {
    /// The sequence to iterate over
    private let sequence: DERSequence
    /// The position within the sequence
    private var position = 0
    
    /// The amount of elements remaining in this iterator
    public var remaining: Int { self.sequence.value.count - self.position }
    /// Whether the iterator is empty or not
    public var isEmpty: Bool { self.remaining == 0 }
    
    /// Initializes the iterator with a `sequence`
    ///
    ///  - Parameter sequence: The sequence to iterate over
    init(sequence: DERSequence) {
        self.sequence = sequence
    }
    
    /// Returns the next element as `T`
    ///
    ///  - Parameter type: The type as which the next element should be decoded
    ///  - Returns: The next element
    ///  - Throws:
    ///     - `DERError.other` if the iterator is exhausted
    ///     - `DERError` if the next element cannot be decoded as `T`
    public mutating func next<T: DERTyped>(type: T.Type = T.self) throws -> T {
        guard let next = self.next() else {
            throw DERError.other("The iterator is exhaustet")
        }
        return try T(with: next.object())
    }
}
extension DERSequenceIterator: IteratorProtocol {
    public typealias Element = DERTyped
    
    public mutating func next() -> DERTyped? {
        switch self.remaining {
            case 0:
                return nil
            default:
                defer { self.position += 1 }
                return self.sequence.value[self.position]
        }
    }
}


/// A DER sequence object
final public class DERSequence: DERTyped {
    /// The associated DER tag
    public static let tag: UInt8 = 0x30
    
    /// The elements in the sequence
    public var value: [DERTyped]
    
    /// Initializes the DER sequence with `elements`
    ///
    ///  - Parameter elements: The elements to initialize the sequence with
    public init(_ elements: [DERTyped] = []) {
        self.value = elements
    }
    public init(with object: DERAny) throws {
        guard object.tag == Self.tag else {
            throw DERError.invalidData("Object is not a sequence")
        }
        
        // Create array and counting source
        var value: [DERTyped] = []
        var source = object.value
        
        // Read elements as long as the source is not empty
        while !source.isEmpty {
            value.append(try DERAny(decode: &source))
        }
        self.value = value
    }

    public func object() -> DERAny {
        var value = Data()
        self.value.forEach({ $0.encode(to: &value) })
        return DERAny(tag: Self.tag, value: value)
    }
    
    /// Creates an iterator over the sequence
    ///
    ///  - Returns: An iterator over the elements in the sequence
    public func makeIterator() -> DERSequenceIterator {
        DERSequenceIterator(sequence: self)
    }
}


extension Array: DERTyped where Element: DERTyped {
    public init(with object: DERAny) throws {
        let sequence = try DERSequence(with: object)
        self = try sequence.value.map({ try Element(with: $0.object()) })
    }
    
    public func object() -> DERAny {
        DERSequence(self).object()
    }
}
