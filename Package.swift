// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "rides-ios-sdk",
    defaultLocalization: "en",
    products: [
        .library(
            name: "UberAuth",
            targets: ["UberAuth"]
        ),
        .library(
            name: "UberRides",
            targets: ["UberRides"]
        ),
        .library(
            name: "UberCore",
            targets: ["UberCore"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/AliSoftware/OHHTTPStubs.git",
            exact: .init(stringLiteral: "9.1.0")
        )
    ],
    targets: [
        .target(
            name: "UberAuth",
            dependencies: [
                "UberCore"
            ]
        ),
        .target(
            name: "UberCore",
            resources: [
                .process("Resources")
            ]
        ),
        .target(
            name: "UberRides",
            dependencies: [
                "UberAuth",
                "UberCore",
            ]
        )
    ]
)
