//
//  JKCacheManager.m
//  JKCache
//
//  Created by 王治恒 on 2020/3/6.
//  Copyright © 2020 王治恒. All rights reserved.
//

#import "JKCacheManager.h"
#import <pthread.h>
#import "JKFileCache.h"

@interface JKCacheFileInfo()
{
    NSDictionary *_dict;
}
@end

@implementation JKCacheFileInfo

NSString *const JKCacheFileNameKey = @"file_name";
NSString *const JKCacheFileSizeKey = @"file_size";
NSString *const JKCacheCreateFileTimeKey = @"file_caret_time";
NSString *const JKCacheFileTimeLimitKey = @"file_time_limit";

- (instancetype)initWithName:(NSString *)name size:(NSUInteger)size timeLimit:(NSTimeInterval)timeLimit
{
    self = [self init];
    if (self) {
        _dict = @{JKCacheFileNameKey:name,
                  JKCacheFileSizeKey:@(size),
                  JKCacheFileTimeLimitKey:@(timeLimit),
                  JKCacheCreateFileTimeKey:@([[NSDate date] timeIntervalSince1970])
                  };
    }
    return self;
}

- (NSString *)fileName
{
    return _dict[JKCacheFileNameKey];
}

- (NSUInteger)fileSize
{
    NSNumber *value = _dict[JKCacheFileSizeKey];
    return value.unsignedIntegerValue;
}

- (double)fileTimeLimit
{
    NSNumber *value = _dict[JKCacheFileTimeLimitKey];
    return value.doubleValue;
}

- (NSTimeInterval)fileCreateTime
{
    NSNumber *value = _dict[JKCacheCreateFileTimeKey];
    return value.doubleValue;
}

- (NSDictionary *)values
{
    return _dict;
}

- (void)format:(NSDictionary *)dict
{
    _dict = dict;
}

@end

@interface JKCacheManager()
{
    pthread_mutex_t _lock;
    NSMutableDictionary *catalogDict;
}
@end

@implementation JKCacheManager

NSString *const CatalogFileName = @"durian_catalog.plist";

static JKCacheManager *managerInstance;
+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        managerInstance = [[super alloc] preInit];
        
        pthread_mutex_init(&managerInstance->_lock, nil);
        
        NSString *cacheFolder = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
        managerInstance->_preFilePath = [cacheFolder stringByAppendingPathComponent:@"Durian"];
        BOOL isExists = [[NSFileManager defaultManager] fileExistsAtPath:managerInstance->_preFilePath];
        if (!isExists) {
            [[NSFileManager defaultManager] createDirectoryAtPath:managerInstance->_preFilePath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        managerInstance->catalogDict = [[NSMutableDictionary alloc] init];
        [managerInstance trimCatalog];
    });
    return managerInstance;
}

- (instancetype)preInit
{
    return [super init];
}

- (void)registFileInfo:(NSString *)name  fileSize:(NSUInteger)size withTimeLimit:(NSTimeInterval)timeLimit
{
    pthread_mutex_lock(&_lock);
    if ([name isEqualToString:CatalogFileName]) {
        pthread_mutex_unlock(&_lock);
        return;
    }
    // 传入的时间戳为分钟，需要转成秒单位
    JKCacheFileInfo *info = [[JKCacheFileInfo alloc] initWithName:name size:size timeLimit:timeLimit * 60];
    [self->catalogDict setObject:info.values forKey:name];
    [[JKFileCache cacheWithName:CatalogFileName] cacheObject:[self->catalogDict copy] cacheResult:nil];
    pthread_mutex_unlock(&_lock);
}

- (void)removeItemWithFileName:(NSString *)name
{
    pthread_mutex_lock(&_lock);
    [self->catalogDict removeObjectForKey:name];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [[JKFileCache cacheWithName:CatalogFileName] cacheObject:self->catalogDict cacheResult:^(BOOL isSuccess) {
            NSLog(@"regist fileCache %@", isSuccess ? @"SUCCESS" : @"FAIL");
        }];
    });
    pthread_mutex_unlock(&_lock);
}

- (void)trimCatalog
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [[JKFileCache cacheWithName:CatalogFileName] object:^(id object, NSString *key) {
            if (object) {
                pthread_mutex_lock(&self->_lock);
                NSMutableDictionary *catalogDict = [[NSMutableDictionary alloc] initWithDictionary:object];
                [catalogDict addEntriesFromDictionary:self->catalogDict];
                [self->catalogDict setDictionary:catalogDict];
                pthread_mutex_unlock(&self->_lock);
                
                NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
                [catalogDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                    JKCacheFileInfo *info = [[JKCacheFileInfo alloc] init];
                    [info format:obj];
                    if (info.fileCreateTime + info.fileTimeLimit < currentTime) {
                        [[JKFileCache cacheWithName:key] delete:^(BOOL isSuccess, NSError *error) {
                            NSLog(@"JKCache delete file:%@ result: %@", key, isSuccess ? @"SUCCESS" : @"FAIL");
                        }];
                    }
                }];
            }
        }];
    });
}


@end
