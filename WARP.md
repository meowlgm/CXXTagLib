# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

CXXTagLib is a Swift Package that wraps the [TagLib](https://github.com/taglib/taglib) C++ library for reading/writing audio metadata. It supports 16+ audio formats (MP3, FLAC, M4A, OGG, WAV, etc.) through a unified Swift API.

## Build Commands

```bash
# Build the package
swift build

# Build with verbose output
swift build -v

# Run all tests
swift test

# Run a specific test
swift test --filter TagLibSwiftTests

# Run tests with verbose output
swift test -v
```

## Architecture

The package has a three-layer architecture:

```
TagLibSwift (Swift API) → TagLibBridge (Obj-C++ bridge) → taglib (C++ core)
```

### Layer Details

1. **taglib** (`Sources/taglib/`) - Vendored TagLib C++ library with format-specific implementations (MP3/ID3, FLAC, MP4, Ogg, etc.)

2. **TagLibBridge** (`Sources/TagLibBridge/`) - Objective-C++ bridge layer exposing C++ functionality to Swift:
   - `TagLibBridge.h` - Public interface with `TagLibBridge`, `TLPicture`, `TLAudioProperties` classes
   - `TagLibBridge.mm` - Implementation calling TagLib C++ APIs

3. **TagLibSwift** (`Sources/TagLibSwift/`) - Swift wrapper providing idiomatic API:
   - `AudioFile.swift` - Main class with properties for tags, audio properties, and generic property access
   - `AudioFile+Picture.swift` - Extension for artwork/cover image operations

### Key Types

- `AudioFile` - Main entry point for opening and manipulating audio files
- `Picture` / `PictureType` - Album artwork handling
- `AudioProperties` - Read-only audio metadata (duration, bitrate, sample rate, channels)
- `TagSource` - Enum for targeting specific tag formats (ID3v2, APE, Vorbis Comment, etc.)

## Platform Support

- macOS 10.15+
- iOS 13+
- tvOS 13+
- watchOS 6+

## Development Notes

- C++17 is required (`cxxLanguageStandard: .cxx17` in Package.swift)
- When modifying the bridge layer, changes must be made in both `.h` (interface) and `.mm` (implementation)
- Tag operations require calling `save()` to persist changes to files
- Tests require audio files in `~/Documents/测试音频/` - they won't pass in CI without test fixtures
