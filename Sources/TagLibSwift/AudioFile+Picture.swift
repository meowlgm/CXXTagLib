import Foundation
import TagLibBridge

// MARK: - Picture Type Enum

/// Standard picture types defined by ID3v2 specification
public enum PictureType: String, CaseIterable, Sendable {
    case other = "Other"
    case fileIcon = "File Icon"
    case otherFileIcon = "Other File Icon"
    case frontCover = "Front Cover"
    case backCover = "Back Cover"
    case leafletPage = "Leaflet Page"
    case media = "Media"
    case leadArtist = "Lead Artist"
    case artist = "Artist"
    case conductor = "Conductor"
    case band = "Band"
    case composer = "Composer"
    case lyricist = "Lyricist"
    case recordingLocation = "Recording Location"
    case duringRecording = "During Recording"
    case duringPerformance = "During Performance"
    case movieScreenCapture = "Movie Screen Capture"
    case colouredFish = "Coloured Fish"  // Yes, this is real in the ID3v2 spec!
    case illustration = "Illustration"
    case bandLogo = "Band Logo"
    case publisherLogo = "Publisher Logo"
    
    /// Create from raw string (for custom types)
    public init(rawString: String) {
        self = PictureType(rawValue: rawString) ?? .other
    }
}

// MARK: - Picture/Artwork Support

extension AudioFile {
    
    /// Picture/artwork embedded in the audio file
    public struct Picture {
        /// Raw image data
        public let data: Data
        
        /// MIME type (e.g., "image/jpeg", "image/png")
        public let mimeType: String
        
        /// Description
        public let description: String
        
        /// Picture type as string (e.g., "Front Cover", "Back Cover")
        public let pictureTypeString: String
        
        /// Picture type as enum (returns .other for unrecognized types)
        public var pictureType: PictureType {
            PictureType(rawValue: pictureTypeString) ?? .other
        }
        
        public init(data: Data, mimeType: String, description: String = "", pictureType: PictureType = .frontCover) {
            self.data = data
            self.mimeType = mimeType
            self.description = description
            self.pictureTypeString = pictureType.rawValue
        }
        
        public init(data: Data, mimeType: String, description: String = "", pictureTypeString: String) {
            self.data = data
            self.mimeType = mimeType
            self.description = description
            self.pictureTypeString = pictureTypeString
        }
    }
    
    /// Get the first embedded picture/artwork
    public var artwork: Picture? {
        return pictures.first
    }
    
    /// Get all embedded pictures (uses C++ API for full support)
    public var pictures: [Picture] {
        return bridge.pictures().map { tlPic in
            Picture(
                data: tlPic.data,
                mimeType: tlPic.mimeType,
                description: tlPic.pictureDescription,
                pictureTypeString: tlPic.pictureType
            )
        }
    }
    
    /// Get picture count
    public var pictureCount: Int {
        return bridge.pictureCount()
    }
    
    /// Set the artwork/cover image using enum type (replaces all existing)
    /// - Parameters:
    ///   - data: Image data
    ///   - mimeType: MIME type (default: "image/jpeg")
    ///   - description: Optional description
    ///   - pictureType: Picture type enum (default: .frontCover)
    /// - Returns: true if successful
    @discardableResult
    public func setArtwork(
        data: Data,
        mimeType: String = "image/jpeg",
        description: String = "",
        pictureType: PictureType = .frontCover
    ) -> Bool {
        return setArtwork(data: data, mimeType: mimeType, description: description, pictureTypeString: pictureType.rawValue)
    }
    
    /// Set the artwork/cover image using custom string type (replaces all existing, uses C++ API)
    /// - Parameters:
    ///   - data: Image data
    ///   - mimeType: MIME type (default: "image/jpeg")
    ///   - description: Optional description
    ///   - pictureTypeString: Picture type as string (for custom types)
    /// - Returns: true if successful
    @discardableResult
    public func setArtwork(
        data: Data,
        mimeType: String = "image/jpeg",
        description: String = "",
        pictureTypeString: String
    ) -> Bool {
        // Remove all existing pictures first
        _ = bridge.removeAllPictures()
        
        // Add the new picture
        let tlPic = TLPicture(
            data: data,
            mimeType: mimeType,
            description: description,
            pictureType: pictureTypeString
        )
        
        return bridge.addPicture(tlPic)
    }
    
    /// Set artwork from a file using enum type
    /// - Parameters:
    ///   - url: URL to the image file
    ///   - mimeType: MIME type of the image
    ///   - description: Optional description
    ///   - pictureType: Picture type enum (default: .frontCover)
    /// - Returns: true if successful
    @discardableResult
    public func setArtwork(
        from url: URL,
        mimeType: String,
        description: String = "",
        pictureType: PictureType = .frontCover
    ) -> Bool {
        guard let data = try? Data(contentsOf: url) else { return false }
        return setArtwork(data: data, mimeType: mimeType, description: description, pictureType: pictureType)
    }
    
