import Foundation
import TagLibBridge

/// Swift-friendly wrapper for TagLib audio file operations (uses C++ API via bridge)
public final class AudioFile {
    /// Bridge instance for all TagLib operations
    let bridge: TagLibBridge
    let path: String
    
    /// Initialize with a file path
    /// - Parameter path: Path to the audio file
    /// - Throws: AudioFileError if the file cannot be opened or is invalid
    public init(path: String) throws {
        self.path = path
        guard let bridge = TagLibBridge(path: path) else {
            throw AudioFileError.fileNotFound(path)
        }
        guard bridge.isValid else {
            throw AudioFileError.invalidFile(path)
        }
        self.bridge = bridge
    }
    
    /// Access the bridge instance (for picture operations)
    var pictureBridge: TagLibBridge? {
        return bridge
    }
    
    // MARK: - Audio Properties
    
    /// Audio properties (duration, bitrate, etc.)
    public var audioProperties: AudioProperties? {
        guard let props = bridge.audioProperties else { return nil }
        return AudioProperties(
            duration: Int(props.duration),
            bitrate: Int(props.bitrate),
            sampleRate: Int(props.sampleRate),
            channels: Int(props.channels)
        )
    }
    
    // MARK: - Basic Tags
    
    /// Track title
    public var title: String? {
        get { bridge.title?.isEmpty == false ? bridge.title : nil }
        set { bridge.title = newValue }
    }
    
    /// Artist name
    public var artist: String? {
        get { bridge.artist?.isEmpty == false ? bridge.artist : nil }
        set { bridge.artist = newValue }
    }
    
    /// Album name
    public var album: String? {
        get { bridge.album?.isEmpty == false ? bridge.album : nil }
        set { bridge.album = newValue }
    }
    
    /// Comment
    public var comment: String? {
        get { bridge.comment?.isEmpty == false ? bridge.comment : nil }
        set { bridge.comment = newValue }
    }
    
    /// Genre
    public var genre: String? {
        get { bridge.genre?.isEmpty == false ? bridge.genre : nil }
        set { bridge.genre = newValue }
    }
    
    /// Year or date (e.g. "2024" or "2024-01-15")
    public var year: String? {
        get { bridge.year?.isEmpty == false ? bridge.year : nil }
        set { bridge.year = newValue }
    }
    
    /// Track number (e.g. "1" or "1/12")
    public var track: String? {
        get { bridge.track?.isEmpty == false ? bridge.track : nil }
        set { bridge.track = newValue }
    }
    
    // MARK: - Extended Tags (via PropertyMap)
    
    /// Album artist
    public var albumArtist: String? {
        get { getProperty("ALBUMARTIST") }
        set { setProperty("ALBUMARTIST", value: newValue) }
    }
    
    /// Subtitle
    public var subtitle: String? {
        get { getProperty("SUBTITLE") }
        set { setProperty("SUBTITLE", value: newValue) }
    }
    
    /// Disc number (e.g. "1" or "1/2")
    public var discNumber: String? {
        get { getProperty("DISCNUMBER") }
        set { setProperty("DISCNUMBER", value: newValue) }
    }
    
    /// Release date
    public var date: String? {
        get { getProperty("DATE") }
        set { setProperty("DATE", value: newValue) }
    }
    
    /// Original release date
    public var originalDate: String? {
        get { getProperty("ORIGINALDATE") }
        set { setProperty("ORIGINALDATE", value: newValue) }
    }
    
    // MARK: - Sort Names
    
    /// Title for sorting
    public var titleSort: String? {
        get { getProperty("TITLESORT") }
        set { setProperty("TITLESORT", value: newValue) }
    }
    
    /// Album name for sorting
    public var albumSort: String? {
        get { getProperty("ALBUMSORT") }
        set { setProperty("ALBUMSORT", value: newValue) }
    }
    
    /// Artist name for sorting
    public var artistSort: String? {
        get { getProperty("ARTISTSORT") }
        set { setProperty("ARTISTSORT", value: newValue) }
    }
    
    /// Album artist for sorting
    public var albumArtistSort: String? {
        get { getProperty("ALBUMARTISTSORT") }
        set { setProperty("ALBUMARTISTSORT", value: newValue) }
    }
    
    /// Composer for sorting
    public var composerSort: String? {
        get { getProperty("COMPOSERSORT") }
        set { setProperty("COMPOSERSORT", value: newValue) }
    }
    
    // MARK: - Credits
    
    /// Composer
    public var composer: String? {
        get { getProperty("COMPOSER") }
        set { setProperty("COMPOSER", value: newValue) }
    }
    
    /// Lyricist
    public var lyricist: String? {
        get { getProperty("LYRICIST") }
        set { setProperty("LYRICIST", value: newValue) }
    }
    
    /// Conductor
    public var conductor: String? {
        get { getProperty("CONDUCTOR") }
        set { setProperty("CONDUCTOR", value: newValue) }
    }
    
