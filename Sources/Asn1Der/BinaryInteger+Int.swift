import Foundation


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
			defer { num >>= 8 }
			return UInt8(truncatingIfNeeded: num)
		})
		return Data(bytes.reversed())
	}

	/// Inits `Self` with up to `Self.byteWidth` big-endian bytes
    ///
    ///  - Parameter bytes: The big-endian encoded bytes
    ///  - Throws: `DERError.unsupported` if the width of `self` is too small
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


// Implement DER length coding for `Int`
internal extension Int {
    /// `self` as DER length field
    var derLength: Data {
        // Check for negative length
        precondition(self >= 0, "Cannot encode a negative length")
        
        // Check for and encode simple or complex length
        switch self {
            case _ where self < 0b1000_0000:
                return Data([UInt8(self)])
            default:
                let bytes = UInt(self).bigEndianBytes
                return Data([0b1000_0000 | UInt8(bytes.count)]) + bytes
        }
    }
    
    /// Decodes and removes the length field from `data`
    ///
    ///  - Parameter data: The data to decode and remove the length field from
    ///  - Throws:
    ///     - `DERError.invalidData` if the length field is truncated or invalid
    ///     - `DERError.unsupported` if the encoded length is larger than `Int.max`
    init(derLength data: inout Data) throws {
        // Check for and decode simple or complex length
        guard let first = data.popFirst() else {
            throw DERError.invalidData("The DER length is truncated")
        }
        switch Int(first) {
            case let length where length < 0b1000_0000:
                self = length
            case let length:
                // Get the size of the complex length and validate that we have enough bytes
                let size = length & 0b0111_1111
                guard data.count >= size else {
                    throw DERError.invalidData("The DER length is truncated")
                }
                
                // Decode and validate the complex length
                let bytes = data.prefix(size)
                data = data.dropFirst(size)
                switch Int(exactly: try UInt(bigEndianBytes: bytes)) {
                    case .some(let length) where length >= 0b1000_0000:
                        self = length
                    case .some:
                        throw DERError.invalidData("DER length < 128 is encoded as complex length")
                    case .none:
                        throw DERError.unsupported("The DER length is larger than `Int.max`")
                }
        }
    }
}
