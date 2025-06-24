// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FoodExpire",
    defaultLocalization: "ja",
    platforms: [
        .iOS("17.0")
    ],
    products: [
        .executable(
            name: "FoodExpire",
            targets: ["FoodExpire"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "10.15.0"),
        .package(url: "https://github.com/google/GoogleMLKit.git", from: "3.2.0"),
        .package(url: "https://github.com/googleads/swift-package-manager-google-mobile-ads.git", from: "10.13.0")
    ],
    targets: [
        .executableTarget(
            name: "FoodExpire",
            dependencies: [
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
                .product(name: "MLKitTextRecognition", package: "GoogleMLKit"),
                .product(name: "GoogleMobileAds", package: "swift-package-manager-google-mobile-ads")
            ],
            resources: [
                .process("Resources")
            ]
        )
    ]
)
