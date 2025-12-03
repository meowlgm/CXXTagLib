import XCTest
@testable import TagLibSwift

final class OggRemovePictureTest: XCTestCase {
    
    static let oggFilePath = "/Users/meowlgm/Documents/测试音频/似是故人来 - 梅艳芳.ogg"
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
    
    /// 辅助方法：确保文件有 4 张封面
    private func ensureFourPictures() throws {
        let file = try AudioFile(path: Self.oggFilePath)
        if file.pictureCount != 4 {
            file.removeAllArtwork()
            for (i, (coverPath, mimeType)) in Self.coverFiles.enumerated() {
                if let data = try? Data(contentsOf: URL(fileURLWithPath: coverPath)) {
                    file.addArtwork(data: data, mimeType: mimeType, pictureType: Self.pictureTypes[i])
                }
            }
            file.save()
        }
    }
    
    /// 测试删除 OGG 文件第四张封面（索引 3）
    func testRemoveFourthPictureFromOgg() throws {
        // 确保初始状态有 4 张封面
        try ensureFourPictures()
        
        let file = try AudioFile(path: Self.oggFilePath)
        let initialCount = file.pictureCount
        print("[Test] 初始封面数量: \(initialCount)")
        XCTAssertEqual(initialCount, 4, "应该有4张封面")
        
        // 删除第四张封面（索引 3）
        print("[Test] 删除索引 3...")
        let result = file.removeArtwork(at: 3)
        XCTAssertTrue(result, "删除应该成功")
        
        // 保存
        let saveResult = file.save()
        XCTAssertTrue(saveResult, "保存应该成功")
        
        // 重新打开验证
        let verifyFile = try AudioFile(path: Self.oggFilePath)
        let finalCount = verifyFile.pictureCount
        print("[Test] 删除后封面数量: \(finalCount)")
        XCTAssertEqual(finalCount, 3, "删除后应该有3张封面")
        
        print("[Test] ✅ 测试通过")
    }
    
    /// 测试边界情况（不修改文件状态）
    func testRemoveArtworkEdgeCases() throws {
        let file = try AudioFile(path: Self.oggFilePath)
        
        // 只测试无效索引，不实际删除
        XCTAssertFalse(file.removeArtwork(at: -1), "负索引应返回 false")
        XCTAssertFalse(file.removeArtwork(at: 100), "超出范围索引应返回 false")
        
        print("[Test] 边界测试通过 ✅")
    }
    
    /// 测试 FLAC 文件删除封面（检查是否有同样问题）
    func testRemovePictureFromFLAC() throws {
        let flacPath = "/Users/meowlgm/Documents/测试音频/似是故人来 - 梅艳芳.flac"
        let file = try AudioFile(path: flacPath)
        
        let count = file.pictureCount
        print("[FLAC Test] 初始封面数量: \(count)")
        
        if count >= 4 {
            print("[FLAC Test] 删除索引 3...")
            let result = file.removeArtwork(at: 3)
            print("[FLAC Test] 结果: \(result)")
            XCTAssertTrue(result, "FLAC 删除应成功")
        }
    }
    
    /// 测试 OGG 替换封面
    func testReplacePictureFromOgg() throws {
        try ensureFourPictures()
        
        let file = try AudioFile(path: Self.oggFilePath)
        print("[Replace Test] 初始封面数量: \(file.pictureCount)")
        
        // 加载新封面
        let (coverPath, mimeType) = Self.coverFiles[0]
        guard let coverData = try? Data(contentsOf: URL(fileURLWithPath: coverPath)) else {
            XCTFail("无法加载封面")
            return
        }
        
        let newPicture = AudioFile.Picture(
            data: coverData,
            mimeType: mimeType,
            description: "Replaced",
            pictureType: .leafletPage
        )
        
        // 替换索引 3
        print("[Replace Test] 替换索引 3...")
        let result = file.replaceArtwork(at: 3, with: newPicture)
        print("[Replace Test] 结果: \(result)")
        XCTAssertTrue(result, "替换应成功")
        
        // 验证数量不变
        XCTAssertEqual(file.pictureCount, 4, "数量应保持 4")
        print("[Replace Test] ✅ 测试通过")
    }
    
    /// 测试逐一删除所有封面
    func testRemoveAllPicturesOneByOne() throws {
        let file = try AudioFile(path: Self.oggFilePath)
        
        // 确保有封面
        print("[OggRemovePictureTest:OneByOne] 初始封面数量: \(file.pictureCount)")
        
        if file.pictureCount < 4 {
            file.removeAllArtwork()
            for (i, (coverPath, mimeType)) in Self.coverFiles.enumerated() {
                if let coverData = try? Data(contentsOf: URL(fileURLWithPath: coverPath)) {
                    file.addArtwork(data: coverData, mimeType: mimeType, pictureType: Self.pictureTypes[i])
                }
            }
            file.save()
        }
        
        // 重新打开并逐一删除
        let testFile = try AudioFile(path: Self.oggFilePath)
        let initialCount = testFile.pictureCount
        print("[OggRemovePictureTest:OneByOne] 开始逐一删除，初始数量: \(initialCount)")
        
        // 从后往前删除（避免索引偏移问题）
        for i in stride(from: initialCount - 1, through: 0, by: -1) {
            print("[OggRemovePictureTest:OneByOne] 删除索引 \(i)...")
            let result = testFile.removeArtwork(at: i)
            print("[OggRemovePictureTest:OneByOne]   结果: \(result ? "✅" : "❌")")
            
            // 保存并验证
            testFile.save()
            
            let verifyFile = try AudioFile(path: Self.oggFilePath)
            let currentCount = verifyFile.pictureCount
            print("[OggRemovePictureTest:OneByOne]   当前数量: \(currentCount)")
        }
        
        // 最终验证
        let finalFile = try AudioFile(path: Self.oggFilePath)
        XCTAssertEqual(finalFile.pictureCount, 0, "所有封面应该已被删除")
        print("[OggRemovePictureTest:OneByOne] ✅ 测试通过！")
    }
}
