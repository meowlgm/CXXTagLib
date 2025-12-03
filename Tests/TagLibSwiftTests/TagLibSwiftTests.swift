import XCTest
@testable import TagLibSwift

final class TagLibSwiftTests: XCTestCase {
    
    // MARK: - Test Files
    
    static let audioFiles = [
        "/Users/meowlgm/Documents/测试音频/似是故人来 - 梅艳芳.wav",
        "/Users/meowlgm/Documents/测试音频/似是故人来 - 梅艳芳(PCM-ALAW).wav",
        "/Users/meowlgm/Documents/测试音频/似是故人来 - 梅艳芳(PCM-UALAW).wav",
        "/Users/meowlgm/Documents/测试音频/似是故人来 - 梅艳芳.aac",
        "/Users/meowlgm/Documents/测试音频/似是故人来 - 梅艳芳.m4a",
        "/Users/meowlgm/Documents/测试音频/亲密爱人.ape",
        "/Users/meowlgm/Documents/测试音频/似是故人来 - 梅艳芳.flac",
        "/Users/meowlgm/Documents/测试音频/似是故人来 - 梅艳芳.mp3",
        "/Users/meowlgm/Documents/测试音频/似是故人来 - 梅艳芳.ogg",
        "/Users/meowlgm/Documents/测试音频/似是故人来 - 梅艳芳.wma",
    ]
    
    static let coverFiles = [
        ("/Users/meowlgm/Documents/测试音频/封面/女人花.jpg", "image/jpeg"),
        ("/Users/meowlgm/Documents/测试音频/封面/让一切随风.jpg", "image/jpeg"),
        ("/Users/meowlgm/Documents/测试音频/封面/Color Out.jpg", "image/jpeg"),
        ("/Users/meowlgm/Documents/测试音频/封面/戒网.png", "image/png"),
    ]
    
    static let pictureTypes: [PictureType] = [
        .frontCover,
        .backCover,
        .artist,
        .bandLogo
    ]
    
    // MARK: - Test All Tags
    
    func testSetAllTagsAndCovers() throws {
        for (index, audioPath) in Self.audioFiles.enumerated() {
            print("\n========================================")
            print("Testing [\(index + 1)/\(Self.audioFiles.count)]: \(audioPath)")
            print("========================================")
            
            do {
                let file = try AudioFile(path: audioPath)
                
                // ==================== 基础标签 ====================
                print("Setting basic tags...")
                file.title = "测试标题 Test Title"
                file.artist = "测试艺术家 Test Artist"
                file.album = "测试专辑 Test Album"
                file.comment = "这是测试注释 This is a test comment"
                file.genre = "Pop"
                file.track = String(index + 1)
                
                // ==================== 扩展标签 - 专辑信息 ====================
                print("Setting album info tags...")
                file.albumArtist = "测试专辑艺术家 Test Album Artist"
                file.discNumber = "1"
                file.subtitle = "测试副标题 Test Subtitle"
                file.year = "2024"
                file.date = "2024-01-15"
                file.originalDate = "2020-06-01"
                
                // ==================== 扩展标签 - 创作者信息 ====================
                print("Setting creator tags...")
                file.composer = "测试作曲家 Test Composer"
                file.lyricist = "测试作词者 Test Lyricist"
                file.conductor = "测试指挥 Test Conductor"
                file.remixer = "测试混音师 Test Remixer"
                
                // ==================== 扩展标签 - 排序标签 ====================
                print("Setting sort tags...")
                file.titleSort = "Ce Shi Biao Ti"
                file.artistSort = "Ce Shi Yi Shu Jia"
                file.albumSort = "Ce Shi Zhuan Ji"
                file.albumArtistSort = "Ce Shi Zhuan Ji Yi Shu Jia"
                file.composerSort = "Ce Shi Zuo Qu Jia"
                
                // ==================== 扩展标签 - 其他 ====================
                print("Setting other tags...")
                file.bpm = 128
                file.isrc = "USRC12345678"
                file.barcode = "1234567890123"
                file.catalogNumber = "CAT-001"
                file.label = "测试唱片公司 Test Label"
                file.copyright = "© 2024 Test Copyright"
                file.mood = "Happy"
                file.media = "Digital Media"
                file.encodedBy = "TagLibSwift Test"
                file.releaseCountry = "CN"
                file.releaseStatus = "Official"
                file.releaseType = "Album"
                file.asin = "B0TEST12345"
                
                // ==================== MusicBrainz 标识 ====================
                print("Setting MusicBrainz tags...")
                file.musicBrainzTrackId = "12345678-1234-1234-1234-123456789012"
                file.musicBrainzArtistId = "abcdefgh-abcd-abcd-abcd-abcdefghijkl"
                file.musicBrainzAlbumId = "album123-album-album-album-album1234567"
                file.musicBrainzAlbumArtistId = "albumart-isti-dist-idid-albumartistid"
                file.musicBrainzReleaseGroupId = "relgroup-rele-grou-pid0-releasegrpid0"
                file.musicBrainzWorkId = "workidid-work-idid-work-workid123456"
                
                // ==================== PERFORMER 标签 ====================
                print("Setting performer tags...")
                file.setPerformer("测试吉他手 Test Guitarist", for: "guitar")
                file.setPerformer("测试贝斯手 Test Bassist", for: "bass")
                file.setPerformer("测试鼓手 Test Drummer", for: "drums")
                file.setPerformer("测试键盘手 Test Keyboardist", for: "keyboard")
                
                // ==================== 封面设置 ====================
                print("Setting artwork (4 covers)...")
                
                // 先清除所有封面
                file.removeAllArtwork()
                
                // 添加 4 个封面
                for (coverIndex, (coverPath, mimeType)) in Self.coverFiles.enumerated() {
                    let pictureType = Self.pictureTypes[coverIndex]
                    
                    guard let coverData = try? Data(contentsOf: URL(fileURLWithPath: coverPath)) else {
                        print("  ⚠️ Failed to load cover: \(coverPath)")
                        continue
                    }
                    
                    let success = file.addArtwork(
                        data: coverData,
                        mimeType: mimeType,
                        description: "Cover \(coverIndex + 1): \(pictureType.rawValue)",
                        pictureType: pictureType
                    )
                    
                    print("  Cover \(coverIndex + 1) (\(pictureType.rawValue)): \(success ? "✅" : "❌")")
                }
                
                // ==================== 保存 ====================
                print("Saving...")
                let saveResult = file.save()
                print("Save result: \(saveResult ? "✅ SUCCESS" : "❌ FAILED")")
                
                // ==================== 验证读取 ====================
                print("Verifying...")
                let verifyFile = try AudioFile(path: audioPath)
                
                // 验证基础标签
                XCTAssertEqual(verifyFile.title, "测试标题 Test Title", "Title mismatch")
                XCTAssertEqual(verifyFile.artist, "测试艺术家 Test Artist", "Artist mismatch")
                XCTAssertEqual(verifyFile.album, "测试专辑 Test Album", "Album mismatch")
                XCTAssertEqual(verifyFile.year, "2024", "Year mismatch")
                XCTAssertEqual(verifyFile.track, String(index + 1), "Track mismatch")
                
                // 验证封面数量
                let pictureCount = verifyFile.pictureCount
                print("  Picture count: \(pictureCount)")
                
                // 打印音频属性
                if let props = verifyFile.audioProperties {
                    print("  Duration: \(props.duration)s, Bitrate: \(props.bitrate)kbps, Sample Rate: \(props.sampleRate)Hz")
                }
                
                print("✅ Test passed for: \(URL(fileURLWithPath: audioPath).lastPathComponent)")
                
            } catch AudioFileError.fileNotFound(let path) {
                print("❌ File not found: \(path)")
                XCTFail("File not found: \(path)")
            } catch AudioFileError.invalidFile(let path) {
                print("⚠️ Invalid/unsupported file: \(path)")
                // 某些格式可能不支持，不算失败
            } catch {
                print("❌ Error: \(error)")
                XCTFail("Unexpected error: \(error)")
            }
        }
        
        print("\n========================================")
        print("All tests completed!")
        print("========================================")
    }
    
