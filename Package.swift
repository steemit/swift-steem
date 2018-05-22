// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "Steem",
    products: [
        .library(name: "Steem", targets: ["Steem"]),
    ],
    dependencies: [.package(url: "https://github.com/steemit/swift-secp256k1.git", from: "1.1.0")],
    targets: [
        .target(
            name: "Steem",
            dependencies: []
        ),
        .testTarget(
            name: "SteemTests",
            dependencies: ["Steem"]
        ),
        .testTarget(
            name: "SteemIntegrationTests",
            dependencies: ["Steem"]
        ),
    ]
)
