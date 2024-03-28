// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DataProcessFlow",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "DataProcessFlow",
            targets: ["DataProcessFlow"]),
    ],
    dependencies: [
//        .package(url: "https://github.com/realm/SwiftLint.git", .upToNextMajor(from: "0.54.0")),
        .package(url: "https://github.com/square/Valet.git", .upToNextMajor(from: "4.2.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "DataProcessFlow",
            dependencies: [
                "Valet"
            ]
//            plugins: [
//                .plugin(name: "SwiftLintPlugin", package: "SwiftLint")
//            ]
        ),
        .testTarget(
            name: "DataProcessFlowTests",
            dependencies: ["DataProcessFlow"]),
    ]
)
