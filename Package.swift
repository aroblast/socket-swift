// swift-tools-version:5.3

import PackageDescription

let package = Package(
	name: "Socket",
	products: [
		.library(
			name: "Socket",
			targets: ["Socket"]),
	],
	dependencies: [],
	targets: [
		.target(
			name: "Socket",
			dependencies: []),
		.testTarget(
			name: "SocketTests",
			dependencies: ["Socket"]),
	]
)
