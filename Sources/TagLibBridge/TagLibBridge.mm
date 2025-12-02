#import "include/TagLibBridge.h"

#include <taglib/fileref.h>
#include <taglib/tfile.h>

// Format-specific files
#include <taglib/mpegfile.h>
#include <taglib/flacfile.h>
#include <taglib/mp4file.h>
#include <taglib/oggfile.h>
#include <taglib/vorbisfile.h>
#include <taglib/opusfile.h>
#include <taglib/speexfile.h>
#include <taglib/oggflacfile.h>
#include <taglib/wavfile.h>
#include <taglib/aifffile.h>
#include <taglib/apefile.h>
#include <taglib/wavpackfile.h>
#include <taglib/mpcfile.h>
#include <taglib/trueaudiofile.h>
#include <taglib/asffile.h>
#include <taglib/dsffile.h>
#include <taglib/dsdifffile.h>

// Tag types
#include <taglib/id3v1tag.h>
#include <taglib/id3v2tag.h>
#include <taglib/apetag.h>
#include <taglib/xiphcomment.h>
#include <taglib/mp4tag.h>
#include <taglib/asftag.h>

// Picture/cover types
#include <taglib/attachedpictureframe.h>
#include <taglib/flacpicture.h>
#include <taglib/mp4coverart.h>
#include <taglib/asfpicture.h>

#include <taglib/tpropertymap.h>

using namespace TagLib;

// MARK: - TLPicture Implementation

@implementation TLPicture

- (instancetype)initWithData:(NSData *)data
                    mimeType:(NSString *)mimeType
                 description:(NSString *)description
                 pictureType:(NSString *)pictureType {
    self = [super init];
    if (self) {
        _data = data;
        _mimeType = mimeType;
        _pictureDescription = description;
        _pictureType = pictureType;
    }
    return self;
}

@end

// MARK: - TLAudioProperties Implementation

@implementation TLAudioProperties

- (instancetype)initWithDuration:(NSInteger)duration
                         bitrate:(NSInteger)bitrate
                      sampleRate:(NSInteger)sampleRate
                        channels:(NSInteger)channels {
    self = [super init];
    if (self) {
        _duration = duration;
        _bitrate = bitrate;
        _sampleRate = sampleRate;
        _channels = channels;
    }
    return self;
}

@end

// MARK: - Helper Functions

static NSString *stringFromTagLibString(const String &str) {
    if (str.isEmpty()) return @"";
    return [NSString stringWithUTF8String:str.toCString(true)];
}

static String tagLibStringFromNSString(NSString *str) {
    return String([str UTF8String], String::UTF8);
}

static ByteVector byteVectorFromNSData(NSData *data) {
    return ByteVector((const char *)data.bytes, (unsigned int)data.length);
}

static NSData *nsDataFromByteVector(const ByteVector &bv) {
    return [NSData dataWithBytes:bv.data() length:bv.size()];
}

static NSString *pictureTypeToString(int type) {
    switch (type) {
        case 0x00: return @"Other";
        case 0x01: return @"File Icon";
        case 0x02: return @"Other File Icon";
        case 0x03: return @"Front Cover";
        case 0x04: return @"Back Cover";
        case 0x05: return @"Leaflet Page";
        case 0x06: return @"Media";
        case 0x07: return @"Lead Artist";
        case 0x08: return @"Artist";
        case 0x09: return @"Conductor";
        case 0x0A: return @"Band";
        case 0x0B: return @"Composer";
        case 0x0C: return @"Lyricist";
        case 0x0D: return @"Recording Location";
        case 0x0E: return @"During Recording";
        case 0x0F: return @"During Performance";
        case 0x10: return @"Movie Screen Capture";
        case 0x11: return @"Coloured Fish";
        case 0x12: return @"Illustration";
        case 0x13: return @"Band Logo";
        case 0x14: return @"Publisher Logo";
        default: return @"Other";
    }
}

static int pictureTypeFromString(NSString *str) {
    static NSDictionary *typeMap = @{
        @"Other": @0x00,
        @"File Icon": @0x01,
        @"Other File Icon": @0x02,
        @"Front Cover": @0x03,
        @"Back Cover": @0x04,
        @"Leaflet Page": @0x05,
        @"Media": @0x06,
        @"Lead Artist": @0x07,
        @"Artist": @0x08,
        @"Conductor": @0x09,
        @"Band": @0x0A,
        @"Composer": @0x0B,
        @"Lyricist": @0x0C,
        @"Recording Location": @0x0D,
        @"During Recording": @0x0E,
        @"During Performance": @0x0F,
        @"Movie Screen Capture": @0x10,
        @"Coloured Fish": @0x11,
        @"Illustration": @0x12,
        @"Band Logo": @0x13,
        @"Publisher Logo": @0x14
    };
    NSNumber *value = typeMap[str];
    return value ? [value intValue] : 0x03; // Default to Front Cover
}

// MARK: - TagLibBridge Implementation

@interface TagLibBridge ()
@property (nonatomic, assign) FileRef *fileRef;
@property (nonatomic, copy) NSString *filePath;
@end

@implementation TagLibBridge

- (nullable instancetype)initWithPath:(NSString *)path {
    self = [super init];
    if (self) {
        _filePath = path;
        _fileRef = new FileRef([path UTF8String]);
        
        if (_fileRef->isNull()) {
            delete _fileRef;
            _fileRef = nullptr;
            return nil;
        }
    }
    return self;
}

- (void)dealloc {
    if (_fileRef) {
        delete _fileRef;
        _fileRef = nullptr;
    }
}

- (BOOL)isValid {
    return _fileRef && !_fileRef->isNull();
}

- (NSString *)fileType {
    if (!self.isValid) return nil;
    
    File *file = _fileRef->file();
    if (!file) return nil;
    
    if (dynamic_cast<MPEG::File *>(file)) return @"MPEG";
    if (dynamic_cast<FLAC::File *>(file)) return @"FLAC";
    if (dynamic_cast<MP4::File *>(file)) return @"MP4";
    
    return @"Unknown";
}

// MARK: - Audio Properties

- (TLAudioProperties *)audioProperties {
    if (!self.isValid) return nil;
    
    AudioProperties *props = _fileRef->audioProperties();
    if (!props) return nil;
    
    return [[TLAudioProperties alloc] initWithDuration:props->lengthInSeconds()
                                               bitrate:props->bitrate()
                                            sampleRate:props->sampleRate()
                                              channels:props->channels()];
}