    /// Set artwork from a file using custom string type
    /// - Parameters:
    ///   - url: URL to the image file
    ///   - mimeType: MIME type of the image
    ///   - description: Optional description
    ///   - pictureTypeString: Picture type as string (for custom types)
    /// - Returns: true if successful
    @discardableResult
    public func setArtwork(
        from url: URL,
        mimeType: String,
        description: String = "",
        pictureTypeString: String
    ) -> Bool {
        guard let data = try? Data(contentsOf: url) else { return false }
        return setArtwork(data: data, mimeType: mimeType, description: description, pictureTypeString: pictureTypeString)
    }
    
    /// Add/append artwork using enum type (keeps existing pictures, uses C++ API)
    /// - Parameters:
    ///   - data: Image data
    ///   - mimeType: MIME type (default: "image/jpeg")
    ///   - description: Optional description
    ///   - pictureType: Picture type enum (default: .frontCover)
    /// - Returns: true if successful
    @discardableResult
    public func addArtwork(
        data: Data,
        mimeType: String = "image/jpeg",
        description: String = "",
        pictureType: PictureType = .frontCover
    ) -> Bool {
        return addArtwork(data: data, mimeType: mimeType, description: description, pictureTypeString: pictureType.rawValue)
    }
    
    /// Add/append artwork using custom string type (keeps existing pictures, uses C++ API)
    /// - Parameters:
    ///   - data: Image data
    ///   - mimeType: MIME type (default: "image/jpeg")
    ///   - description: Optional description
    ///   - pictureTypeString: Picture type as string (for custom types)
    /// - Returns: true if successful
    @discardableResult
    public func addArtwork(
        data: Data,
        mimeType: String = "image/jpeg",
        description: String = "",
        pictureTypeString: String
    ) -> Bool {
        let tlPic = TLPicture(
            data: data,
            mimeType: mimeType,
            description: description,
            pictureType: pictureTypeString
        )
        
        return bridge.addPicture(tlPic)
    }
    
    /// Add/append artwork from a file using enum type (keeps existing pictures)
    /// - Parameters:
    ///   - url: URL to the image file
    ///   - mimeType: MIME type of the image
    ///   - description: Optional description
    ///   - pictureType: Picture type enum (default: .frontCover)
    /// - Returns: true if successful
    @discardableResult
    public func addArtwork(
        from url: URL,
        mimeType: String,
        description: String = "",
        pictureType: PictureType = .frontCover
    ) -> Bool {
        guard let data = try? Data(contentsOf: url) else { return false }
        return addArtwork(data: data, mimeType: mimeType, description: description, pictureType: pictureType)
    }
    
    /// Add/append artwork from a file using custom string type (keeps existing pictures)
    /// - Parameters:
    ///   - url: URL to the image file
    ///   - mimeType: MIME type of the image
    ///   - description: Optional description
    ///   - pictureTypeString: Picture type as string (for custom types)
    /// - Returns: true if successful
    @discardableResult
    public func addArtwork(
        from url: URL,
        mimeType: String,
        description: String = "",
        pictureTypeString: String
    ) -> Bool {
        guard let data = try? Data(contentsOf: url) else { return false }
        return addArtwork(data: data, mimeType: mimeType, description: description, pictureTypeString: pictureTypeString)
    }
    
    /// Remove all artwork (uses C++ API)
    /// - Returns: true if successful
    @discardableResult
    public func removeAllArtwork() -> Bool {
        return bridge.removeAllPictures()
    }
    
    /// Remove artwork at specific index (uses C++ API for precise operation)
    /// - Parameter index: Index of the artwork to remove
    /// - Returns: true if successful
    @discardableResult
    public func removeArtwork(at index: Int) -> Bool {
        return bridge.removePicture(at: index)
    }
    
    /// Remove artwork by picture type (uses C++ API)
    /// - Parameter pictureType: Type of picture to remove
    /// - Returns: Number of pictures removed
    @discardableResult
    public func removeArtwork(ofType pictureType: PictureType) -> Int {
        return removeArtwork(ofTypeString: pictureType.rawValue)
    }
    
    /// Remove artwork by picture type string (uses C++ API)
    /// - Parameter typeString: Type string of picture to remove
    /// - Returns: Number of pictures removed
    @discardableResult
    public func removeArtwork(ofTypeString typeString: String) -> Int {
        return bridge.removePictures(ofType: typeString)
    }
    
    /// Replace artwork at specific index (uses C++ API)
    /// - Parameters:
    ///   - index: Index of artwork to replace
    ///   - picture: New picture
    /// - Returns: true if successful
    @discardableResult
    public func replaceArtwork(at index: Int, with picture: Picture) -> Bool {
        let tlPic = TLPicture(
            data: picture.data,
            mimeType: picture.mimeType,
            description: picture.description,
            pictureType: picture.pictureTypeString
        )
        
        return bridge.replacePicture(at: index, with: tlPic)
    }
    
    /// Replace all pictures with new array
    /// - Parameter newPictures: Array of pictures to set
    /// - Returns: true if successful
    @discardableResult
    public func replacePictures(with newPictures: [Picture]) -> Bool {
        // Clear all existing
        _ = bridge.removeAllPictures()
        
        // Add new pictures
        for picture in newPictures {
            let tlPic = TLPicture(
                data: picture.data,
                mimeType: picture.mimeType,
                description: picture.description,
                pictureType: picture.pictureTypeString
            )
            if !bridge.addPicture(tlPic) { return false }
        }
        
        return bridge.save()
    }
}
