// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CarPlayUI",
    platforms: [.iOS(.v12)],
    products: [
        .library(
            name: "CarPlayUI",
            targets: ["CarPlayUI"]
        )
    ],
    targets: [
        .target(
            name: "CarPlayUI"
        ),
        .testTarget(
            name: "CarPlayUITests",
            dependencies: ["CarPlayUI"]
        )
    ]
)
