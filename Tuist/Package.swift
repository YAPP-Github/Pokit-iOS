// swift-tools-version: 5.9
import PackageDescription

#if TUIST
    import ProjectDescription
    import ProjectDescriptionHelpers

    let packageSettings = PackageSettings(
        // Customize the product types for specific package product
        // Default is .staticFramework
        // productTypes: ["Alamofire": .framework,]
        productTypes: [
            "GoogleSignIn": .staticFramework,
            "ComposableArchitecture": TuistRelease.isRelease ? .staticFramework : .framework
        ]
    )
#endif

let package = Package(
    name: "Pokit",
    dependencies: [
        // Add your own dependencies here:
        // .package(url: "https://github.com/Alamofire/Alamofire", from: "5.0.0"),
        // You can read more about dependencies here: https://docs.tuist.io/documentation/tuist/dependencies
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.10.4"),
        .package(url: "https://github.com/google/GoogleSignIn-iOS", "7.0.0" ..< "7.1.0"),
        .package(url: "https://github.com/Moya/Moya", from: "15.0.0"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk", "10.28.0" ..< "10.28.1")
    ]
)
