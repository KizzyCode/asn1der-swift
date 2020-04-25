import Foundation


/// A data source
public protocol DataSource {
	/// Reads the next byte
	mutating func read() throws -> UInt8
	/// Reads `count` bytes
	mutating func read(count: Int) throws -> Data
}
public extension DataSource {
	mutating func read(count: Int) throws -> Data {
		try (0 ..< count).reduce(into: Data(), { data, _ in data.append(try self.read()) })
	}
}


/// A data sink
public protocol DataSink {
	/// Writes the next `byte`
	mutating func write(_ byte: UInt8) throws
	/// Writes the next bytes from `sequence`
	mutating func write<S: Sequence>(_ sequence: S) throws where S.Element == UInt8
}
public extension DataSink {
	mutating func write<S: Sequence>(_ sequence: S) throws where S.Element == UInt8 {
		try sequence.forEach({ try self.write($0) })
	}
}


/// A data source wrapper around a Swift `DataProtocol` type
public struct SwiftDataSource {
	private let getElement: (Int) -> UInt8
	private let length: Int
	private(set) public var position: Int = 0
	
	/// Checks if the data source is exhausted
	public var isExhausted: Bool { self.position >= self.length }
	
	/// Creates a new `SwiftDataSource` over `data`
	public init<D: DataProtocol>(_ data: D) {
		self.getElement = {
			let index = data.index(data.startIndex, offsetBy: $0)
			return data[index]
		}
		self.length = data.count
	}
}
extension SwiftDataSource: DataSource {
	public mutating func read() throws -> UInt8 {
		switch self.position < self.length {
			case true:
				defer{ self.position += 1 }
				return self.getElement(self.position)
			case false:
				throw DERError.inOutError("The data source is exhausted")
		}
	}
}


// Provides a `write` API for `Data`
extension Data: DataSink {
	/// Writes `byte` to the end of `self`
	public mutating func write(_ byte: UInt8) {
		self.append(byte)
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
	init(bigEndianBytes bytes: Data) throws {
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


// Extensions to work with DER lengths
internal extension DataSource {
	/// Reads a DER length field
	mutating func readLength() throws -> (length: Int, lengthFieldSize: Int) {
		// Read first byte
		let first = try self.read()
		var size = 1
		
		// Check for and decode simple or complex length
		switch Int(first) {
			case let length where length < 0b1000_0000:
				return (length: length, lengthFieldSize: size)
			case let length where length & 0b0111_1111 > UInt.byteWidth:
				throw DERError.unsupported("The DER length is larger than `Int.max`")
			case let length:
				let bytes = try self.read(count: length & 0b0111_1111)
				size += length & 0b0111_1111
				switch Int(exactly: try UInt(bigEndianBytes: bytes)) {
					case .some(let length) where length < 0b1000_0000:
						throw DERError.invalidData("DER length < 128 is encoded as complex length")
					case .some(let length):
						return (length: length, lengthFieldSize: size)
					case .none:
						throw DERError.unsupported("The DER length is larger than `Int.max`")
				}
		}
	}
}
internal extension DataSink {
	/// Writes `len` as DER length field
	mutating func writeLength(length: Int) throws {
		// Validate that the length is positive
		guard let length = UInt(exactly: length) else {
			throw DERError.other("Cannot encode a negative length")
		}
	
		// Check for and encode simple or complex length
		switch length {
			case _ where length < 0b1000_0000:
				try self.write(UInt8(length))
			default:
				let bytes = length.bigEndianBytes
				try self.write(0b1000_0000 | UInt8(bytes.count))
				try self.write(bytes)
		}
	}
}


public extension Int {
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
