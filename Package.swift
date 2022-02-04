// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SimplePing",
    platforms: [.macOS(.v11), .iOS(.v14)],
    products: [
        .library(
            name: "SimplePing",
            targets: ["SimplePing"])
    ],
    targets: [
        .target(
            name: "SimplePing"
        )
    ],
    swiftLanguageVersions: [.v5]
)