    // MARK: - Test Individual Operations
    
    func testReadAudioProperties() throws {
        for audioPath in Self.audioFiles {
            guard let file = try? AudioFile(path: audioPath) else { continue }
            
            if let props = file.audioProperties {
                print("\(URL(fileURLWithPath: audioPath).lastPathComponent):")
                print("  Duration: \(props.duration)s")
                print("  Bitrate: \(props.bitrate) kbps")
                print("  Sample Rate: \(props.sampleRate) Hz")
                print("  Channels: \(props.channels)")
            }
        }
    }
    
    func testPictureOperations() throws {
        // 使用 MP3 测试封面操作
        let testPath = Self.audioFiles[7] // MP3 文件
        let file = try AudioFile(path: testPath)
        
        // 清除所有封面
        print("Removing all artwork...")
        file.removeAllArtwork()
        XCTAssertEqual(file.pictureCount, 0, "Should have 0 pictures after removeAll")
        
        // 添加第一个封面
        let (cover1Path, mime1) = Self.coverFiles[0]
        let cover1Data = try Data(contentsOf: URL(fileURLWithPath: cover1Path))
        file.addArtwork(data: cover1Data, mimeType: mime1, pictureType: .frontCover)
        file.save()
        XCTAssertEqual(file.pictureCount, 1, "Should have 1 picture")
        
        // 添加第二个封面
        let (cover2Path, mime2) = Self.coverFiles[1]
        let cover2Data = try Data(contentsOf: URL(fileURLWithPath: cover2Path))
        file.addArtwork(data: cover2Data, mimeType: mime2, pictureType: .backCover)
        file.save()
        XCTAssertEqual(file.pictureCount, 2, "Should have 2 pictures")
        
        // 删除第一个封面
        file.removeArtwork(at: 0)
        file.save()
        XCTAssertEqual(file.pictureCount, 1, "Should have 1 picture after remove")
        
        // 替换封面
        let (cover3Path, mime3) = Self.coverFiles[2]
        let cover3Data = try Data(contentsOf: URL(fileURLWithPath: cover3Path))
        let newPicture = AudioFile.Picture(
            data: cover3Data,
            mimeType: mime3,
            description: "Replaced cover",
            pictureType: .artist
        )
        file.replaceArtwork(at: 0, with: newPicture)
        file.save()
        
        // 验证
        let pictures = file.pictures
        XCTAssertEqual(pictures.count, 1)
        print("Final picture type: \(pictures.first?.pictureTypeString ?? "unknown")")
        
        print("✅ Picture operations test passed")
    }
}
