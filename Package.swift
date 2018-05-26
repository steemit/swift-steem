// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "Steem",
    products: [
        .library(name: "Steem", targets: ["Steem"]),
    ],
    dependencies: [
        .package(url: "https://github.com/steemit/swift-secp256k1.git", from: "1.1.0"),
        .package(url: "https://github.com/Flight-School/AnyCodable.git", .revision("396ccc3dba5bdee04c1e742e7fab40582861401e")),
    ],
    targets: [
        .target(
            name: "Crypto",
            dependencies: []
        ),
        .target(
            name: "Steem",
            dependencies: ["Crypto", "AnyCodable"]
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
