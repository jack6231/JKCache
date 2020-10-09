//
//  JKCache.m
//  JKCache
//
//  Created by 王治恒 on 2020/3/6.
//  Copyright © 2020 王治恒. All rights reserved.
//

#import "JKCache.h"
#import "JKLRUCache.h"

@interface JKCache()
{
    JKLRUCache *_lurCache;
}
@end

@implementation JKCache

static JKCache *cacheInstance;
+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cacheInstance = [[super alloc] superInit];
    });
    return cacheInstance;
}

- (instancetype)superInit
{
    _lurCache = [[JKLRUCache alloc] init];
    return [super init];
}

- (void)cacheObject:(id<NSCoding>)object forKey:(NSString *)key whenResult:(JKCacheObjectBlock)result
{
    [_lurCache cacheObject:object forKey:key];
    [[JKFileCache cacheWithName:key] cacheObject:object cacheResult:result];
}

- (void)cacheObject:(id<NSCoding>)object forKey:(NSString *)key andTiemLimit:(NSTimeInterval)timeLimit whenResult:(JKCacheObjectBlock)result
{
    [_lurCache cacheObject:object forKey:key];
    [[JKFileCache cacheWithName:key] cacheObject:object withTimeLimit:timeLimit cacheResult:result];
}

- (void)cacheObject:(id<NSCoding>)object forKey:(NSString *)key withSerialize:(JKCacheSerializeBlock)serialize andDeserialize:(JKCacheDeserializeBlock)deserialize whenResult:(JKCacheObjectBlock)result
{
    [_lurCache cacheObject:object forKey:key];
    [[JKFileCache cacheWithName:key serialize:serialize deserialize:deserialize] cacheObject:object cacheResult:result];
}

- (void)cacheObject:(id<NSCoding>)object forKey:(NSString *)key withTiemLimit:(NSTimeInterval)timeLimit andSerialize:(JKCacheSerializeBlock)serialize andDeserialize:(JKCacheDeserializeBlock)deserialize whenResult:(JKCacheObjectBlock)result
{
    [[JKFileCache cacheWithName:key serialize:serialize deserialize:deserialize] cacheObject:object withTimeLimit:timeLimit cacheResult:result];
}

- (void)objectForKey:(NSString *)key whenResult:(JKCacheGetObjectBlock)result
{
    id object = [_lurCache objectForKey:key];
    if (object) {
        result(object, key);
        return;
    }
    [[JKFileCache cacheWithName:key] object:^(id object, NSString *key) {
        if (object) {
         [self->_lurCache cacheObject:object forKey:key];
        }
        result(object, key);
    }];
}

- (id)objectForKey:(NSString *)key
{
    id object = [_lurCache objectForKey:key];
    if (object) {
        return object;
    }
    
    return [[JKFileCache cacheWithName:key] object];
}

- (void)deleteObjectForKey:(NSString *)key whenResul:(JKCacheDeleteBlock)result
{
    [_lurCache removeForKey:key];
    [[JKFileCache cacheWithName:key] delete:result];
}

@end
