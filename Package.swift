// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CarPlayUI",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "CarPlayUI",
            targets: ["CarPlayUI"]
        )
    ],
    targets: [
        .target(
            name: "CarPlayUI",
            dependencies: [
                "TokamakCore"
            ]
        ),
        .target(
            name: "TokamakCore"
        ),
        .testTarget(
            name: "CarPlayUITests",
            dependencies: ["CarPlayUI"]
        )
    ]
)
