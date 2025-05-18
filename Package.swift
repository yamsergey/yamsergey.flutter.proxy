// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "platform_proxy",
    platforms: [
        .iOS(.v9),
        .macOS(.v10_11)
    ],
    products: [
        .library(
            name: "platform_proxy_ios",
            targets: ["platform_proxy_ios"]
        ),
        .library(
            name: "platform_proxy_macos",
            targets: ["platform_proxy_macos"]
        )
    ],
    targets: [
        .target(
            name: "platform_proxy_ios",
            path: "ios/Classes",
            publicHeadersPath: "."
        ),
        .target(
            name: "platform_proxy_macos",
            path: "macos/Classes"
        )
    ]
)
