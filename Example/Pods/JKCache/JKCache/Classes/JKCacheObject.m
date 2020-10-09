//
//  JKCacheObject.m
//  Expecta
//
//  Created by 王治恒 on 2020/7/14.
//

#import <objc/runtime.h>
#import "JKCacheObject.h"
#import "JKCache.h"

@implementation JKCacheObject

JKCacheCodingImplementation

+ (instancetype)instanceForCache
{
    NSString *key = NSStringFromClass([self class]);
    return [self instanceForCacheWithKey:key];
}

+ (instancetype)instanceForCacheWithKey:(NSString *)key
{
    if (!key) return nil;
    id instance = [[JKCache shareInstance] objectForKey:key];
    if (![instance isKindOfClass:[self class]]) {
        return nil;
    }
    return instance;
}

- (void)cacheObject
{
    NSString *key = NSStringFromClass([self class]);
    [self cacheObjectWithKey:key];
}

- (void)cacheObjectWithKey:(NSString *)key
{
    if (!key) return;
    [[JKCache shareInstance] cacheObject:self forKey:key andTiemLimit:NSIntegerMax whenResult:nil];
}

@end
