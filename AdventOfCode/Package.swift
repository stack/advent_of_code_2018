// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AdventOfCode",
    dependencies: [
        .package(path: "../LineReader"),
    ],
    targets: [
        .target(
            name: "01",
            dependencies: ["LineReader"]),
        .target(
            name: "02",
            dependencies: ["LineReader"]),
        .target(
            name: "03",
            dependencies: ["LineReader"]),
    ]
)
