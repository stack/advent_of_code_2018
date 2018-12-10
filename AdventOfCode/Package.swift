// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AdventOfCode",
    dependencies: [],
    targets: [
        .target(
            name: "01",
            dependencies: ["Utilities"]),
        .target(
            name: "02",
            dependencies: ["Utilities"]),
        .target(
            name: "03",
            dependencies: ["Utilities"]),
        .target(
            name: "04",
            dependencies: ["Utilities"]),
        .target(
            name: "05",
            dependencies: ["Utilities"]),
        .target(
            name: "06",
            dependencies: ["Utilities"]),
        .target(
            name: "07",
            dependencies: ["Utilities"]),
        .target(
            name: "08",
            dependencies: ["Utilities"]),
        .target(
            name: "09",
            dependencies: ["Utilities"]),
        .target(
            name: "10",
            dependencies: ["Utilities"]),
        .target(name: "Utilities"),
        .testTarget(
            name: "UtilitiesTests",
            dependencies: ["Utilities"]),
    ]
)