// MARK: - Basic Tags

- (NSString *)title {
    if (!self.isValid) return nil;
    Tag *tag = _fileRef->tag();
    if (!tag) return nil;
    return stringFromTagLibString(tag->title());
}

- (void)setTitle:(NSString *)title {
    if (!self.isValid) return;
    Tag *tag = _fileRef->tag();
    if (!tag) return;
    tag->setTitle(title ? tagLibStringFromNSString(title) : String());
}

- (NSString *)artist {
    if (!self.isValid) return nil;
    Tag *tag = _fileRef->tag();
    if (!tag) return nil;
    return stringFromTagLibString(tag->artist());
}

- (void)setArtist:(NSString *)artist {
    if (!self.isValid) return;
    Tag *tag = _fileRef->tag();
    if (!tag) return;
    tag->setArtist(artist ? tagLibStringFromNSString(artist) : String());
}

- (NSString *)album {
    if (!self.isValid) return nil;
    Tag *tag = _fileRef->tag();
    if (!tag) return nil;
    return stringFromTagLibString(tag->album());
}

- (void)setAlbum:(NSString *)album {
    if (!self.isValid) return;
    Tag *tag = _fileRef->tag();
    if (!tag) return;
    tag->setAlbum(album ? tagLibStringFromNSString(album) : String());
}

- (NSString *)comment {
    if (!self.isValid) return nil;
    Tag *tag = _fileRef->tag();
    if (!tag) return nil;
    return stringFromTagLibString(tag->comment());
}

- (void)setComment:(NSString *)comment {
    if (!self.isValid) return;
    Tag *tag = _fileRef->tag();
    if (!tag) return;
    tag->setComment(comment ? tagLibStringFromNSString(comment) : String());
}

- (NSString *)genre {
    if (!self.isValid) return nil;
    Tag *tag = _fileRef->tag();
    if (!tag) return nil;
    return stringFromTagLibString(tag->genre());
}

- (void)setGenre:(NSString *)genre {
    if (!self.isValid) return;
    Tag *tag = _fileRef->tag();
    if (!tag) return;
    tag->setGenre(genre ? tagLibStringFromNSString(genre) : String());
}

- (NSInteger)year {
    if (!self.isValid) return 0;
    Tag *tag = _fileRef->tag();
    if (!tag) return 0;
    return tag->year();
}

- (void)setYear:(NSInteger)year {
    if (!self.isValid) return;
    Tag *tag = _fileRef->tag();
    if (!tag) return;
    tag->setYear((unsigned int)year);
}

- (NSInteger)track {
    if (!self.isValid) return 0;
    Tag *tag = _fileRef->tag();
    if (!tag) return 0;
    return tag->track();
}

- (void)setTrack:(NSInteger)track {
    if (!self.isValid) return;
    Tag *tag = _fileRef->tag();
    if (!tag) return;
    tag->setTrack((unsigned int)track);
}

// MARK: - Extended Tags (PropertyMap)
// 支持 ID3v2 的格式：MPEG, FLAC, WAV, AIFF, DSF, DSDIFF, TrueAudio
// 支持 ID3v1 的格式：MPEG, FLAC, TrueAudio, APE, MPC, WavPack
// 读取：优先 ID3v2，其次 ID3v1，最后其他格式原生标签
// 写入：优先写 ID3v2，不支持则用原生标签
// 删除：按优先顺序删除找到的那个

// 获取文件的 ID3v2 标签（不创建）
- (ID3v2::Tag *)getID3v2TagForRead:(File *)file {
    // MPEG (MP3)
    if (auto *f = dynamic_cast<MPEG::File *>(file)) {
        return f->ID3v2Tag(false);
    }
    // FLAC
    if (auto *f = dynamic_cast<FLAC::File *>(file)) {
        return f->ID3v2Tag(false);
    }
    // WAV
    if (auto *f = dynamic_cast<RIFF::WAV::File *>(file)) {
        return f->ID3v2Tag();
    }
    // AIFF
    if (auto *f = dynamic_cast<RIFF::AIFF::File *>(file)) {
        return dynamic_cast<ID3v2::Tag *>(f->tag());
    }
    // DSF
    if (auto *f = dynamic_cast<DSF::File *>(file)) {
        return f->tag();
    }
    // DSDIFF
    if (auto *f = dynamic_cast<DSDIFF::File *>(file)) {
        return f->ID3v2Tag(false);
    }
    // TrueAudio
    if (auto *f = dynamic_cast<TrueAudio::File *>(file)) {
        return f->ID3v2Tag(false);
    }
    return nullptr;
}

// 获取文件的 ID3v2 标签（创建如果不存在）
- (ID3v2::Tag *)getID3v2TagForWrite:(File *)file {
    // MPEG (MP3)
    if (auto *f = dynamic_cast<MPEG::File *>(file)) {
        return f->ID3v2Tag(true);
    }
    // FLAC
    if (auto *f = dynamic_cast<FLAC::File *>(file)) {
        return f->ID3v2Tag(true);
    }
    // WAV
    if (auto *f = dynamic_cast<RIFF::WAV::File *>(file)) {
        return f->ID3v2Tag();
    }
    // AIFF
    if (auto *f = dynamic_cast<RIFF::AIFF::File *>(file)) {
        return dynamic_cast<ID3v2::Tag *>(f->tag());
    }
    // DSF
    if (auto *f = dynamic_cast<DSF::File *>(file)) {
        return f->tag();
    }
    // DSDIFF
    if (auto *f = dynamic_cast<DSDIFF::File *>(file)) {
        return f->ID3v2Tag(true);
    }
    // TrueAudio
    if (auto *f = dynamic_cast<TrueAudio::File *>(file)) {
        return f->ID3v2Tag(true);
    }
    return nullptr;
}

// 获取文件的 ID3v1 标签
- (ID3v1::Tag *)getID3v1Tag:(File *)file {
    // MPEG (MP3)
    if (auto *f = dynamic_cast<MPEG::File *>(file)) {
        return f->ID3v1Tag();
    }
    // FLAC
    if (auto *f = dynamic_cast<FLAC::File *>(file)) {
        return f->ID3v1Tag();
    }
    // TrueAudio
    if (auto *f = dynamic_cast<TrueAudio::File *>(file)) {
        return f->ID3v1Tag();
    }
    // APE
    if (auto *f = dynamic_cast<APE::File *>(file)) {
        return f->ID3v1Tag();
    }
    // MPC (Musepack)
    if (auto *f = dynamic_cast<MPC::File *>(file)) {
        return f->ID3v1Tag();
    }
    // WavPack
    if (auto *f = dynamic_cast<WavPack::File *>(file)) {
        return f->ID3v1Tag();
    }
    return nullptr;
}

