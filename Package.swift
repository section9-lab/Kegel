// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "kegel",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "Kegel", targets: ["Kegel"])
    ],
    targets: [
        .executableTarget(
            name: "Kegel",
            path: "Sources/Kegel",
            linkerSettings: [
                .unsafeFlags([
                    "-Xlinker", "-sectcreate", "-Xlinker", "__TEXT", "-Xlinker", "__info_plist", "-Xlinker", "App/Info.plist"
                ])
            ]
        )
    ]
)
