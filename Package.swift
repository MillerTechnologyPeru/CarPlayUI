// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "CarPlayUI",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "CarPlayUI",
            targets: ["CarPlayUI"]
        )
    ],
    targets: [
        .target(
            name: "CarPlayUI",
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        ),
        .testTarget(
            name: "CarPlayUITests",
            dependencies: ["CarPlayUI"],
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        )
    ]
)
