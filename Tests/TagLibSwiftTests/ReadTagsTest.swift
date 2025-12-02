import XCTest
@testable import TagLibSwift

final class ReadTagsTest: XCTestCase {
    
    func testRestoreTags() throws {
        let path = "/Users/meowlgm/Music/LX/让一切随风 - 钟镇涛.mp3"
        
        let file = try AudioFile(path: path)
        
        print("\n========== 恢复标签 ==========")
        
        // 设置基础标签
        file.title = "让一切随风"
        file.artist = "钟镇涛"
        file.album = "听涛"
        file.genre = "粤语流行"
        file.year = 1987
        file.track = 1
        
        // 设置扩展标签
        file.albumArtist = "钟镇涛"
        file.composer = "大野克夫"
        file.lyricist = "黄霑"  // 这次存正确的作词人名字
        
        file.save()
        
        // 验证
        let file2 = try AudioFile(path: path)
        
        print("\n========== 恢复后 ==========")
        for prop in file2.allPropertiesRaw() {
            print("[\(prop.source)] \(prop.key): \(prop.value)")
        }
        
        print("\n========== 验证 ==========")
        print("title:       \(file2.title ?? "(nil)")")
        print("artist:      \(file2.artist ?? "(nil)")")
        print("album:       \(file2.album ?? "(nil)")")
        print("genre:       \(file2.genre ?? "(nil)")")
        print("year:        \(file2.year.map { String($0) } ?? "(nil)")")
        print("track:       \(file2.track.map { String($0) } ?? "(nil)")")
        print("albumArtist: \(file2.albumArtist ?? "(nil)")")
        print("composer:    \(file2.composer ?? "(nil)")")
        print("lyricist:    \(file2.lyricist ?? "(nil)")")
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
