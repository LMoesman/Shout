// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "Shout",
    platforms: [
        .macOS(.v10_12)
    ],
    products: [
        .library(name: "Shout", targets: ["Shout"]),
    ],
    dependencies: [
        .package(url: "https://github.com/lmoesman/BlueSocket", from: "2.0.3"),
    ],
    targets: [
        .binaryTarget(
            name: "libssh2",
            path: "Libs/libssh2.xcframework"
        ),
        .binaryTarget(
            name: "openssl",
            path: "Libs/openssl.xcframework"
        ),
        .target(
            name: "Shout",
            dependencies: [
                "libssh2",
                "openssl",
                .product(name: "Socket", package: "BlueSocket")
            ],
            exclude: [
                "Scripts/libssh2-generate-framework.sh",
                "Resources/libssh2"
            ]
        ),
        .testTarget(name: "ShoutTests", dependencies: ["Shout"]),
    ]
)
