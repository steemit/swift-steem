// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "Steem",
    products: [
        .library(name: "Steem", targets: ["Steem"]),
    ],
    targets: [
        .target(
            name: "Steem",
            dependencies: []),
        .testTarget(
            name: "SteemTests",
            dependencies: ["Steem"]),
        .testTarget(
            name: "SteemIntegrationTests",
            dependencies: ["Steem"]),
    ]
)
