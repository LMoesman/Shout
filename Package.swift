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
        .systemLibrary(name: "CSSH", pkgConfig: "libssh2", providers: [.brew(["libssh2","openssl"])]),
        .target(
            name: "Shout",
            dependencies: [
                "CSSH",
                .product(name: "Socket", package: "BlueSocket")
            ]
        ),
        .testTarget(name: "ShoutTests", dependencies: ["Shout"]),
    ]
)
