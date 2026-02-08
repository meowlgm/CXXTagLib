import XCTest
@testable import TagLibSwift

final class MP4DeleteTest: XCTestCase {
    
    let originalPath = "/Users/meowlgm/Music/LX/亲密爱人/亲密爱人.m4a"
    var testPath: String!
    
    override func setUp() {
        super.setUp()
        let tempDir = NSTemporaryDirectory()
        testPath = tempDir + "MP4DeleteTest.m4a"
        try? FileManager.default.removeItem(atPath: testPath)
        try? FileManager.default.copyItem(atPath: originalPath, toPath: testPath)
    }
    
    override func tearDown() {
        try? FileManager.default.removeItem(atPath: testPath)
        super.tearDown()
    }
    
    /// 确保测试文件有 DATE 字段（先写入）
    private func ensureDateExists() throws {
        let file = try AudioFile(path: testPath)
        if file.year == nil {
            file.year = "2077"
            file.save()
        }
        // 重新打开验证
        let file2 = try AudioFile(path: testPath)
        XCTAssertNotNil(file2.year, "确保 DATE 存在")
    }
    
    /// 测试1：通过 setProperty nil 删除 DATE（不带 source）
    func testDeleteDateViaSetPropertyNil() throws {
        guard FileManager.default.fileExists(atPath: testPath) else {
            XCTFail("测试文件不存在: \(testPath!)")
            return
        }
        
        try ensureDateExists()
        
        let file1 = try AudioFile(path: testPath)
        let yearBefore = file1.year
        print("[MP4Test] 删除前 year=\(yearBefore ?? "nil")")
        XCTAssertNotNil(yearBefore, "删除前应该有 year")
        
        file1.setProperty("DATE", value: nil)
        let saved = file1.save()
        print("[MP4Test] save() 返回: \(saved)")
        
        let file2 = try AudioFile(path: testPath)
        let yearAfter = file2.year
        print("[MP4Test] 删除后 year=\(yearAfter ?? "nil")")
        
        XCTAssertNil(yearAfter, "删除后 year 应该为 nil")
    }
    
    /// 测试2：通过 year = nil 删除
    func testDeleteDateViaYearNil() throws {
        guard FileManager.default.fileExists(atPath: testPath) else {
            XCTFail("测试文件不存在: \(testPath!)")
            return
        }
        
        try ensureDateExists()
        
        let file1 = try AudioFile(path: testPath)
        let yearBefore = file1.year
        print("[MP4Test:YearNil] 删除前 year=\(yearBefore ?? "nil")")
        XCTAssertNotNil(yearBefore)
        
        file1.year = nil
        let saved = file1.save()
        print("[MP4Test:YearNil] save() 返回: \(saved)")
        
        let file2 = try AudioFile(path: testPath)
        let yearAfter = file2.year
        print("[MP4Test:YearNil] 删除后 year=\(yearAfter ?? "nil")")
        
        XCTAssertNil(yearAfter, "删除后 year 应该为 nil")
    }
    
    /// 测试3：先写入再删除
    func testWriteThenDelete() throws {
        guard FileManager.default.fileExists(atPath: testPath) else {
            XCTFail("测试文件不存在: \(testPath!)")
            return
        }
        
        let file1 = try AudioFile(path: testPath)
        file1.year = "2088"
        file1.save()
        
        let file2 = try AudioFile(path: testPath)
        XCTAssertEqual(file2.year, "2088", "写入应该成功")
        
        file2.year = nil
        file2.save()
        
        let file3 = try AudioFile(path: testPath)
        print("[MP4Test:WriteThenDelete] 删除后 year=\(file3.year ?? "nil")")
        XCTAssertNil(file3.year, "删除后 year 应该为 nil")
    }
    
    /// 测试4：通过 removeProperty 按 source 删除
    func testRemovePropertyFromMP4Source() throws {
        guard FileManager.default.fileExists(atPath: testPath) else {
            XCTFail("测试文件不存在: \(testPath!)")
            return
        }
        
        try ensureDateExists()
        
        let file1 = try AudioFile(path: testPath)
        XCTAssertNotNil(file1.year)
        
        file1.removeProperty("DATE", from: .mp4)
        file1.save()
        
        let file2 = try AudioFile(path: testPath)
        print("[MP4Test:RemoveSource] 删除后 year=\(file2.year ?? "nil")")
        XCTAssertNil(file2.year, "删除后 year 应该为 nil")
    }
    
    /// 测试5：删除 TITLE
    func testDeleteTitle() throws {
        guard FileManager.default.fileExists(atPath: testPath) else {
            XCTFail("测试文件不存在: \(testPath!)")
            return
        }
        
        let file1 = try AudioFile(path: testPath)
        let titleBefore = file1.title
        print("[MP4Test:Title] 删除前 title=\(titleBefore ?? "nil")")
        
        // 确保有 title
        if titleBefore == nil {
            file1.title = "Test Title"
            file1.save()
        }
        
        let file2 = try AudioFile(path: testPath)
        XCTAssertNotNil(file2.title)
        
        file2.title = nil
        file2.save()
        
        let file3 = try AudioFile(path: testPath)
        print("[MP4Test:Title] 删除后 title=\(file3.title ?? "nil")")
        XCTAssertNil(file3.title, "删除后 title 应该为 nil")
    }
    
    /// 测试6：多次写入删除循环
    func testMultipleWriteDeleteCycles() throws {
        guard FileManager.default.fileExists(atPath: testPath) else {
            XCTFail("测试文件不存在: \(testPath!)")
            return
        }
        
        for i in 1...3 {
            // 写入
            let fileW = try AudioFile(path: testPath)
            fileW.year = String(2000 + i)
            fileW.save()
            
            let fileR1 = try AudioFile(path: testPath)
            XCTAssertEqual(fileR1.year, String(2000 + i), "第\(i)轮写入应该成功")
            
            // 删除
            fileR1.year = nil
            fileR1.save()
            
            let fileR2 = try AudioFile(path: testPath)
            XCTAssertNil(fileR2.year, "第\(i)轮删除应该成功")
            print("[MP4Test:Cycle] 第\(i)轮 写入/删除 成功")
        }
    }
}
