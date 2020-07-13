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

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder {
    self = [super init];
    if (!self) {
       return nil;
    }
    unsigned int propertyCount;
    objc_property_t* properties_t = class_copyPropertyList([self class], &propertyCount);
    for (int i = 0; i < propertyCount; i++) {
        objc_property_t t_property = properties_t[i];
        NSString *attributeName = [NSString stringWithUTF8String:property_getName(t_property)];
        [self setValue:[coder decodeObjectForKey:attributeName] forKey:attributeName];
    }
    return self;
}

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    unsigned int propertyCount;
    objc_property_t* properties_t = class_copyPropertyList([self class], &propertyCount);
    for (int i = 0; i < propertyCount; i++) {
        objc_property_t t_property = properties_t[i];
        NSString *attributeName = [NSString stringWithUTF8String:property_getName(t_property)];
        [coder encodeObject:[self valueForKey:attributeName] forKey:attributeName];
    }
}

- (void)cacheWithKay:(NSString *)key
{
    [[JKCache shareInstance] cacheObject:self forKey:key andTiemLimit:NSIntegerMax whenResult:nil];
}

@end