    /// Remixer
    public var remixer: String? {
        get { getProperty("REMIXER") }
        set { setProperty("REMIXER", value: newValue) }
    }
    
    /// Get performer for a specific instrument/role
    public func performer(for instrument: String) -> String? {
        return getProperty("PERFORMER:\(instrument.uppercased())")
    }
    
    /// Set performer for a specific instrument/role
    public func setPerformer(_ name: String?, for instrument: String) {
        setProperty("PERFORMER:\(instrument.uppercased())", value: name)
    }
    
    /// Get all performers with their instruments
    public func allPerformers() -> [String: String] {
        var result: [String: String] = [:]
        for key in allPropertyKeys() {
            if key.hasPrefix("PERFORMER:") {
                let instrument = String(key.dropFirst("PERFORMER:".count))
                if let value = getProperty(key) {
                    result[instrument] = value
                }
            }
        }
        return result
    }
    
    // MARK: - Other Tags
    
    /// ISRC (International Standard Recording Code)
    public var isrc: String? {
        get { getProperty("ISRC") }
        set { setProperty("ISRC", value: newValue) }
    }
    
    /// ASIN (Amazon Standard Identification Number)
    public var asin: String? {
        get { getProperty("ASIN") }
        set { setProperty("ASIN", value: newValue) }
    }
    
    /// BPM (Beats Per Minute)
    public var bpm: Int? {
        get { getProperty("BPM").flatMap { Int($0) } }
        set { setProperty("BPM", value: newValue.map { String($0) }) }
    }
    
    /// Copyright information
    public var copyright: String? {
        get { getProperty("COPYRIGHT") }
        set { setProperty("COPYRIGHT", value: newValue) }
    }
    
    /// Encoded by
    public var encodedBy: String? {
        get { getProperty("ENCODEDBY") }
        set { setProperty("ENCODEDBY", value: newValue) }
    }
    
    /// Mood
    public var mood: String? {
        get { getProperty("MOOD") }
        set { setProperty("MOOD", value: newValue) }
    }
    
    /// Media type
    public var media: String? {
        get { getProperty("MEDIA") }
        set { setProperty("MEDIA", value: newValue) }
    }
    
    /// Record label
    public var label: String? {
        get { getProperty("LABEL") }
        set { setProperty("LABEL", value: newValue) }
    }
    
    /// Catalog number
    public var catalogNumber: String? {
        get { getProperty("CATALOGNUMBER") }
        set { setProperty("CATALOGNUMBER", value: newValue) }
    }
    
    /// Barcode
    public var barcode: String? {
        get { getProperty("BARCODE") }
        set { setProperty("BARCODE", value: newValue) }
    }
    
    /// Release country
    public var releaseCountry: String? {
        get { getProperty("RELEASECOUNTRY") }
        set { setProperty("RELEASECOUNTRY", value: newValue) }
    }
    
    /// Release status
    public var releaseStatus: String? {
        get { getProperty("RELEASESTATUS") }
        set { setProperty("RELEASESTATUS", value: newValue) }
    }
    
    /// Release type
    public var releaseType: String? {
        get { getProperty("RELEASETYPE") }
        set { setProperty("RELEASETYPE", value: newValue) }
    }
    
    // MARK: - MusicBrainz IDs
    
    /// MusicBrainz Track ID
    public var musicBrainzTrackId: String? {
        get { getProperty("MUSICBRAINZ_TRACKID") }
        set { setProperty("MUSICBRAINZ_TRACKID", value: newValue) }
    }
    
    /// MusicBrainz Album ID
    public var musicBrainzAlbumId: String? {
        get { getProperty("MUSICBRAINZ_ALBUMID") }
        set { setProperty("MUSICBRAINZ_ALBUMID", value: newValue) }
    }
    
    /// MusicBrainz Release Group ID
    public var musicBrainzReleaseGroupId: String? {
        get { getProperty("MUSICBRAINZ_RELEASEGROUPID") }
        set { setProperty("MUSICBRAINZ_RELEASEGROUPID", value: newValue) }
    }
    
    /// MusicBrainz Release Track ID
    public var musicBrainzReleaseTrackId: String? {
        get { getProperty("MUSICBRAINZ_RELEASETRACKID") }
        set { setProperty("MUSICBRAINZ_RELEASETRACKID", value: newValue) }
    }
    
    /// MusicBrainz Work ID
    public var musicBrainzWorkId: String? {
        get { getProperty("MUSICBRAINZ_WORKID") }
        set { setProperty("MUSICBRAINZ_WORKID", value: newValue) }
    }
    
    /// MusicBrainz Artist ID
    public var musicBrainzArtistId: String? {
        get { getProperty("MUSICBRAINZ_ARTISTID") }
        set { setProperty("MUSICBRAINZ_ARTISTID", value: newValue) }
    }
    
    /// MusicBrainz Album Artist ID
    public var musicBrainzAlbumArtistId: String? {
        get { getProperty("MUSICBRAINZ_ALBUMARTISTID") }
        set { setProperty("MUSICBRAINZ_ALBUMARTISTID", value: newValue) }
    }
    
