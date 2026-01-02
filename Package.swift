// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "SwiftACP",
  platforms: [
    .macOS(.v14),
    .iOS(.v17),
    .tvOS(.v17),
    .watchOS(.v10),
  ],
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(
      name: "SwiftACP",
      targets: ["SwiftACP"]
    ),
    .executable(
      name: "ACPClientExample",
      targets: ["ACPClientExample"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/luosheng/StreamTransport.git", branch: "main")
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "SwiftACP",
      dependencies: [
        .product(name: "StreamTransportCore", package: "StreamTransport"),
        .product(name: "StreamTransportClient", package: "StreamTransport"),
      ]
    ),
    .executableTarget(
      name: "ACPClientExample",
      dependencies: [
        "SwiftACP",
        .product(name: "StreamTransportClient", package: "StreamTransport"),
      ]
    ),
    .testTarget(
      name: "SwiftACPTests",
      dependencies: ["SwiftACP"]
    ),
  ]
)
