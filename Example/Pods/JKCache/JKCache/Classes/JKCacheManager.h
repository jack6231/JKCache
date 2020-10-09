//
//  JKCacheManager.h
//  JKCache
//
//  Created by 王治恒 on 2020/3/6.
//  Copyright © 2020 王治恒. All rights reserved.
//
//  1、JKCacheManager 以单例的方式只创建一次
//  2、统一对外提供缓存目录
//  3、管理所有的 JKFileCache 对象
//  4、线程安全的
//  5、JKCacheManager 创建时读取文件缓存目录进行遍历并删除超出缓存时间的文件
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JKCacheManager : NSObject

@property (nonatomic, strong, readonly)NSString *preFilePath;

+ (instancetype)alloc __attribute__((unavailable("alloc方法不可用，请用shareInstance")));
- (instancetype)init __attribute__((unavailable("init方法不可用，请用shareInstance")));
+ (instancetype)new __attribute__((unavailable("new方法不可用，请用shareInstance")));
- (instancetype)copy __attribute__((unavailable("copy方法不可用，请用shareInstance")));

+ (instancetype)shareInstance;

/**
 注册缓存的文件

 @param name 文件名称
 @param size 文件大小
 @param timeLimit 文件缓存时间（单位：分钟）
 */
- (void)registFileInfo:(NSString *)name fileSize:(NSUInteger)size withTimeLimit:(NSTimeInterval)timeLimit;

/**
 从目录中删除该文件信息

 @param name 文件名称
 */
- (void)removeItemWithFileName:(NSString *)name;

@end

@interface JKCacheFileInfo : NSObject

- (instancetype)initWithName:(NSString *)name size:(NSUInteger)size timeLimit:(NSTimeInterval)timeLimit;

- (NSString *)fileName;

- (NSUInteger)fileSize;

- (NSTimeInterval)fileTimeLimit;

- (NSTimeInterval)fileCreateTime;

- (NSDictionary *)values;

- (void)format:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