// 检查文件是否支持 ID3v2
- (BOOL)supportsID3v2:(File *)file {
    return dynamic_cast<MPEG::File *>(file) ||
           dynamic_cast<FLAC::File *>(file) ||
           dynamic_cast<RIFF::WAV::File *>(file) ||
           dynamic_cast<RIFF::AIFF::File *>(file) ||
           dynamic_cast<DSF::File *>(file) ||
           dynamic_cast<DSDIFF::File *>(file) ||
           dynamic_cast<TrueAudio::File *>(file);
}

- (NSString *)propertyForKey:(NSString *)key {
    if (!self.isValid || !key) return nil;
    
    File *file = _fileRef->file();
    if (!file) return nil;
    
    String tagKey = tagLibStringFromNSString(key);
    
    // 支持 ID3v2 的格式：优先 ID3v2
    if ([self supportsID3v2:file]) {
        // 先查 ID3v2
        if (ID3v2::Tag *id3v2 = [self getID3v2TagForRead:file]) {
            PropertyMap props = id3v2->properties();
            if (props.contains(tagKey) && !props[tagKey].isEmpty()) {
                return stringFromTagLibString(props[tagKey].front());
            }
        }
        // 再查 ID3v1（仅 MPEG 和 TrueAudio）
        if (ID3v1::Tag *id3v1 = [self getID3v1Tag:file]) {
            PropertyMap props = id3v1->properties();
            if (props.contains(tagKey) && !props[tagKey].isEmpty()) {
                return stringFromTagLibString(props[tagKey].front());
            }
        }
        return nil;
    }
    
    // 其他格式：使用默认 PropertyMap（FLAC, MP4, Ogg, APE, WMA 等）
    PropertyMap props = file->properties();
    if (props.contains(tagKey) && !props[tagKey].isEmpty()) {
        return stringFromTagLibString(props[tagKey].front());
    }
    return nil;
}

- (void)setProperty:(NSString *)value forKey:(NSString *)key {
    if (!self.isValid || !key) return;
    
    File *file = _fileRef->file();
    if (!file) return;
    
    String tagKey = tagLibStringFromNSString(key);
    
    // 支持 ID3v2 的格式：写入 ID3v2，删除按优先顺序
    if ([self supportsID3v2:file]) {
        if (value) {
            // 写入：总是写 ID3v2
            if (ID3v2::Tag *id3v2 = [self getID3v2TagForWrite:file]) {
                PropertyMap props = id3v2->properties();
                StringList values;
                values.append(tagLibStringFromNSString(value));
                props[tagKey] = values;
                id3v2->setProperties(props);
            }
        } else {
            // 删除：先看 ID3v2
            if (ID3v2::Tag *id3v2 = [self getID3v2TagForRead:file]) {
                PropertyMap props = id3v2->properties();
                if (props.contains(tagKey)) {
                    props.erase(tagKey);
                    id3v2->setProperties(props);
                    return;
                }
            }
            // 再看 ID3v1
            if (ID3v1::Tag *id3v1 = [self getID3v1Tag:file]) {
                PropertyMap props = id3v1->properties();
                if (props.contains(tagKey)) {
                    props.erase(tagKey);
                    id3v1->setProperties(props);
                }
            }
        }
        return;
    }
    
    // 其他格式：使用默认 PropertyMap
    PropertyMap props = file->properties();
    if (value) {
        StringList values;
        values.append(tagLibStringFromNSString(value));
        props[tagKey] = values;
        file->setProperties(props);
    } else {
        if (props.contains(tagKey)) {
            props.erase(tagKey);
            file->setProperties(props);
        }
    }
}

- (NSArray<NSString *> *)allPropertyKeys {
    if (!self.isValid) return @[];
    
    File *file = _fileRef->file();
    if (!file) return @[];
    
    // 支持 ID3v2 的格式：合并 ID3v2 和 ID3v1 的 keys
    if ([self supportsID3v2:file]) {
        NSMutableSet<NSString *> *keySet = [NSMutableSet set];
        
        if (ID3v2::Tag *id3v2 = [self getID3v2TagForRead:file]) {
            PropertyMap props = id3v2->properties();
            for (auto it = props.begin(); it != props.end(); ++it) {
                [keySet addObject:stringFromTagLibString(it->first)];
            }
        }
        if (ID3v1::Tag *id3v1 = [self getID3v1Tag:file]) {
            PropertyMap props = id3v1->properties();
            for (auto it = props.begin(); it != props.end(); ++it) {
                [keySet addObject:stringFromTagLibString(it->first)];
            }
        }
        return [keySet allObjects];
    }
    
    // 其他格式
    PropertyMap props = file->properties();
    NSMutableArray<NSString *> *keys = [NSMutableArray array];
    for (auto it = props.begin(); it != props.end(); ++it) {
        [keys addObject:stringFromTagLibString(it->first)];
    }
    return keys;
}

