# CXXTagLib

[TagLib](https://github.com/taglib/taglib) packaged for the [Swift Package Manager](https://swift.org/package-manager/).

## 安装

在 `Package.swift` 中添加依赖：

```swift
dependencies: [
    .package(url: "https://github.com/your-repo/CXXTagLib.git", from: "1.0.0")
]

targets: [
    .target(
        name: "YourTarget",
        dependencies: ["TagLibSwift"]
    )
]
```

## 快速开始

```swift
import TagLibSwift

// 打开音频文件
let file = try AudioFile(path: "/path/to/song.mp3")

// 读取标签
print(file.title ?? "Unknown")
print(file.artist ?? "Unknown")

// 修改标签
file.title = "新歌曲名"
file.artist = "艺术家"

// 保存
file.save()
```

## 支持的格式

MP3, FLAC, M4A, AAC, ALAC, OGG, Opus, WAV, AIFF, WMA, APE, WavPack, MPC, DSF, DSDIFF, TrueAudio, Speex 等 16+ 种格式。

**调用者无需关心格式差异，API 使用方式完全相同。**

---

# API 文档

## AudioFile

### 初始化

```swift
// 从路径打开
let file = try AudioFile(path: "/path/to/audio.mp3")

// 可能抛出的错误
enum AudioFileError: Error {
    case fileNotFound(String)
    case invalidFile(String)
}
```

### 音频属性（只读）

```swift
file.audioProperties?.duration    // Int - 时长（秒）
file.audioProperties?.bitrate     // Int - 比特率 (kbps)
file.audioProperties?.sampleRate  // Int - 采样率 (Hz)
file.audioProperties?.channels    // Int - 声道数
```

### 保存

```swift
file.save()  // 保存所有更改
```

---

## 基础标签

| 属性 | 类型 | 说明 |
|------|------|------|
| `title` | `String?` | 标题 |
| `artist` | `String?` | 艺术家 |
| `album` | `String?` | 专辑 |
| `comment` | `String?` | 注释 |
| `genre` | `String?` | 流派 |
| `year` | `String?` | 年份或日期，如 "2024" 或 "2024-01-15" |
| `track` | `String?` | 音轨号，如 "1" 或 "1/12" |

```swift
// 读取
let title = file.title

// 设置
file.title = "新标题"
file.year = "2024"
file.track = "1"         // 或 "1/12" (含总数)
file.save()  // 保存更改
```

---

## 扩展标签

### 专辑信息

| 属性 | 类型 | 说明 |
|------|------|------|
| `albumArtist` | `String?` | 专辑艺术家 |
| `discNumber` | `String?` | 碟片号，如 "1" 或 "1/2" (含总数) |
| `subtitle` | `String?` | 副标题 |
| `date` | `String?` | 发行日期 |
| `originalDate` | `String?` | 原始发行日期 |

### 创作者信息

| 属性 | 类型 | 说明 |
|------|------|------|
| `composer` | `String?` | 作曲家 |
| `lyricist` | `String?` | 作词者 / 歌词 |
| `conductor` | `String?` | 指挥 |
| `remixer` | `String?` | 混音师 |

> **💡 提示**：`lyricist` 字段（对应 ID3v2 的 TEXT 帧）常被主流音乐软件用于存储 LRC 同步歌词。如需让歌词被更多播放器识别，建议将此字段在 UI上映射为歌词


### 排序标签

用于控制在播放器中的排序方式：

| 属性 | 类型 | 说明 |
|------|------|------|
| `titleSort` | `String?` | 标题排序 |
| `artistSort` | `String?` | 艺术家排序 |
| `albumSort` | `String?` | 专辑排序 |
| `albumArtistSort` | `String?` | 专辑艺术家排序 |
| `composerSort` | `String?` | 作曲家排序 |

```swift
// 示例：让 "The Beatles" 按 "Beatles" 排序
file.artist = "The Beatles"
file.artistSort = "Beatles, The"
```

### 评分与播放次数

| 属性 | 类型 | 说明 |
|------|------|------|
| `rating` | `Int?` | 原始评分 (0-255)，nil 表示未设置 |
| `ratingStars` | `Int?` | 星级评分 (0-5)，自动转换 |
| `playCount` | `UInt` | 播放次数 |

```swift
// 读取
let stars = file.ratingStars  // 0, 1, 2, 3, 4, 5 或 nil

// 设置
file.ratingStars = 5  // 设置 5 星
file.playCount = 10

// 删除
file.ratingStars = nil  // 删除评分（POPM 帧）
```

> **星级映射（Windows Media Player 标准）**：
> | 星级 | 值 | | 星级 | 值 |
> |------|-----|---|------|-----|
> | 1⭐ | 1 | | 4⭐ | 196 |
> | 2⭐ | 64 | | 5⭐ | 255 |
> | 3⭐ | 128 | | | |

### 其他标签

| 属性 | 类型 | 说明 |
|------|------|------|
| `bpm` | `Int?` | 每分钟节拍数 |
| `isrc` | `String?` | 国际标准录音编码 |
| `asin` | `String?` | Amazon 标准识别号 |
| `barcode` | `String?` | 条形码 |
| `catalogNumber` | `String?` | 目录编号 |
| `label` | `String?` | 唱片公司 |
| `copyright` | `String?` | 版权信息 |
| `mood` | `String?` | 情绪 |
| `media` | `String?` | 媒体类型 |
| `encodedBy` | `String?` | 编码者 |
| `releaseCountry` | `String?` | 发行国家 |
| `releaseStatus` | `String?` | 发行状态 |
| `releaseType` | `String?` | 发行类型 |

### MusicBrainz 标识

| 属性 | 类型 | 说明 |
|------|------|------|
| `musicBrainzTrackId` | `String?` | 曲目 ID |
| `musicBrainzArtistId` | `String?` | 艺术家 ID |
| `musicBrainzAlbumId` | `String?` | 专辑 ID |
| `musicBrainzAlbumArtistId` | `String?` | 专辑艺术家 ID |
| `musicBrainzReleaseGroupId` | `String?` | 发行组 ID |
| `musicBrainzWorkId` | `String?` | 作品 ID |

### 特殊标签：PERFORMER

支持按乐器分类的演奏者信息：

```swift
// 读取
let guitarist = file.performer(for: "guitar")

// 设置
file.setPerformer("John Mayer", for: "guitar")
file.setPerformer("Pino Palladino", for: "bass")
```

---

## 通用属性操作

### 读取所有属性

```swift
// 获取所有属性键
let keys = file.allPropertyKeys()  // [String]

// 获取所有属性（合并去重）
let props = file.allProperties()   // [String: String]

// 获取所有属性（含来源，不去重）
let rawProps = file.allPropertiesRaw()  // [RawProperty]
for prop in rawProps {
    print("[\(prop.source)] \(prop.key): \(prop.value)")
}
// 输出示例：
// [ID3v2] TITLE: 歌曲名
// [ID3v2] ARTIST: 艺术家
// [ID3v1] TITLE: 歌曲名（可能与 ID3v2 不同）
```

**支持的来源标识**：

| 来源 | 说明 |
|------|------|
| `ID3v2` | ID3v2 标签（MP3, FLAC, WAV 等）|
| `ID3v1` | ID3v1 标签（MP3, FLAC 等）|
| `Xiph` | Xiph/Vorbis Comment（FLAC, Ogg）|
| `MP4` | MP4 标签（M4A, AAC）|
| `APE` | APE 标签（APE, WavPack, MPC）|
| `ASF` | ASF 标签（WMA）|

### 读写单个属性

```swift
// 读取
let value = file.getProperty("CUSTOM_TAG")

// 设置
file.setProperty("CUSTOM_TAG", value: "自定义值")

// 删除
file.setProperty("CUSTOM_TAG", value: nil)
```

### 清除所有标签

```swift
// 删除文件中的所有标签（ID3v1, ID3v2, APE, Xiph 等）
file.removeAllTags()
file.save()  // 需要保存才生效
```

---

## 封面/图片操作

### 图片类型

```swift
public enum PictureType: String {
    case other = "Other"
    case fileIcon = "File Icon"
    case frontCover = "Front Cover"    // 最常用
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
    case illustration = "Illustration"
    case bandLogo = "Band Logo"
    case publisherLogo = "Publisher Logo"
}
```

### Picture 结构体

```swift
public struct Picture {
    let data: Data              // 图片数据
    let mimeType: String        // MIME 类型 (image/jpeg, image/png)
    let description: String     // 描述
    let pictureTypeString: String  // 类型字符串
    var pictureType: PictureType   // 类型枚举
}
```

### 读取封面

```swift
// 获取第一张封面
if let artwork = file.artwork {
    let imageData = artwork.data
    let mimeType = artwork.mimeType
}

// 获取所有封面
let allPictures = file.pictures

// 获取封面数量
let count = file.pictureCount
```

### 设置封面（替换所有）

```swift
// 使用枚举类型
file.setArtwork(
    data: imageData,
    mimeType: "image/jpeg",
    description: "专辑封面",
    pictureType: .frontCover
)

// 使用自定义类型字符串
file.setArtwork(
    data: imageData,
    mimeType: "image/jpeg",
    pictureTypeString: "Custom Type"
)

// 从 URL 设置
file.setArtwork(
    from: imageURL,
    mimeType: "image/jpeg",
    pictureType: .frontCover
)

file.save()  // 保存更改
```

### 添加封面（保留现有）

```swift
// 添加背面封面
file.addArtwork(
    data: backCoverData,
    mimeType: "image/jpeg",
    pictureType: .backCover
)

// 从 URL 添加
file.addArtwork(
    from: imageURL,
    mimeType: "image/png",
    pictureType: .bandLogo
)

file.save()  // 保存更改
```

### 删除封面

```swift
// 删除所有封面
file.removeAllArtwork()

// 删除指定索引的封面
file.removeArtwork(at: 0)

// 删除指定类型的封面
file.removeArtwork(ofType: .backCover)

// 删除自定义类型的封面
file.removeArtwork(ofTypeString: "Custom Type")

file.save()  // 保存更改
```

### 替换封面

```swift
// 替换指定索引的封面
let newPicture = AudioFile.Picture(
    data: newData,
    mimeType: "image/jpeg",
    pictureType: .frontCover
)
file.replaceArtwork(at: 0, with: newPicture)

// 替换所有封面为新数组
file.replacePictures(with: [picture1, picture2])

file.save()  // 保存更改
```

---

## 完整示例

```swift
import TagLibSwift

do {
    // 打开文件
    let file = try AudioFile(path: "/path/to/song.flac")
    
    // 读取音频信息
    if let props = file.audioProperties {
        print("时长: \(props.duration) 秒")
        print("比特率: \(props.bitrate) kbps")
    }
    
    // 设置基础标签
    file.title = "歌曲名"
    file.artist = "艺术家"
    file.album = "专辑名"
    file.year = 2024
    file.track = 1
    
    // 设置扩展标签
    file.albumArtist = "Various Artists"
    file.discNumber = 1
    file.composer = "作曲家"
    file.bpm = 128
    
    // 设置排序标签
    file.artistSort = "艺术家拼音"
    
    // 设置演奏者
    file.setPerformer("吉他手", for: "guitar")
    
    // 设置封面
    if let coverData = try? Data(contentsOf: URL(fileURLWithPath: "/path/to/cover.jpg")) {
        file.setArtwork(
            data: coverData,
            mimeType: "image/jpeg",
            pictureType: .frontCover
        )
    }
    
    // 保存
    file.save()
    
    print("保存成功！")
    
} catch AudioFileError.fileNotFound(let path) {
    print("文件不存在: \(path)")
} catch AudioFileError.invalidFile(let path) {
    print("无效的音频文件: \(path)")
} catch {
    print("错误: \(error)")
}
```

---

## 注意事项

1. **格式无关**：所有 API 对所有支持的音频格式使用方式相同
2. **MIME 类型**：设置封面时需要显式指定 MIME 类型，库不会自动检测
3. **字符串标签**：扩展标签全部为字符串类型，数值需自行转换
4. **保存**：修改后需调用 `save()` 才会写入文件
5. **内存管理**：`AudioFile` 对象释放时会自动关闭文件

## 标签优先级

对于支持多种标签格式的文件（如 MP3），本库按以下优先级处理：

| 操作 | 优先级 |
|------|--------|
| 读取 | ID3v2 → ID3v1 → 其他 |
| 写入 | 优先写入 ID3v2（支持的格式）|
| 删除 | 按优先级删除找到的那个 |

**各格式的标签类型**：

| 格式 | 支持的标签类型 |
|------|---------------|
| MP3 | ID3v2, ID3v1, APE |
| FLAC | Xiph Comment, ID3v2, ID3v1 |
| M4A/AAC | MP4 Tag |
| Ogg | Xiph Comment |
| WMA | ASF Tag |
| APE/WavPack/MPC | APE Tag, ID3v1 |
| WAV/AIFF | ID3v2 |

## 许可证

TagLib 使用 LGPL/MPL 双许可证。
