//
//  JKCacheObject.h
//  Expecta
//
//  Created by 王治恒 on 2020/7/14.
//
// 1、JKCacheObject 作为缓存类的基类
// 2、本类类名作为默认存取键值
// 3、多个实例存取使用 cacheObjectWithKey:\cacheInstanceWithKey: 传入对应键值
//

#import <Foundation/Foundation.h>
#import "JKCacheObject.h"

#define JKCacheCodingImplementation \
- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder { \
    self = [super init]; \
    if (!self) { \
       return nil; \
    } \
    unsigned int propertyCount; \
    objc_property_t* properties_t = class_copyPropertyList([self class], &propertyCount); \
    for (int i = 0; i < propertyCount; i++) { \
        objc_property_t t_property = properties_t[i]; \
        NSString *attributeName = [NSString stringWithUTF8String:property_getName(t_property)]; \
        [self setValue:[coder decodeObjectForKey:attributeName] forKey:attributeName]; \
    } \
    return self; \
} \
 \
- (void)encodeWithCoder:(nonnull NSCoder *)coder { \
    unsigned int propertyCount; \
    objc_property_t* properties_t = class_copyPropertyList([self class], &propertyCount); \
    for (int i = 0; i < propertyCount; i++) { \
        objc_property_t t_property = properties_t[i]; \
        NSString *attributeName = [NSString stringWithUTF8String:property_getName(t_property)]; \
        [coder encodeObject:[self valueForKey:attributeName] forKey:attributeName]; \
    } \
}

NS_ASSUME_NONNULL_BEGIN

@interface JKCacheObject : NSObject<NSCoding>

/// 从磁盘读取缓存实例
+ (instancetype)instanceForCache;

/// 根据 key 值从磁盘读取缓存实例
/// @param key 实例对应的键值
+ (instancetype)instanceForCacheWithKey:(NSString *)key;

/// 缓存实例
- (void)cacheObject;

/// 根据 key 值缓存实例
/// @param key 实例对应的键值
- (void)cacheObjectWithKey:(NSString *)key;


@end

NS_ASSUME_NONNULL_END