- (NSArray<NSDictionary<NSString *, NSString *> *> *)allPropertiesRaw {
    if (!self.isValid) return @[];
    
    File *file = _fileRef->file();
    if (!file) return @[];
    
    NSMutableArray<NSDictionary<NSString *, NSString *> *> *result = [NSMutableArray array];
    
    // Helper to add properties from a PropertyMap
    auto addProps = [&result](const PropertyMap &props, NSString *source) {
        for (auto it = props.begin(); it != props.end(); ++it) {
            NSString *key = stringFromTagLibString(it->first);
            NSString *value = it->second.isEmpty() ? @"" : stringFromTagLibString(it->second.front());
            [result addObject:@{@"source": source, @"key": key, @"value": value}];
        }
    };
    
    // MPEG (MP3): ID3v2, ID3v1, APE
    if (auto *mpegFile = dynamic_cast<MPEG::File *>(file)) {
        if (ID3v2::Tag *tag = mpegFile->ID3v2Tag(false)) {
            addProps(tag->properties(), @"ID3v2");
        }
        if (ID3v1::Tag *tag = mpegFile->ID3v1Tag()) {
            addProps(tag->properties(), @"ID3v1");
        }
        if (APE::Tag *tag = mpegFile->APETag(false)) {
            addProps(tag->properties(), @"APE");
        }
        return result;
    }
    
    // FLAC: Xiph Comment, ID3v2, ID3v1
    if (auto *flacFile = dynamic_cast<FLAC::File *>(file)) {
        if (Ogg::XiphComment *tag = flacFile->xiphComment(false)) {
            addProps(tag->properties(), @"Xiph");
        }
        if (ID3v2::Tag *tag = flacFile->ID3v2Tag(false)) {
            addProps(tag->properties(), @"ID3v2");
        }
        if (ID3v1::Tag *tag = flacFile->ID3v1Tag()) {
            addProps(tag->properties(), @"ID3v1");
        }
        return result;
    }
    
    // MP4/M4A
    if (auto *mp4File = dynamic_cast<MP4::File *>(file)) {
        if (MP4::Tag *tag = mp4File->tag()) {
            addProps(tag->properties(), @"MP4");
        }
        return result;
    }
    
    // Ogg Vorbis/Opus/Speex/FLAC
    if (Ogg::XiphComment *xiph = [self xiphCommentFromFile:file]) {
        addProps(xiph->properties(), @"Xiph");
        return result;
    }
    
    // ASF/WMA
    if (auto *asfFile = dynamic_cast<ASF::File *>(file)) {
        if (ASF::Tag *tag = asfFile->tag()) {
            addProps(tag->properties(), @"ASF");
        }
        return result;
    }
    
    // APE/WavPack/MPC
    if (APE::Tag *ape = [self apeTagFromFile:file]) {
        addProps(ape->properties(), @"APE");
        // Also check ID3v1
        if (ID3v1::Tag *id3v1 = [self getID3v1Tag:file]) {
            addProps(id3v1->properties(), @"ID3v1");
        }
        return result;
    }
    
    // WAV/AIFF/DSF/DSDIFF/TrueAudio (ID3v2-based)
    if (ID3v2::Tag *id3v2 = [self getID3v2TagForRead:file]) {
        addProps(id3v2->properties(), @"ID3v2");
        if (ID3v1::Tag *id3v1 = [self getID3v1Tag:file]) {
            addProps(id3v1->properties(), @"ID3v1");
        }
        return result;
    }
    
    // Fallback: use generic properties
    addProps(file->properties(), @"Default");
    return result;
}

- (BOOL)removeAllTags {
    if (!self.isValid) return NO;
    
    File *file = _fileRef->file();
    if (!file) return NO;
    
    // MPEG (MP3): strip all tag types
    if (auto *mpegFile = dynamic_cast<MPEG::File *>(file)) {
        return mpegFile->strip(MPEG::File::AllTags);
    }
    
    // FLAC: strip all tag types
    if (auto *flacFile = dynamic_cast<FLAC::File *>(file)) {
        flacFile->removePictures();
        if (flacFile->xiphComment(false)) {
            flacFile->xiphComment()->setProperties({});
        }
        if (flacFile->ID3v2Tag(false)) {
            flacFile->strip(FLAC::File::ID3v2);
        }
        if (flacFile->ID3v1Tag()) {
            flacFile->strip(FLAC::File::ID3v1);
        }
        return YES;
    }
    
    // MP4/M4A
    if (auto *mp4File = dynamic_cast<MP4::File *>(file)) {
        if (MP4::Tag *tag = mp4File->tag()) {
            tag->setProperties({});
            mp4File->setComplexProperties("PICTURE", {});
        }
        return YES;
    }
    
    // Ogg formats
    if (Ogg::XiphComment *xiph = [self xiphCommentFromFile:file]) {
        xiph->setProperties({});
        xiph->removeAllPictures();
        return YES;
    }
    
    // ASF/WMA
    if (auto *asfFile = dynamic_cast<ASF::File *>(file)) {
        if (ASF::Tag *tag = asfFile->tag()) {
            tag->setProperties({});
            tag->removeItem("WM/Picture");
        }
        return YES;
    }
    
    // APE
    if (auto *apeFile = dynamic_cast<APE::File *>(file)) {
        apeFile->strip(APE::File::AllTags);
        return YES;
    }
    
    // WavPack
    if (auto *wavpackFile = dynamic_cast<WavPack::File *>(file)) {
        wavpackFile->strip(WavPack::File::AllTags);
        return YES;
    }
    
    // MPC
    if (auto *mpcFile = dynamic_cast<MPC::File *>(file)) {
        mpcFile->strip(MPC::File::AllTags);
        return YES;
    }
    
    // TrueAudio
    if (auto *ttaFile = dynamic_cast<TrueAudio::File *>(file)) {
        ttaFile->strip(TrueAudio::File::AllTags);
        return YES;
    }
    
    // WAV
    if (auto *wavFile = dynamic_cast<RIFF::WAV::File *>(file)) {
        wavFile->strip(RIFF::WAV::File::AllTags);
        return YES;
    }
    
    // AIFF
    if (auto *aiffFile = dynamic_cast<RIFF::AIFF::File *>(file)) {
        if (aiffFile->tag()) {
            aiffFile->tag()->setProperties({});
        }
        return YES;
    }
    
    // DSF
    if (auto *dsfFile = dynamic_cast<DSF::File *>(file)) {
        if (dsfFile->tag()) {
            dsfFile->tag()->setProperties({});
        }
        return YES;
    }
    
    // DSDIFF
    if (auto *dsdiffFile = dynamic_cast<DSDIFF::File *>(file)) {
        if (dsdiffFile->ID3v2Tag(false)) {
            dsdiffFile->ID3v2Tag()->setProperties({});
        }
        return YES;
    }
    
    // Fallback: clear properties
    file->setProperties({});
    return YES;
}

// MARK: - Picture Operations for MPEG (ID3v2)

- (NSArray<TLPicture *> *)picturesFromMPEG:(MPEG::File *)mpegFile {
    NSMutableArray<TLPicture *> *result = [NSMutableArray array];
    
    ID3v2::Tag *tag = mpegFile->ID3v2Tag(false);
    if (!tag) return result;
    
    const ID3v2::FrameList &frames = tag->frameList("APIC");
    for (auto it = frames.begin(); it != frames.end(); ++it) {
        auto *picFrame = dynamic_cast<ID3v2::AttachedPictureFrame *>(*it);
        if (picFrame) {
            TLPicture *pic = [[TLPicture alloc]
                initWithData:nsDataFromByteVector(picFrame->picture())
                    mimeType:stringFromTagLibString(picFrame->mimeType())
                 description:stringFromTagLibString(picFrame->description())
                 pictureType:pictureTypeToString(picFrame->type())];
            [result addObject:pic];
        }
    }
    return result;
}

