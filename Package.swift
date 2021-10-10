// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "BigSyncKit",
    platforms: [
        .macOS(.v10_12),
        .iOS(.v11),
        .tvOS(.v11),
        .watchOS(.v3)
    ],
    products: [
        .library(name: "BigSyncKit/RealmSwift", targets: ["BigSyncKit/RealmSwift"])],
    dependencies: [
        .package(url: "https://github.com/realm/realm-cocoa", from: "10.7.7")
    ],
    targets: [
        .target(
            name: "BigSyncKit/RealmSwift",
            dependencies: ["RealmSwift", "Realm"],
            path: ".",
            sources: ["BigSyncKit/RealmSwift"]
        )
    ],
    swiftLanguageVersions: [.v5]
)
