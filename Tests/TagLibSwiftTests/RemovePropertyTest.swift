import XCTest
@testable import TagLibSwift

final class RemovePropertyTest: XCTestCase {
    
    // 使用测试文件的副本，避免破坏原文件
    let originalPath = "/Volumes/Data/Host 2.mp3"
    var testPath: String!
    
    override func setUp() {
        super.setUp()
        // 复制到临时目录
        let tempDir = NSTemporaryDirectory()
        testPath = tempDir + "RemovePropertyTest_Host2.mp3"
        try? FileManager.default.removeItem(atPath: testPath)
        try? FileManager.default.copyItem(atPath: originalPath, toPath: testPath)
    }
    
    override func tearDown() {
        try? FileManager.default.removeItem(atPath: testPath)
        super.tearDown()
    }
    
    /// 测试通过 removeProperty 按来源删除 ID3v2 的 DATE 标签
    func testRemovePropertyDateFromID3v2() throws {
        guard FileManager.default.fileExists(atPath: testPath) else {
            XCTFail("测试文件不存在: \(testPath!)")
            return
        }
        
        // 1. 读取原始标签，确认 DATE 存在
        let file1 = try AudioFile(path: testPath)
        let rawBefore = file1.allPropertiesRaw()
        let dateBefore = rawBefore.filter { $0.key == "DATE" }
        print("[Test] 删除前 DATE 标签:")
        for item in dateBefore {
            print("  source=\(item.source), key=\(item.key), value=\(item.value)")
        }
        XCTAssertFalse(dateBefore.isEmpty, "删除前应该存在 DATE 标签")
        
        // 2. 通过 removeProperty 按来源删除
        print("[Test] 调用 removeProperty(\"DATE\", from: .id3v2)")
        file1.removeProperty("DATE", from: .id3v2)
        file1.save()
        
        // 3. 重新打开文件验证
        let file2 = try AudioFile(path: testPath)
        let rawAfter = file2.allPropertiesRaw()
        let dateAfter = rawAfter.filter { $0.key == "DATE" }
        print("[Test] 删除后 DATE 标签:")
        if dateAfter.isEmpty {
            print("  (无) ✅ 删除成功")
        } else {
            for item in dateAfter {
                print("  source=\(item.source), key=\(item.key), value=\(item.value) ❌ 仍然存在")
            }
        }
        
        // 验证 ID3v2 来源的 DATE 已被删除
        let id3v2DateAfter = dateAfter.filter { $0.source == "ID3v2" }
        XCTAssertTrue(id3v2DateAfter.isEmpty, "ID3v2 的 DATE 标签应该已被删除")
    }
    
    /// 测试通过 setProperty nil（不带 source）删除 DATE 标签作为对照
    func testSetPropertyNilDate() throws {
        guard FileManager.default.fileExists(atPath: testPath) else {
            XCTFail("测试文件不存在: \(testPath!)")
            return
        }
        
        let file1 = try AudioFile(path: testPath)
        let rawBefore = file1.allPropertiesRaw()
        let dateBefore = rawBefore.filter { $0.key == "DATE" }
        print("[Test] 对照组 - 删除前 DATE: \(dateBefore.map { "\($0.source)=\($0.value)" })")
        XCTAssertFalse(dateBefore.isEmpty)
        
        // 通过 year = nil 删除（不带 source）
        print("[Test] 调用 file.year = nil")
        file1.year = nil
        file1.save()
        
        let file2 = try AudioFile(path: testPath)
        let rawAfter = file2.allPropertiesRaw()
        let dateAfter = rawAfter.filter { $0.key == "DATE" }
        print("[Test] 对照组 - 删除后 DATE: \(dateAfter.map { "\($0.source)=\($0.value)" })")
        XCTAssertTrue(dateAfter.isEmpty, "year=nil 应该能删除 DATE")
    }
}
