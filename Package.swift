// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "swiftcn",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(name: "swiftcn", targets: ["swiftcn"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.3.0")
    ],
    targets: [
        .executableTarget(
            name: "swiftcn",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        )
    ]
)
