// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "SwiftterAPI",
    platforms: [
        .macOS(.v15)
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.110.1"),
        // 🗄 An ORM for SQL and NoSQL databases.
        .package(url: "https://github.com/vapor/fluent.git", from: "4.9.0"),
        // 🐘 Fluent driver for Postgres.
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.8.0"),
        // 🔵 Non-blocking, event-driven networking for Swift. Used for custom executors
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.65.0"),
        .package(url: "https://github.com/vapor/jwt.git", from: "5.0.0")
    ],
    targets: [
        .executableTarget(
            name: "SwiftterAPI",
            dependencies: [
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
                .product(name: "Vapor", package: "vapor"),
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOPosix", package: "swift-nio"),
                .product(name: "JWT", package: "jwt")
            ],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "SwiftterAPITests",
            dependencies: [
                .target(name: "SwiftterAPI"),
                .product(name: "VaporTesting", package: "vapor"),
            ],
            swiftSettings: swiftSettings
        )
    ],
    swiftLanguageModes: [.v6]
)

var swiftSettings: [SwiftSetting] { [
    .enableUpcomingFeature("ExistentialAny"),
] }