    /// AcoustID
    public var acoustId: String? {
        get { getProperty("ACOUSTID_ID") }
        set { setProperty("ACOUSTID_ID", value: newValue) }
    }
    
    /// AcoustID Fingerprint
    public var acoustIdFingerprint: String? {
        get { getProperty("ACOUSTID_FINGERPRINT") }
        set { setProperty("ACOUSTID_FINGERPRINT", value: newValue) }
    }
    
    /// MusicIP PUID
    public var musicIpPuid: String? {
        get { getProperty("MUSICIP_PUID") }
        set { setProperty("MUSICIP_PUID", value: newValue) }
    }
    
    // MARK: - Generic Property Access
    
    /// Get a property value by key
    public func getProperty(_ key: String) -> String? {
        let value = bridge.property(forKey: key)
        return value?.isEmpty == false ? value : nil
    }
    
    /// Set a property value
    public func setProperty(_ key: String, value: String?) {
        bridge.setProperty(value, forKey: key)
    }
    
    /// Get all property keys present in the file
    public func allPropertyKeys() -> [String] {
        return bridge.allPropertyKeys()
    }
    
    /// Get all properties as a dictionary (merged, duplicates overwritten)
    public func allProperties() -> [String: String] {
        var result: [String: String] = [:]
        for key in allPropertyKeys() {
            if let value = getProperty(key) {
                result[key] = value
            }
        }
        return result
    }
    
    /// Raw property entry with source information
    public struct RawProperty {
        public let source: String  // "ID3v2", "ID3v1", "Default", etc.
        public let key: String
        public let value: String
    }
    
    /// Get all properties including duplicates from different tag sources
    public func allPropertiesRaw() -> [RawProperty] {
        let rawArray = bridge.allPropertiesRaw()
        return rawArray.compactMap { dict in
            guard let source = dict["source"],
                  let key = dict["key"],
                  let value = dict["value"] else { return nil }
            return RawProperty(source: source, key: key, value: value)
        }
    }
    
    /// Remove all tags from the file (ID3v1, ID3v2, APE, Xiph, etc.)
    /// Note: You must call save() after this to persist changes
    @discardableResult
    public func removeAllTags() -> Bool {
        return bridge.removeAllTags()
    }
    
    // MARK: - Rating (POPM)
    
    /// Rating value (0-255), nil if not set
    /// Common mappings: 0=unrated, 1=⭐, 64=⭐⭐, 128=⭐⭐⭐, 196=⭐⭐⭐⭐, 255=⭐⭐⭐⭐⭐
    public var rating: Int? {
        get {
            let value = bridge.rating
            return value >= 0 ? Int(value) : nil
        }
        set {
            bridge.setRating(newValue.map { NSInteger($0) } ?? -1)
        }
    }
    
    /// Rating as stars (0-5)
    public var ratingStars: Int? {
        get {
            guard let r = rating else { return nil }
            if r == 0 { return 0 }
            if r < 64 { return 1 }
            if r < 128 { return 2 }
            if r < 196 { return 3 }
            if r < 255 { return 4 }
            return 5
        }
        set {
            guard let stars = newValue else {
                rating = nil
                return
            }
            switch stars {
            case 0: rating = 0
            case 1: rating = 1
            case 2: rating = 64
            case 3: rating = 128
            case 4: rating = 196
            case 5: rating = 255
            default: rating = nil
            }
        }
    }
    
    /// Play count from POPM frame
    public var playCount: UInt {
        get { UInt(bridge.playCount) }
        set { bridge.setPlayCount(newValue) }
    }
    
    // MARK: - Save
    
    /// Save changes to the file
    @discardableResult
    public func save() -> Bool {
        return bridge.save()
    }
}

// MARK: - Supporting Types

/// Audio file properties
public struct AudioProperties: Sendable {
    /// Duration in seconds
    public let duration: Int
    
    /// Bitrate in kb/s
    public let bitrate: Int
    
    /// Sample rate in Hz
    public let sampleRate: Int
    
    /// Number of audio channels
    public let channels: Int
    
    /// Duration as TimeInterval
    public var durationInterval: TimeInterval {
        TimeInterval(duration)
    }
    
    /// Formatted duration string (MM:SS or HH:MM:SS)
    public var formattedDuration: String {
        let hours = duration / 3600
        let minutes = (duration % 3600) / 60
        let seconds = duration % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
}

/// Errors that can occur when working with audio files
public enum AudioFileError: Error, LocalizedError {
    case fileNotFound(String)
    case invalidFile(String)
    case saveFailed(String)
    
    public var errorDescription: String? {
        switch self {
        case .fileNotFound(let path):
            return "File not found: \(path)"
        case .invalidFile(let path):
            return "Invalid or unsupported audio file: \(path)"
        case .saveFailed(let path):
            return "Failed to save changes to: \(path)"
        }
    }
}
