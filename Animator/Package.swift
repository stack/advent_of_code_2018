// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Animator",
    products: [
        .library(
            name: "Animator",
            targets: ["Animator"]),
    ],
    dependencies: [
        .package(path: "../Canvas"),
    ],
    targets: [
        .target(
            name: "Animator",
            dependencies: ["Canvas"]),
        .testTarget(
            name: "AnimatorTests",
            dependencies: ["Animator"]),
    ]
)
