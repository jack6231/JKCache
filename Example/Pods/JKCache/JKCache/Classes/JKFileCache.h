//
//  JKFileCache.h
//  JKCache
//
//  Created by 王治恒 on 2020/3/6.
//  Copyright © 2020 王治恒. All rights reserved.
//
//  1、该对象作为单个文件存储的对象，每个要操作的文件都会对应一个 JKFileCache 对象
//  2、该对象会以文件名作为单例条件，整个 APP 生命周期中只会创建一次
//  3、因为操作文件是一个耗时耗性能的操作，所以使用异步线程中操作，故需要 Block 进行结果回调
//  4、该对象是保证单个文件操作是线程安全的，所以可以在任意线程中调用该对象的方法
//  5、该对象使用 JKCacheManager 对象作为文件管理对象，每次 JKCacheManager 对象创建时都会检查一遍过期文件，调用本类方法进行删除处理
//  6、文件存储的默认时间是 90 天
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 序列化 Block
 默认使用 NSKeyedArchiver 进行序列化，缺点是只能序列化实现NSCoding的对象

 @param object 对象
 @param key 对象的key
 @return 序列化后的对象
 */
typedef NSData* _Nonnull(^JKCacheSerializeBlock)(id<NSCoding> _Nullable object, NSString * _Nullable key);

/**
 反序列化 Block
 默认使用 NSKeyedUnarchiver

 @param data 序列化后对象，直接从file中读取的 NSData 类型
 @param key 缓存对象的Key
 @return 反序列化后的对象本身
 */
typedef id<NSCoding> _Nonnull(^JKCacheDeserializeBlock)(NSData * _Nullable data, NSString * _Nullable key);

/**
 缓存结果的Block

 @param isSuccess YES：成功；NO：失败
 */
typedef void (^JKCacheObjectBlock)(BOOL isSuccess);

/**
 获取对象的Block

 @param object 获取到的对象
 @param key 对象的key
 */
typedef void (^JKCacheGetObjectBlock)(id _Nullable object, NSString * _Nullable key);

/**
 删除对象的Block

 @param isSuccess 删除是否成功，YES：成功；NO：是吧
 @param error 失败的详细信息 NSError 类型，为 nil 则说明成功
 */
typedef void (^JKCacheDeleteBlock)(BOOL isSuccess, NSError * _Nullable error);

@interface JKFileCache : NSObject

@property (nonatomic, strong, readonly) NSString * _Nullable name;   // 缓存对象的名称
@property (nonatomic, strong, readonly) NSString * _Nullable path;   // 缓存对象的路径


- (instancetype _Nullable )init __attribute__((unavailable("init方法不可用，请用cacheWithName:")));

+ (instancetype _Nullable )new __attribute__((unavailable("new方法不可用，请用cacheWithName:")));

/**
 获取该 file 的缓存对象，用于管理单个文件的操作
 使用“name”作为单例条件，保证每个 file 在应用启动后只创建一次

 @param name 文件名
 @return JKFileCache
 */
+ (instancetype _Nullable )cacheWithName:(NSString *_Nullable)name;

/**
 获取该 file 的缓存对象，用于管理单个文件的操作
 使用“name”作为单例条件，保证每个 file 在应用启动后只创建一次

 @param name 文件名
 @param serialize 序列化回调
 @param deserialize 反序列化回调
 @return JKFileCache
 */
+ (instancetype _Nullable )cacheWithName:(NSString *_Nullable)name serialize:(JKCacheSerializeBlock _Nullable )serialize deserialize:(JKCacheDeserializeBlock _Nullable )deserialize;

/**
 缓存对象

 @param object 缓存的对象
 @param cacheResult 缓存结果回调
 */
- (void)cacheObject:(id<NSCoding>_Nullable)object cacheResult:(JKCacheObjectBlock _Nullable )cacheResult;

/**
 缓存对象

 @param object 缓存对象
 @param timeLimit 缓存对象的时间单位是分钟
 @param cacheResult 缓存结果回调
 */
- (void)cacheObject:(id<NSCoding>_Nullable)object withTimeLimit:(NSTimeInterval)timeLimit cacheResult:(JKCacheObjectBlock _Nullable )cacheResult;

/**
 获取对象：异步

 @param result 获取对象的回调
 */
- (void)object:(JKCacheGetObjectBlock _Nullable )result;

/**
 获取对象：同步
 
 大文件建议使用异步读取对象回调
 */
- (id)object;

/**
 删除文件

 @param reuslt 删除对象的回调
 */
- (void)delete:(JKCacheDeleteBlock _Nullable )reuslt;

@end

NS_ASSUME_NONNULL_END
