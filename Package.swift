// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "MockableMacro",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "MockableMacro",
            targets: ["MockableMacro"]
        ),
        .executable(
            name: "MockableMacroClient",
            targets: ["MockableMacroClient"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax", "509.0.0"..<"601.0.0-prerelease"),
        .package(url: "https://github.com/pointfreeco/swift-macro-testing", .upToNextMajor(from: "0.5.2")),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        // Macro implementation that performs the source transformation of a macro.
        .macro(
            name: "MockableMacroMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),

        // Library that exposes a macro as part of its API, which is used in client programs.
        .target(name: "MockableMacro", dependencies: ["MockableMacroMacros"]),

        // A client of the library, which is able to use the macro in its own code.
        .executableTarget(name: "MockableMacroClient", dependencies: ["MockableMacro"]),
        .testTarget(name: "MacroClientTests", dependencies: ["MockableMacroClient"]),

        // A test target used to develop the macro implementation.
        .testTarget(
            name: "MockableMacroTests",
            dependencies: [
                "MockableMacroMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
                .product(name: "MacroTesting", package: "swift-macro-testing"),
            ]
        ),
    ]
)
