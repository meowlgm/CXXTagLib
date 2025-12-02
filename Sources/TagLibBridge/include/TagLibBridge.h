#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Picture data structure for bridging
@interface TLPicture : NSObject

@property (nonatomic, strong) NSData *data;
@property (nonatomic, copy) NSString *mimeType;
@property (nonatomic, copy) NSString *pictureDescription;
@property (nonatomic, copy) NSString *pictureType;

- (instancetype)initWithData:(NSData *)data
                    mimeType:(NSString *)mimeType
                 description:(NSString *)description
                 pictureType:(NSString *)pictureType;

@end

/// Audio properties structure
@interface TLAudioProperties : NSObject

@property (nonatomic, readonly) NSInteger duration;    // seconds
@property (nonatomic, readonly) NSInteger bitrate;     // kbps
@property (nonatomic, readonly) NSInteger sampleRate;  // Hz
@property (nonatomic, readonly) NSInteger channels;

- (instancetype)initWithDuration:(NSInteger)duration
                         bitrate:(NSInteger)bitrate
                      sampleRate:(NSInteger)sampleRate
                        channels:(NSInteger)channels;

@end

/// Bridge class for TagLib C++ operations
@interface TagLibBridge : NSObject

/// Open an audio file
/// @param path Path to the audio file
/// @return Instance or nil if failed
- (nullable instancetype)initWithPath:(NSString *)path;

/// Check if file is valid
@property (nonatomic, readonly) BOOL isValid;

/// Get file type (e.g., "MPEG", "FLAC", "MP4")
@property (nonatomic, readonly, nullable) NSString *fileType;

// MARK: - Audio Properties

/// Get audio properties (duration, bitrate, etc.)
@property (nonatomic, readonly, nullable) TLAudioProperties *audioProperties;

// MARK: - Basic Tags

@property (nonatomic, copy, nullable) NSString *title;
@property (nonatomic, copy, nullable) NSString *artist;
@property (nonatomic, copy, nullable) NSString *album;
@property (nonatomic, copy, nullable) NSString *comment;
@property (nonatomic, copy, nullable) NSString *genre;
@property (nonatomic, assign) NSInteger year;
@property (nonatomic, assign) NSInteger track;

// MARK: - Extended Tags (via PropertyMap)

/// Get property value for key
- (nullable NSString *)propertyForKey:(NSString *)key;

/// Set property value for key
- (void)setProperty:(nullable NSString *)value forKey:(NSString *)key;

/// Get all property keys (merged, no duplicates)
- (NSArray<NSString *> *)allPropertyKeys;

/// Get all properties as array of key-value pairs (includes duplicates from different tag sources)
- (NSArray<NSDictionary<NSString *, NSString *> *> *)allPropertiesRaw;

/// Remove all tags from the file (ID3v1, ID3v2, APE, Xiph, etc.)
- (BOOL)removeAllTags;

// MARK: - Rating (POPM)

/// Get rating (0-255, or -1 if not set)
@property (nonatomic, readonly) NSInteger rating;

/// Set rating (0-255, set to -1 or negative to remove)
- (void)setRating:(NSInteger)rating;

/// Get play count (from POPM frame)
@property (nonatomic, readonly) NSUInteger playCount;

/// Set play count
- (void)setPlayCount:(NSUInteger)count;

// MARK: - Pictures

/// Get all pictures
- (NSArray<TLPicture *> *)pictures;

/// Get picture count
- (NSInteger)pictureCount;

/// Get picture at index
- (nullable TLPicture *)pictureAtIndex:(NSInteger)index;

/// Add a picture (append)
- (BOOL)addPicture:(TLPicture *)picture;

/// Remove picture at specific index
- (BOOL)removePictureAtIndex:(NSInteger)index;

/// Remove pictures of specific type
- (NSInteger)removePicturesOfType:(NSString *)pictureType;

/// Remove all pictures
- (BOOL)removeAllPictures;

/// Replace picture at index
- (BOOL)replacePictureAtIndex:(NSInteger)index withPicture:(TLPicture *)picture;

/// Save changes
- (BOOL)save;

@end

NS_ASSUME_NONNULL_END
