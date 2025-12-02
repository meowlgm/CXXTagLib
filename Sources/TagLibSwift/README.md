# TagLibSwift

Swift-friendly wrapper for TagLib C API.

## Usage

### Basic Usage

```swift
import TagLibSwift

// Open an audio file
let file = try AudioFile(path: "/path/to/song.mp3")

// Read basic tags
print(file.title ?? "Unknown")
print(file.artist ?? "Unknown")
print(file.album ?? "Unknown")

// Read audio properties
if let props = file.audioProperties {
    print("Duration: \(props.formattedDuration)")
    print("Bitrate: \(props.bitrate) kb/s")
    print("Sample Rate: \(props.sampleRate) Hz")
}

// Modify tags
file.title = "New Title"
file.artist = "New Artist"
file.year = 2024

// Save changes
file.save()
```

### Extended Tags

```swift
// Album artist (for compilations)
file.albumArtist = "Various Artists"

// Disc and track numbers
file.discNumber = 1
file.track = 5

// Sort names (for proper alphabetical sorting)
file.artistSort = "Beatles, The"
file.albumSort = "Abbey Road"

// Credits
file.composer = "John Lennon"
file.lyricist = "Paul McCartney"
file.conductor = "George Martin"

// Other metadata
file.bpm = 120
file.mood = "Happy"
file.copyright = "© 2024 Record Label"
file.label = "Apple Records"

// MusicBrainz IDs
file.musicBrainzTrackId = "..."
file.musicBrainzAlbumId = "..."
```

### Artwork/Cover Images

```swift
// Get artwork
if let artwork = file.artwork {
    let imageData = artwork.data
    let mimeType = artwork.mimeType  // e.g., "image/jpeg"
    // Use imageData to create NSImage/UIImage
}

// Set artwork from Data
let imageData = Data(contentsOf: imageURL)!
file.setArtwork(data: imageData, mimeType: "image/jpeg")

// Set artwork from file URL
file.setArtwork(from: URL(fileURLWithPath: "/path/to/cover.jpg"))

// Remove artwork
file.removeArtwork()

// Don't forget to save
file.save()
```

### Generic Property Access

```swift
// Get all properties
let allProps = file.allProperties()
for (key, values) in allProps {
    print("\(key): \(values.joined(separator: ", "))")
}

// Get/set custom properties
let customValue = file.getProperty("CUSTOM_TAG")
file.setProperty("CUSTOM_TAG", value: "Custom Value")

// Multi-value properties
let artists = file.getPropertyValues("ARTIST")  // Returns [String]
file.appendProperty("ARTIST", value: "Featured Artist")
```

## Supported Properties

### Basic Tags
- `TITLE`, `ALBUM`, `ARTIST`, `ALBUMARTIST`
- `TRACKNUMBER`, `DISCNUMBER`
- `DATE`, `ORIGINALDATE`
- `GENRE`, `COMMENT`, `SUBTITLE`

### Sort Names
- `TITLESORT`, `ALBUMSORT`, `ARTISTSORT`
- `ALBUMARTISTSORT`, `COMPOSERSORT`

### Credits
- `COMPOSER`, `LYRICIST`, `CONDUCTOR`, `REMIXER`

### Other
- `ISRC`, `ASIN`, `BPM`, `COPYRIGHT`
- `ENCODEDBY`, `MOOD`, `MEDIA`
- `LABEL`, `CATALOGNUMBER`, `BARCODE`
- `RELEASECOUNTRY`, `RELEASESTATUS`, `RELEASETYPE`

### MusicBrainz
- `MUSICBRAINZ_TRACKID`, `MUSICBRAINZ_ALBUMID`
- `MUSICBRAINZ_RELEASEGROUPID`, `MUSICBRAINZ_RELEASETRACKID`
- `MUSICBRAINZ_WORKID`, `MUSICBRAINZ_ARTISTID`
- `MUSICBRAINZ_ALBUMARTISTID`
- `ACOUSTID_ID`, `ACOUSTID_FINGERPRINT`, `MUSICIP_PUID`

## Error Handling

```swift
do {
    let file = try AudioFile(path: "/path/to/song.mp3")
    // ...
} catch AudioFileError.fileNotFound(let path) {
    print("File not found: \(path)")
} catch AudioFileError.invalidFile(let path) {
    print("Invalid audio file: \(path)")
}
```
