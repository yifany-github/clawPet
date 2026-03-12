// swift-tools-version: 5.10
import PackageDescription

let package = Package(
  name: "MacPetWidget",
  platforms: [.macOS(.v13)],
  products: [
    .executable(name: "MacPetWidgetApp", targets: ["MacPetWidgetApp"])
  ],
  targets: [
    .executableTarget(
      name: "MacPetWidgetApp",
      path: "Sources/MacPetWidgetApp"
    )
  ]
)
