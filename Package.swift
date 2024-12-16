// swift-tools-version:5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NetworkingKit",
    defaultLocalization: "it",
    platforms: [
        .iOS(.v13), .macOS(.v11)
    ],
    products: [
        .library(name: "NetworkingKit", targets: ["NetworkingKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire", .upToNextMajor(from: "5.10.2")),
    ],
    targets: [
        .target(
            name: "NetworkingKit",
            dependencies: [
                .product(name: "Alamofire", package: "Alamofire"),
            ],
            resources: [
              .process("Resources")
            ]
        ),
    ]
)
