//
//  JKFileCache.m
//  JKCache
//
//  Created by 王治恒 on 2020/3/6.
//  Copyright © 2020 王治恒. All rights reserved.
//

#import "JKFileCache.h"
#import <CommonCrypto/CommonCrypto.h>
#import <pthread.h>
#import "JKCacheManager.h"

@interface JKFileCache()
{
    dispatch_queue_t _queue;
    JKCacheSerializeBlock _serialize;     // 序列化回调block
    JKCacheDeserializeBlock _deserialize; // 反序列化回调block
}
@end

@implementation JKFileCache

static NSMapTable *globalInstances;
static pthread_mutex_t globalLock;

static void JKCachInitGlobal()
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pthread_mutex_init(&globalLock, NULL);
        globalInstances = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsWeakMemory capacity:0];
    });
}

static inline JKFileCache* JKCacheGetGlobal(NSString *path)
{
    if (!path.length) return nil;
    id cache = [globalInstances objectForKey:path];
    return cache;
}

static inline void JKCacheSetGlobal(JKFileCache *cache)
{
    if (!cache.path.length) return;
    [globalInstances setObject:cache forKey:cache.path];
}

static NSString *md5(NSString *string)
{
    const char *object = [string UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(object,(CC_LONG)strlen(object),result);
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < 16; i ++) {
        [hash appendFormat:@"%02X", result[i]];
    }
    return [hash lowercaseString];
}

+ (instancetype)cacheWithName:(NSString *)name
{
    return [JKFileCache cacheWithName:name serialize:nil deserialize:nil];
}

+ (instancetype)cacheWithName:(NSString *)name serialize:(JKCacheSerializeBlock)serialize deserialize:(JKCacheDeserializeBlock)deserialize
{

    JKCachInitGlobal();
    pthread_mutex_lock(&globalLock);
    
    NSString *cacheFolder = [[JKCacheManager shareInstance] preFilePath];
    NSString *path = [cacheFolder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", md5(name)]];
    JKFileCache *instance = JKCacheGetGlobal(path);
    if (instance) {
        pthread_mutex_unlock(&globalLock);
        return instance;
    }
    
    instance = [[self alloc] initWithPath:path serialize:serialize deserialize:deserialize];
    instance->_name = name;
    JKCacheSetGlobal(instance);
    pthread_mutex_unlock(&globalLock);
    
    return instance;
}

- (instancetype)initWithPath:(NSString *)path serialize:(JKCacheSerializeBlock)serialize deserialize:(JKCacheDeserializeBlock)deserialize
{
    self = [super init];
    if (self) {
        _path = path;
        NSLog(@"----path:%@", _path);

        // 创建一个并发队列，用于操作任务
        _queue = dispatch_queue_create("com.JK.cache.disk", DISPATCH_QUEUE_SERIAL);
        
        if (serialize) {
            _serialize = serialize;
        } else {
            _serialize = [self defultSerializeBlock];
        }
        
        if (deserialize) {
            _deserialize = deserialize;
        } else {
            _deserialize = [self defultDeserializeBlock];
        }
    }
    return self;
}

-(JKCacheSerializeBlock)defultSerializeBlock
{
    return ^NSData* (id<NSCoding> object, NSString *key){
        NSData *data = nil;
        @try {
            data = [NSKeyedArchiver archivedDataWithRootObject:object];
        }
        @catch (NSException *exception) {
            NSLog(@"JKCache serialized object failure：%@", exception);
        }
        return data;
    };
}

- (JKCacheDeserializeBlock)defultDeserializeBlock
{
    return ^id<NSCoding> (NSData *data, NSString *key){
        id<NSCoding> object = nil;
        @try {
            object = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        }
        @catch (NSException *exception) {
            NSLog(@"JKCache deserialized object failure：%@", exception);
        }
        return object;
    };
}

- (void)cacheObject:(id<NSCoding>)object cacheResult:(JKCacheObjectBlock)cacheResult
{
    // 默认时间 90 天
    [self cacheObject:object withTimeLimit:90 * 24 * 60 cacheResult:cacheResult];
}

- (void)cacheObject:(id<NSCoding>)object withTimeLimit:(NSTimeInterval)timeLimit cacheResult:(JKCacheObjectBlock)cacheResult
{
    if (!object) {
        [self delete:^(BOOL isSuccess, NSError *error) {
            if (cacheResult) {
                cacheResult(isSuccess);
            }
        }];
        return;
    }
    dispatch_async(_queue, ^{
        NSData *data = self->_serialize(object, self->_name);
        [[JKCacheManager shareInstance] registFileInfo:self.name fileSize:data.length withTimeLimit:timeLimit];
        if (data) {
            [data writeToFile:self->_path atomically:YES];
        }
        if (cacheResult) {
            BOOL fileExistence = [[NSFileManager defaultManager] fileExistsAtPath:self->_path];
            cacheResult(fileExistence);
        }
    });
}

- (void)object:(JKCacheGetObjectBlock)result
{
    dispatch_async(_queue, ^{
        BOOL fileExistence = [[NSFileManager defaultManager] fileExistsAtPath:self->_path];
        if (!fileExistence) {
            result(nil, self->_name);
            return;
        }
        NSData *data = [NSData dataWithContentsOfFile:self->_path];
        id object;
        if (data) {
            object = self->_deserialize(data, self->_name);
        }
        result(object, self->_name);
    });
}

- (id)object
{
    BOOL fileExistence = [[NSFileManager defaultManager] fileExistsAtPath:self->_path];
    if (!fileExistence) {
        return nil;
    }
    NSData *data = [NSData dataWithContentsOfFile:self->_path];
    id object;
    if (data) {
        object = self->_deserialize(data, self->_name);
    }
    return object;
}

- (void)delete:(JKCacheDeleteBlock)reuslt
{
    dispatch_async(_queue, ^{
        NSError *error;
        [[NSFileManager defaultManager] removeItemAtPath:self->_path error:&error];
        BOOL fileExistence = [[NSFileManager defaultManager] fileExistsAtPath:self->_path];
        // 如果文件删除成功，则删除目录中数据
        if (!fileExistence) {
            [[JKCacheManager shareInstance] removeItemWithFileName:self.name];
        }
        reuslt(!fileExistence, error);
    });
}

@end