- (BOOL)addPictureToMPEG:(MPEG::File *)mpegFile picture:(TLPicture *)picture {
    ID3v2::Tag *tag = mpegFile->ID3v2Tag(true);
    if (!tag) return NO;
    
    auto *frame = new ID3v2::AttachedPictureFrame();
    frame->setPicture(byteVectorFromNSData(picture.data));
    frame->setMimeType(tagLibStringFromNSString(picture.mimeType));
    frame->setDescription(tagLibStringFromNSString(picture.pictureDescription));
    frame->setType((ID3v2::AttachedPictureFrame::Type)pictureTypeFromString(picture.pictureType));
    
    tag->addFrame(frame);
    return YES;
}

- (BOOL)removePictureFromMPEGAtIndex:(MPEG::File *)mpegFile index:(NSInteger)index {
    ID3v2::Tag *tag = mpegFile->ID3v2Tag(false);
    if (!tag) return NO;
    
    const ID3v2::FrameList &frames = tag->frameList("APIC");
    if (index < 0 || index >= (NSInteger)frames.size()) return NO;
    
    auto it = frames.begin();
    std::advance(it, index);
    tag->removeFrame(*it, true);
    return YES;
}

- (NSInteger)removePicturesFromMPEGOfType:(MPEG::File *)mpegFile type:(NSString *)typeString {
    ID3v2::Tag *tag = mpegFile->ID3v2Tag(false);
    if (!tag) return 0;
    
    int targetType = pictureTypeFromString(typeString);
    NSInteger removedCount = 0;
    
    const ID3v2::FrameList frames = tag->frameList("APIC"); // Copy to avoid iterator invalidation
    for (auto *frame : frames) {
        auto *picFrame = dynamic_cast<ID3v2::AttachedPictureFrame *>(frame);
        if (picFrame && picFrame->type() == targetType) {
            tag->removeFrame(frame, true);
            removedCount++;
        }
    }
    return removedCount;
}

- (BOOL)removeAllPicturesFromMPEG:(MPEG::File *)mpegFile {
    ID3v2::Tag *tag = mpegFile->ID3v2Tag(false);
    if (!tag) return YES; // No tag = no pictures = success
    
    tag->removeFrames("APIC");
    return YES;
}

// MARK: - Picture Operations for FLAC

- (NSArray<TLPicture *> *)picturesFromFLAC:(FLAC::File *)flacFile {
    NSMutableArray<TLPicture *> *result = [NSMutableArray array];
    
    const List<FLAC::Picture *> &pics = flacFile->pictureList();
    for (auto it = pics.begin(); it != pics.end(); ++it) {
        FLAC::Picture *pic = *it;
        TLPicture *tlPic = [[TLPicture alloc]
            initWithData:nsDataFromByteVector(pic->data())
                mimeType:stringFromTagLibString(pic->mimeType())
             description:stringFromTagLibString(pic->description())
             pictureType:pictureTypeToString(pic->type())];
        [result addObject:tlPic];
    }
    return result;
}

- (BOOL)addPictureToFLAC:(FLAC::File *)flacFile picture:(TLPicture *)picture {
    auto *pic = new FLAC::Picture();
    pic->setData(byteVectorFromNSData(picture.data));
    pic->setMimeType(tagLibStringFromNSString(picture.mimeType));
    pic->setDescription(tagLibStringFromNSString(picture.pictureDescription));
    pic->setType((FLAC::Picture::Type)pictureTypeFromString(picture.pictureType));
    
    flacFile->addPicture(pic);
    return YES;
}

- (BOOL)removePictureFromFLACAtIndex:(FLAC::File *)flacFile index:(NSInteger)index {
    const List<FLAC::Picture *> &pics = flacFile->pictureList();
    if (index < 0 || index >= (NSInteger)pics.size()) return NO;
    
    auto it = pics.begin();
    std::advance(it, index);
    flacFile->removePicture(*it, true);
    return YES;
}

- (BOOL)removeAllPicturesFromFLAC:(FLAC::File *)flacFile {
    flacFile->removePictures();
    return YES;
}

// MARK: - Picture Operations for MP4

- (NSArray<TLPicture *> *)picturesFromMP4:(MP4::File *)mp4File {
    NSMutableArray<TLPicture *> *result = [NSMutableArray array];
    
    auto pictures = mp4File->complexProperties("PICTURE");
    for (const auto &pic : pictures) {
        ByteVector data = pic.value("data").value<ByteVector>();
        String mimeType = pic.value("mimeType").value<String>();
        String description = pic.value("description").value<String>();
        String pictureType = pic.value("pictureType").value<String>();
        
        TLPicture *tlPic = [[TLPicture alloc]
            initWithData:nsDataFromByteVector(data)
                mimeType:stringFromTagLibString(mimeType)
             description:stringFromTagLibString(description)
             pictureType:pictureType.isEmpty() ? @"Front Cover" : stringFromTagLibString(pictureType)];
        [result addObject:tlPic];
    }
    return result;
}

- (BOOL)addPictureToMP4:(MP4::File *)mp4File picture:(TLPicture *)picture {
    // Use setComplexProperties like the C API does
    VariantMap map;
    map["data"] = byteVectorFromNSData(picture.data);
    map["mimeType"] = tagLibStringFromNSString(picture.mimeType);
    map["pictureType"] = tagLibStringFromNSString(picture.pictureType);
    if (picture.pictureDescription.length > 0) {
        map["description"] = tagLibStringFromNSString(picture.pictureDescription);
    }
    
    // Get existing pictures and append new one
    auto existing = mp4File->complexProperties("PICTURE");
    existing.append(map);
    return mp4File->setComplexProperties("PICTURE", existing);
}

- (BOOL)removePictureFromMP4AtIndex:(MP4::File *)mp4File index:(NSInteger)index {
    auto pictures = mp4File->complexProperties("PICTURE");
    if (index < 0 || index >= (NSInteger)pictures.size()) return NO;
    
    auto it = pictures.begin();
    std::advance(it, index);
    pictures.erase(it);
    
    return mp4File->setComplexProperties("PICTURE", pictures);
}

