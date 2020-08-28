// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Asn1Der",
    products: [
        .library(
            name: "Asn1Der",
            targets: ["Asn1Der"])
    ],
    targets: [
        .target(
            name: "Asn1Der",
            dependencies: []),
        .testTarget(
            name: "Asn1DerTests",
            dependencies: ["Asn1Der"])
    ]
)
