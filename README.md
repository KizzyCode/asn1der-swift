[![License BSD-2-Clause](https://img.shields.io/badge/License-BSD--2--Clause-blue.svg)](https://opensource.org/licenses/BSD-2-Clause)
[![License MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Travis CI](https://travis-ci.org/KizzyCode/asn1der-Swift.svg?branch=master)](https://travis-ci.org/KizzyCode/asn1der-swift)

# Asn1Der

Welcome to `Asn1Der` 🎉

`Asn1Der` is a basic ASN.1-DER implementation that offers simple de-/encoding support for some basic types:
 - The `ASN.1-BOOLEAN` type as `DERBoolean` object and Swift's `Bool` type
 - The `ASN.1-INTEGER` type as `DERInteger` object and Swift's `UInt`, `UInt8`, `UInt16`, `UInt32`, `UInt64` types
 - The `ASN.1-NULL` type as `DERNull` object and Swift's `Optional.none` type (which allows the encoding of optional elements)
 - The `ASN.1-OctetString` type as `DEROctetString` object and Swift's `Data` type
 - The `ASN.1-Sequence` type as `DERSequence` object and Swift's `Array` type
 - The `ASN.1-UTF8String` type as `DERUTF8String` object and Swift's `String` type


## Example

```swift
// Declare an encoded integer with value `7`
let encoded = Data([0x02, 0x01, 0x07])

// Decode a generic DER object
let object = try! DERAny(decode: encoded)

// Reencode the object
let encodedObject = object.encode()
precondition(encoded == encodedObject)


// Decode an UInt32
let uint = try! UInt32(decode: encoded)
precondition(uint == 7)

// Reencode the integer
let encodedInteger = uint.encode()
precondition(encoded == encodedInteger)
```


## Support for `Decode`/`Encode`
Support for Swift's `Decode` and `Encode` protocols is not implemented yet but on my roadmap and will come eventually 😅
