// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AdventOfCode",
    dependencies: [
        .package(path: "../Animator"),
        .package(path: "../Canvas"),
        .package(path: "../ColorGenerator"),
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
        .target(
            name: "04",
            dependencies: ["Canvas", "LineReader"]),
        .target(
            name: "05",
            dependencies: ["LineReader"]),
        .target(
            name: "06",
            dependencies: ["Animator", "Canvas", "ColorGenerator", "LineReader"]),
        .target(
            name: "07",
            dependencies: ["LineReader"]),
        .target(
            name: "08",
            dependencies: ["LineReader"]),
        .target(
            name: "09",
            dependencies: []),
    ]
)