- (BOOL)removeAllPicturesFromMP4:(MP4::File *)mp4File {
    return mp4File->setComplexProperties("PICTURE", {});
}

// MARK: - Picture Operations for Ogg/Xiph Comment (Vorbis, Opus, Speex, Ogg FLAC)

- (Ogg::XiphComment *)xiphCommentFromFile:(File *)file {
    if (auto *vorbis = dynamic_cast<Ogg::Vorbis::File *>(file)) {
        return vorbis->tag();
    }
    if (auto *opus = dynamic_cast<Ogg::Opus::File *>(file)) {
        return opus->tag();
    }
    if (auto *speex = dynamic_cast<Ogg::Speex::File *>(file)) {
        return speex->tag();
    }
    if (auto *oggFlac = dynamic_cast<Ogg::FLAC::File *>(file)) {
        return oggFlac->tag();
    }
    return nullptr;
}

- (NSArray<TLPicture *> *)picturesFromXiph:(Ogg::XiphComment *)tag {
    NSMutableArray<TLPicture *> *result = [NSMutableArray array];
    if (!tag) return result;
    
    const List<FLAC::Picture *> pics = tag->pictureList();
    for (auto *pic : pics) {
        TLPicture *tlPic = [[TLPicture alloc]
            initWithData:nsDataFromByteVector(pic->data())
                mimeType:stringFromTagLibString(pic->mimeType())
             description:stringFromTagLibString(pic->description())
             pictureType:pictureTypeToString(pic->type())];
        [result addObject:tlPic];
    }
    return result;
}

- (BOOL)addPictureToXiph:(Ogg::XiphComment *)tag picture:(TLPicture *)picture {
    if (!tag) return NO;
    
    auto *pic = new FLAC::Picture();
    pic->setData(byteVectorFromNSData(picture.data));
    pic->setMimeType(tagLibStringFromNSString(picture.mimeType));
    pic->setDescription(tagLibStringFromNSString(picture.pictureDescription));
    pic->setType((FLAC::Picture::Type)pictureTypeFromString(picture.pictureType));
    
    tag->addPicture(pic);
    return YES;
}

- (BOOL)removePictureFromXiphAtIndex:(Ogg::XiphComment *)tag index:(NSInteger)index {
    if (!tag) return NO;
    
    const List<FLAC::Picture *> pics = tag->pictureList();
    if (index < 0 || index >= (NSInteger)pics.size()) return NO;
    
    auto it = pics.begin();
    std::advance(it, index);
    tag->removePicture(*it, true);
    return YES;
}

- (BOOL)removeAllPicturesFromXiph:(Ogg::XiphComment *)tag {
    if (!tag) return YES;
    tag->removeAllPictures();
    return YES;
}

// MARK: - Picture Operations for ASF (WMA/WMV)

- (NSArray<TLPicture *> *)picturesFromASF:(ASF::File *)asfFile {
    NSMutableArray<TLPicture *> *result = [NSMutableArray array];
    
    ASF::Tag *tag = asfFile->tag();
    if (!tag) return result;
    
    const ASF::AttributeListMap &attrs = tag->attributeListMap();
    if (!attrs.contains("WM/Picture")) return result;
    
    const ASF::AttributeList &pics = attrs["WM/Picture"];
    for (const auto &attr : pics) {
        ASF::Picture pic = attr.toPicture();
        TLPicture *tlPic = [[TLPicture alloc]
            initWithData:nsDataFromByteVector(pic.picture())
                mimeType:stringFromTagLibString(pic.mimeType())
             description:stringFromTagLibString(pic.description())
             pictureType:pictureTypeToString(pic.type())];
        [result addObject:tlPic];
    }
    return result;
}

- (BOOL)addPictureToASF:(ASF::File *)asfFile picture:(TLPicture *)picture {
    ASF::Tag *tag = asfFile->tag();
    if (!tag) return NO;
    
    ASF::Picture pic;
    pic.setPicture(byteVectorFromNSData(picture.data));
    pic.setMimeType(tagLibStringFromNSString(picture.mimeType));
    pic.setDescription(tagLibStringFromNSString(picture.pictureDescription));
    pic.setType((ASF::Picture::Type)pictureTypeFromString(picture.pictureType));
    
    tag->addAttribute("WM/Picture", ASF::Attribute(pic));
    return YES;
}

- (BOOL)removePictureFromASFAtIndex:(ASF::File *)asfFile index:(NSInteger)index {
    ASF::Tag *tag = asfFile->tag();
    if (!tag) return NO;
    
    if (!tag->attributeListMap().contains("WM/Picture")) return NO;
    
    ASF::AttributeList pics = tag->attribute("WM/Picture");
    if (index < 0 || index >= (NSInteger)pics.size()) return NO;
    
    auto it = pics.begin();
    std::advance(it, index);
    pics.erase(it);
    
    tag->removeItem("WM/Picture");
    for (const auto &pic : pics) {
        tag->addAttribute("WM/Picture", pic);
    }
    return YES;
}

- (BOOL)removeAllPicturesFromASF:(ASF::File *)asfFile {
    ASF::Tag *tag = asfFile->tag();
    if (!tag) return YES;
    tag->removeItem("WM/Picture");
    return YES;
}

// MARK: - Picture Operations for APE Tag (APE, WavPack, MPC)

- (APE::Tag *)apeTagFromFile:(File *)file {
    if (auto *ape = dynamic_cast<APE::File *>(file)) {
        return ape->APETag(false);
    }
    if (auto *wavpack = dynamic_cast<WavPack::File *>(file)) {
        return wavpack->APETag(false);
    }
    if (auto *mpc = dynamic_cast<MPC::File *>(file)) {
        return mpc->APETag(false);
    }
    return nullptr;
}

- (APE::Tag *)apeTagFromFileCreate:(File *)file {
    if (auto *ape = dynamic_cast<APE::File *>(file)) {
        return ape->APETag(true);
    }
    if (auto *wavpack = dynamic_cast<WavPack::File *>(file)) {
        return wavpack->APETag(true);
    }
    if (auto *mpc = dynamic_cast<MPC::File *>(file)) {
        return mpc->APETag(true);
    }
    return nullptr;
}

