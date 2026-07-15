// swift-tools-version: 6.2
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
                .swiftLanguageMode(.v6),
                .enableUpcomingFeature("InferIsolatedConformances"),
                .enableUpcomingFeature("NonisolatedNonsendingByDefault")
            ]
        ),
        .testTarget(
            name: "CarPlayUITests",
            dependencies: ["CarPlayUI"],
            swiftSettings: [
                .swiftLanguageMode(.v6),
                .enableUpcomingFeature("InferIsolatedConformances"),
                .enableUpcomingFeature("NonisolatedNonsendingByDefault")
            ]
        )
    ]
)
