// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to
// build this package.

import PackageDescription

let package = Package(
  name: "ua_client_hints",
  platforms: [
    .iOS("12.0"),
  ],
  products: [
    .library(
      name: "ua-client-hints",
      targets: ["ua_client_hints"]
    ),
  ],
  targets: [
    .target(
      name: "ua_client_hints",
      resources: [
        .process("PrivacyInfo.xcprivacy"),
      ]
    ),
  ]
)
