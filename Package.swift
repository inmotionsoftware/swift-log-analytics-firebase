// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-log-analytics-firebase",
    platforms: [
            .iOS(.v10)
        ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "LoggingAnalyticsFirebase",
            targets: ["LoggingAnalyticsFirebase"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
        .package(name: "Firebase",
                 url: "https://github.com/firebase/firebase-ios-sdk.git",
                 .branch("6.34-spm-beta")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "LoggingAnalyticsFirebase",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
                .product(name: "FirebaseAnalytics", package: "Firebase"),
                .product(name: "FirebaseCrashlytics", package: "Firebase"),
            ]),
        .testTarget(
            name: "LoggingAnalyticsFirebaseTests",
            dependencies: [
                "LoggingAnalyticsFirebase",
                .product(name: "Logging", package: "swift-log")
            ]),
    ]
)
