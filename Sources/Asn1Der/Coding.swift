import Foundation


/// An ARC managed box to share pass-by-value/implicit-copy elements like structs etc
internal class Box<T> {
	/// The wrapped value
	public var boxed: T
	
	/// Creates a new `Box` around element
	public init(_ element: T) {
		self.boxed = element
	}
}


// Implement big-endian byte coding methods for unsigned integers
internal extension BinaryInteger where Self: FixedWidthInteger, Self: UnsignedInteger {
	/// The byte width of `Self`
	static var byteWidth: Int { Self.bitWidth / 8 }

	/// The big-endian encoded bytes of `Self` (leading zero-bytes are truncated)
	var bigEndianBytes: Data {
		// Compute the amount of bytes to skip and capture value
		let skip = self.leadingZeroBitCount / 8
		var num = self
		
		// Encode the number
		let bytes: [UInt8] = (0 ..< Self.byteWidth - skip).map({ _ in
			defer{ num >>= 8 }
			return UInt8(truncatingIfNeeded: num)
		})
		return Data(bytes.reversed())
	}

	/// Inits `Self` with up to `Self.byteWidth` big-endian bytes
	init<D: DataProtocol>(bigEndianBytes bytes: D) throws {
		// Validate that the number can fit
		guard bytes.count <= Self.byteWidth else {
			throw DERError.unsupported("Cannot decode integer because the target type is too small")
		}
		
		// Decode the number
		self = bytes.reduce(into: Self.zero, {
			$0 <<= 8
			$0 |= Self(exactly: $1)!
		})
	}
}


// Implement mutating read and write functions for `Data`
internal extension Data {
	/// Creates a new `Data` object from `nextByte`
	init(from nextByte: () throws -> UInt8, length: Int) rethrows {
		self.init()
		for _ in 0 ..< length { self.write(try nextByte()) }
	}
	
	/// Reads and removes the next byte from `self`
	mutating func read() throws -> UInt8 {
		switch self.popFirst() {
			case .some(let byte): return byte
			case .none: throw DERError.inOutError("There are no more bytes to read")
		}
	}
	/// Reads and removes the next `count` bytes from `self`
	mutating func read(_ count: Int) throws -> Data {
		Data(try (0 ..< count).map({ _ in try self.read() }))
	}
	
	/// Writes `byte` to `self`
	mutating func write(_ byte: UInt8) {
		self.append(byte)
	}
	/// Writes `data` to `self`
	mutating func write<D: DataProtocol>(_ data: D) {
		data.forEach({ self.write($0) })
	}
}


// Implement DER length field coding for `Int`
internal extension Int {
	/// Decodes a DER encoded length
	init(decodeLength nextByte: () throws -> UInt8) throws {
		// Read first byte
		let first = try nextByte()
		
		// Check for and decode simple or complex length
		switch Int(first) {
			case let length where length < 0b1000_0000:
				self = length
			case let length where length & 0b0111_1111 > UInt.byteWidth:
				throw DERError.unsupported("The DER length is larger than `Int.max`")
			case let length:
				let bytes = try (0 ..< length & 0b0111_1111).map({ _ in try nextByte() })
				switch Int(exactly: try UInt(bigEndianBytes: bytes)) {
					case .some(let length) where length < 0b1000_0000:
						throw DERError.invalidData("DER length < 128 is encoded as complex length")
					case .some(let length):
						self = length
					case .none:
						throw DERError.unsupported("The DER length is larger than `Int.max`")
				}
		}
	}
}


internal extension Data {
	/// Encodes and writes `length` as DER length field to `self`
	mutating func writeLength(_ length: Int) {
		// Assert that the length is positive
		let length: UInt! = UInt(exactly: length)
		precondition(length != nil, "Cannot encode a negative length!")
	
		// Check for and encode simple or complex length
		switch length {
			case _ where length < 0b1000_0000:
				self.write(UInt8(length))
			default:
				let bytes = length.bigEndianBytes
				self.write(0b1000_0000 | UInt8(bytes.count))
				self.write(bytes)
		}
	}
}


// Implement an overflow safe sum-initializer for `Int`
internal extension Int {
	/// Adds `nums` and returns the sum or `nil` in case of an overflow
	init?(checkedSum nums: Int...) {
		var (sum, overflow) = (0, false)
		for num in nums {
			(sum, overflow) = sum.addingReportingOverflow(num)
			guard !overflow else {
				return nil
			}
		}
		self = sum
	}
}
