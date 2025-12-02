import XCTest
@testable import TagLibSwift

final class ReadTagsTest: XCTestCase {
    
    func testRating() throws {
        let path = "/Users/meowlgm/Music/LX/让一切随风 - 钟镇涛.mp3"
        
        let file = try AudioFile(path: path)
        
        print("\n========== 当前评分 ==========")
        print("rating (0-255): \(file.rating.map { String($0) } ?? "(nil)")")
        print("ratingStars (0-5): \(file.ratingStars.map { String($0) } ?? "(nil)")")
        print("playCount: \(file.playCount)")
        
        // 设置 5 星评分
        print("\n========== 设置 5 星评分 ==========")
        file.ratingStars = 5
        file.playCount = 10
        file.save()
        
        // 验证
        let file2 = try AudioFile(path: path)
        print("rating (0-255): \(file2.rating.map { String($0) } ?? "(nil)")")
        print("ratingStars (0-5): \(file2.ratingStars.map { String($0) } ?? "(nil)")")
        print("playCount: \(file2.playCount)")
    }
    
    func testReadAllTags() throws {
        let path = "/Users/meowlgm/Music/LX/让一切随风 - 钟镇涛.mp3"
        
        let file = try AudioFile(path: path)
        
        print("\n========== 基础标签 ==========")
        print("TITLE:       \(file.title ?? "(nil)")")
        print("ARTIST:      \(file.artist ?? "(nil)")")
        print("ALBUM:       \(file.album ?? "(nil)")")
        print("GENRE:       \(file.genre ?? "(nil)")")
        print("YEAR:        \(file.year.map { String($0) } ?? "(nil)")")
        print("TRACK:       \(file.track.map { String($0) } ?? "(nil)")")
        print("COMMENT:     \(file.comment ?? "(nil)")")
        
        print("\n========== 扩展标签 ==========")
        print("ALBUMARTIST: \(file.albumArtist ?? "(nil)")")
        print("COMPOSER:    \(file.composer ?? "(nil)")")
        print("LYRICIST:    \(file.lyricist ?? "(nil)")")
        print("CONDUCTOR:   \(file.conductor ?? "(nil)")")
        print("DATE:        \(file.date ?? "(nil)")")
        print("DISCNUMBER:  \(file.discNumber.map { String($0) } ?? "(nil)")")
        
        print("\n========== 所有 PropertyMap 键值 ==========")
        let allProps = file.allProperties()
        for (key, value) in allProps.sorted(by: { $0.key < $1.key }) {
            // 如果值太长，截断显示
            let displayValue = value.count > 50 ? String(value.prefix(50)) + "..." : value
            print("\(key): \(displayValue)")
        }
        
        print("\n========== 音频属性 ==========")
        if let props = file.audioProperties {
            print("Duration:    \(props.duration)s (\(props.formattedDuration))")
            print("Bitrate:     \(props.bitrate) kbps")
            print("Sample Rate: \(props.sampleRate) Hz")
            print("Channels:    \(props.channels)")
        }
        
        print("\n========== 封面信息 ==========")
        print("Picture count: \(file.pictureCount)")
        for (index, pic) in file.pictures.enumerated() {
            print("  [\(index)] Type: \(pic.pictureTypeString), MIME: \(pic.mimeType), Size: \(pic.data.count) bytes")
        }
    }
}