- (NSArray<TLPicture *> *)picturesFromAPE:(APE::Tag *)tag {
    NSMutableArray<TLPicture *> *result = [NSMutableArray array];
    if (!tag) return result;
    
    // APE stores covers as binary items with key "Cover Art (Front)", "Cover Art (Back)", etc.
    static const char *coverKeys[] = {
        "Cover Art (Front)", "Cover Art (Back)", "Cover Art (Other)",
        "Cover Art (Media)", "Cover Art (Artist)", "Cover Art (Band)"
    };
    
    for (const char *key : coverKeys) {
        if (tag->itemListMap().contains(key)) {
            APE::Item item = tag->itemListMap()[key];
            if (item.type() == APE::Item::Binary) {
                ByteVector data = item.binaryData();
                // APE binary data starts with description (null-terminated) then image data
                int nullPos = data.find('\0');
                if (nullPos >= 0) {
                    ByteVector imageData = data.mid(nullPos + 1);
                    NSString *mimeType = @"image/jpeg"; // Default, would need magic byte detection for accuracy
                    
                    TLPicture *pic = [[TLPicture alloc]
                        initWithData:nsDataFromByteVector(imageData)
                            mimeType:mimeType
                         description:@""
                         pictureType:[NSString stringWithUTF8String:key]];
                    [result addObject:pic];
                }
            }
        }
    }
    return result;
}

- (BOOL)addPictureToAPE:(APE::Tag *)tag picture:(TLPicture *)picture {
    if (!tag) return NO;
    
    NSString *key = @"Cover Art (Front)";
    if ([picture.pictureType containsString:@"Back"]) {
        key = @"Cover Art (Back)";
    } else if ([picture.pictureType containsString:@"Artist"]) {
        key = @"Cover Art (Artist)";
    }
    
    // APE format: description + null byte + image data
    ByteVector data;
    data.append(ByteVector("", 1)); // Empty description + null
    data.append(byteVectorFromNSData(picture.data));
    
    tag->setItem([key UTF8String], APE::Item([key UTF8String], data, true));
    return YES;
}

- (BOOL)removeAllPicturesFromAPE:(APE::Tag *)tag {
    if (!tag) return YES;
    
    static const char *coverKeys[] = {
        "Cover Art (Front)", "Cover Art (Back)", "Cover Art (Other)",
        "Cover Art (Media)", "Cover Art (Artist)", "Cover Art (Band)"
    };
    
    for (const char *key : coverKeys) {
        tag->removeItem(key);
    }
    return YES;
}

// MARK: - Picture Operations for ID3v2-based formats (WAV, AIFF, DSF, DSDIFF, TrueAudio)

- (ID3v2::Tag *)id3v2TagFromFile:(File *)file {
    if (auto *wav = dynamic_cast<RIFF::WAV::File *>(file)) {
        return wav->ID3v2Tag();
    }
    if (auto *aiff = dynamic_cast<RIFF::AIFF::File *>(file)) {
        return aiff->tag(); // AIFF uses ID3v2
    }
    if (auto *dsf = dynamic_cast<DSF::File *>(file)) {
        return dsf->tag();
    }
    if (auto *dsdiff = dynamic_cast<DSDIFF::File *>(file)) {
        return dsdiff->ID3v2Tag();
    }
    if (auto *tta = dynamic_cast<TrueAudio::File *>(file)) {
        return tta->ID3v2Tag();
    }
    return nullptr;
}

- (ID3v2::Tag *)id3v2TagFromFileCreate:(File *)file {
    if (auto *wav = dynamic_cast<RIFF::WAV::File *>(file)) {
        return wav->ID3v2Tag();
    }
    if (auto *aiff = dynamic_cast<RIFF::AIFF::File *>(file)) {
        return dynamic_cast<ID3v2::Tag *>(aiff->tag());
    }
    if (auto *dsf = dynamic_cast<DSF::File *>(file)) {
        return dsf->tag();
    }
    if (auto *dsdiff = dynamic_cast<DSDIFF::File *>(file)) {
        return dsdiff->ID3v2Tag(true);
    }
    if (auto *tta = dynamic_cast<TrueAudio::File *>(file)) {
        return tta->ID3v2Tag(true);
    }
    return nullptr;
}

- (NSArray<TLPicture *> *)picturesFromID3v2:(ID3v2::Tag *)tag {
    NSMutableArray<TLPicture *> *result = [NSMutableArray array];
    if (!tag) return result;
    
    const ID3v2::FrameList &frames = tag->frameList("APIC");
    for (auto it = frames.begin(); it != frames.end(); ++it) {
        auto *picFrame = dynamic_cast<ID3v2::AttachedPictureFrame *>(*it);
        if (picFrame) {
            TLPicture *pic = [[TLPicture alloc]
                initWithData:nsDataFromByteVector(picFrame->picture())
                    mimeType:stringFromTagLibString(picFrame->mimeType())
                 description:stringFromTagLibString(picFrame->description())
                 pictureType:pictureTypeToString(picFrame->type())];
            [result addObject:pic];
        }
    }
    return result;
}

- (BOOL)addPictureToID3v2:(ID3v2::Tag *)tag picture:(TLPicture *)picture {
    if (!tag) return NO;
    
    auto *frame = new ID3v2::AttachedPictureFrame();
    frame->setPicture(byteVectorFromNSData(picture.data));
    frame->setMimeType(tagLibStringFromNSString(picture.mimeType));
    frame->setDescription(tagLibStringFromNSString(picture.pictureDescription));
    frame->setType((ID3v2::AttachedPictureFrame::Type)pictureTypeFromString(picture.pictureType));
    
    tag->addFrame(frame);
    return YES;
}

- (BOOL)removeAllPicturesFromID3v2:(ID3v2::Tag *)tag {
    if (!tag) return YES;
    tag->removeFrames("APIC");
    return YES;
}

// MARK: - Public Interface

