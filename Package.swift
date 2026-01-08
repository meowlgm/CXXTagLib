// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "CXXTagLib",
	platforms: [
		.macOS(.v10_15),
		.iOS(.v13),
		.tvOS(.v13),
		.watchOS(.v6),
	],
	products: [
		// Dynamic library for LGPL-2.1 compliance
		// TagLib is LGPL licensed, dynamic linking allows closed-source apps to use it
		.library(
			name: "TagLibSwift",
			type: .dynamic,
			targets: [
				"TagLibSwift",
			]),
	],
	targets: [
		// Targets are the basic building blocks of a package, defining a module or a test suite.
		// Targets can depend on other targets in this package and products from dependencies.
		.target(
			name: "taglib",
			cxxSettings: [
				.headerSearchPath("include/taglib"),
				.headerSearchPath("utfcpp/source"),
				.headerSearchPath("."),
				.headerSearchPath("mod"),
				.headerSearchPath("riff"),
				.headerSearchPath("toolkit"),
			]),
		.target(
			name: "TagLibBridge",
			dependencies: [
				"taglib",
			],
			publicHeadersPath: "include",
			cxxSettings: [
				.headerSearchPath("../taglib/include/taglib"),
			]),
		.target(
			name: "TagLibSwift",
			dependencies: [
				"taglib",
				"TagLibBridge",
			]),
		.testTarget(
			name: "CXXTagLibTests",
			dependencies: [
				"taglib",
			]),
		.testTarget(
			name: "TagLibSwiftTests",
			dependencies: [
				"TagLibSwift",
			]),
	],
	cxxLanguageStandard: .cxx17
)