- (NSArray<TLPicture *> *)pictures {
    if (!self.isValid) return @[];
    
    File *file = _fileRef->file();
    
    // MPEG (MP3)
    if (auto *mpegFile = dynamic_cast<MPEG::File *>(file)) {
        return [self picturesFromMPEG:mpegFile];
    }
    // FLAC
    if (auto *flacFile = dynamic_cast<FLAC::File *>(file)) {
        return [self picturesFromFLAC:flacFile];
    }
    // MP4/M4A
    if (auto *mp4File = dynamic_cast<MP4::File *>(file)) {
        return [self picturesFromMP4:mp4File];
    }
    // ASF/WMA
    if (auto *asfFile = dynamic_cast<ASF::File *>(file)) {
        return [self picturesFromASF:asfFile];
    }
    // Ogg/Xiph Comment formats
    if (Ogg::XiphComment *xiph = [self xiphCommentFromFile:file]) {
        return [self picturesFromXiph:xiph];
    }
    // APE Tag formats
    if (APE::Tag *ape = [self apeTagFromFile:file]) {
        return [self picturesFromAPE:ape];
    }
    // ID3v2-based formats (WAV, AIFF, DSF, DSDIFF, TrueAudio)
    if (ID3v2::Tag *id3v2 = [self id3v2TagFromFile:file]) {
        return [self picturesFromID3v2:id3v2];
    }
    
    return @[];
}

- (NSInteger)pictureCount {
    return self.pictures.count;
}

- (TLPicture *)pictureAtIndex:(NSInteger)index {
    NSArray<TLPicture *> *pics = self.pictures;
    if (index < 0 || index >= (NSInteger)pics.count) return nil;
    return pics[index];
}

- (BOOL)addPicture:(TLPicture *)picture {
    if (!self.isValid) return NO;
    
    File *file = _fileRef->file();
    
    // MPEG (MP3)
    if (auto *mpegFile = dynamic_cast<MPEG::File *>(file)) {
        return [self addPictureToMPEG:mpegFile picture:picture];
    }
    // FLAC
    if (auto *flacFile = dynamic_cast<FLAC::File *>(file)) {
        return [self addPictureToFLAC:flacFile picture:picture];
    }
    // MP4/M4A
    if (auto *mp4File = dynamic_cast<MP4::File *>(file)) {
        return [self addPictureToMP4:mp4File picture:picture];
    }
    // ASF/WMA
    if (auto *asfFile = dynamic_cast<ASF::File *>(file)) {
        return [self addPictureToASF:asfFile picture:picture];
    }
    // Ogg/Xiph Comment formats
    if (Ogg::XiphComment *xiph = [self xiphCommentFromFile:file]) {
        return [self addPictureToXiph:xiph picture:picture];
    }
    // APE Tag formats
    if (APE::Tag *ape = [self apeTagFromFileCreate:file]) {
        return [self addPictureToAPE:ape picture:picture];
    }
    // ID3v2-based formats
    if (ID3v2::Tag *id3v2 = [self id3v2TagFromFileCreate:file]) {
        return [self addPictureToID3v2:id3v2 picture:picture];
    }
    
    return NO;
}

- (BOOL)removePictureAtIndex:(NSInteger)index {
    if (!self.isValid) return NO;
    
    File *file = _fileRef->file();
    
    // MPEG (MP3)
    if (auto *mpegFile = dynamic_cast<MPEG::File *>(file)) {
        return [self removePictureFromMPEGAtIndex:mpegFile index:index];
    }
    // FLAC
    if (auto *flacFile = dynamic_cast<FLAC::File *>(file)) {
        return [self removePictureFromFLACAtIndex:flacFile index:index];
    }
    // MP4/M4A
    if (auto *mp4File = dynamic_cast<MP4::File *>(file)) {
        return [self removePictureFromMP4AtIndex:mp4File index:index];
    }
    // ASF/WMA
    if (auto *asfFile = dynamic_cast<ASF::File *>(file)) {
        return [self removePictureFromASFAtIndex:asfFile index:index];
    }
    // Ogg/Xiph Comment formats
    if (Ogg::XiphComment *xiph = [self xiphCommentFromFile:file]) {
        return [self removePictureFromXiphAtIndex:xiph index:index];
    }
    // APE and ID3v2-based formats - use read-filter-rewrite approach
    // (They don't have convenient per-index removal)
    
    return NO;
}

- (NSInteger)removePicturesOfType:(NSString *)pictureType {
    if (!self.isValid) return 0;
    
    File *file = _fileRef->file();
    
    if (auto *mpegFile = dynamic_cast<MPEG::File *>(file)) {
        return [self removePicturesFromMPEGOfType:mpegFile type:pictureType];
    }
    
    // For other formats, use generic approach
    NSArray<TLPicture *> *currentPics = self.pictures;
    NSMutableArray<TLPicture *> *remaining = [NSMutableArray array];
    NSInteger removedCount = 0;
    
    for (TLPicture *pic in currentPics) {
        if ([pic.pictureType isEqualToString:pictureType]) {
            removedCount++;
        } else {
            [remaining addObject:pic];
        }
    }
    
    if (removedCount > 0) {
        [self removeAllPictures];
        for (TLPicture *pic in remaining) {
            [self addPicture:pic];
        }
    }
    
    return removedCount;
}

- (BOOL)removeAllPictures {
    if (!self.isValid) return NO;
    
    File *file = _fileRef->file();
    
    // MPEG (MP3)
    if (auto *mpegFile = dynamic_cast<MPEG::File *>(file)) {
        return [self removeAllPicturesFromMPEG:mpegFile];
    }
    // FLAC
    if (auto *flacFile = dynamic_cast<FLAC::File *>(file)) {
        return [self removeAllPicturesFromFLAC:flacFile];
    }
    // MP4/M4A
    if (auto *mp4File = dynamic_cast<MP4::File *>(file)) {
        return [self removeAllPicturesFromMP4:mp4File];
    }
    // ASF/WMA
    if (auto *asfFile = dynamic_cast<ASF::File *>(file)) {
        return [self removeAllPicturesFromASF:asfFile];
    }
    // Ogg/Xiph Comment formats
    if (Ogg::XiphComment *xiph = [self xiphCommentFromFile:file]) {
        return [self removeAllPicturesFromXiph:xiph];
    }
    // APE Tag formats
    if (APE::Tag *ape = [self apeTagFromFile:file]) {
        return [self removeAllPicturesFromAPE:ape];
    }
    // ID3v2-based formats
    if (ID3v2::Tag *id3v2 = [self id3v2TagFromFile:file]) {
        return [self removeAllPicturesFromID3v2:id3v2];
    }
    
    return NO;
}

- (BOOL)replacePictureAtIndex:(NSInteger)index withPicture:(TLPicture *)picture {
    if (![self removePictureAtIndex:index]) return NO;
    return [self addPicture:picture];
}

- (BOOL)save {
    if (!self.isValid) return NO;
    return _fileRef->save();
}

@end
