//
//  JKCache.h
//  JKCache
//
//  Created by 王治恒 on 2020/3/6.
//  Copyright © 2020 王治恒. All rights reserved.
//
//  1、JKCache 以单例的形式存在提供API调用
//  2、使用 JKLRUCache 作为二级缓存，只会在本来创建一次
//  3、使用 JKFileCache 作为三级缓存，每个对象都会创建一次 fileCache 对象并将创建后的对象进行内存缓存
//  4、二、三级缓存联动，优先取二级缓存，取三级缓存之后会赋值到二级缓存中
//  5、删除方法会同时删除二、三级缓存
//
//  TOTO 缓存时间策略还需优化
//

#import <Foundation/Foundation.h>
#import "JKFileCache.h"

NS_ASSUME_NONNULL_BEGIN

@interface JKCache : NSObject

+ (instancetype)alloc __attribute__((unavailable("alloc方法不可用，请用shareInstance")));
- (instancetype)init __attribute__((unavailable("init方法不可用，请用shareInstance")));
+ (instancetype)new __attribute__((unavailable("new方法不可用，请用shareInstance")));
- (instancetype)copy __attribute__((unavailable("copy方法不可用，请用shareInstance")));

+ (instancetype)shareInstance;

/**
 缓存对象
 
 @param object 缓存对象（对象必须实现NSCoding协议）
 @param key 缓存对象的key
 @param result 缓存对象结果回调
 */
- (void)cacheObject:(id<NSCoding>)object forKey:(NSString *)key whenResult:(nullable JKCacheObjectBlock)result;

/**
 缓存对象

 @param object 缓存对象（对象必须实现NSCoding协议）
 @param key 缓存对象的key
 @param timeLimit 对象的缓存时间，单位是分钟
 @param result 缓存对象结果回调
 */
- (void)cacheObject:(id<NSCoding>)object forKey:(NSString *)key andTiemLimit:(NSTimeInterval)timeLimit whenResult:(nullable JKCacheObjectBlock)result;

/**
 缓存对象
 
 @param object 缓存对象（对象必须实现NSCoding协议）
 @param key 缓存对象的key
 @param serialize 序列化方法回调（如果为nil,默认使用NSKeyedArchiver进行序列化）
 @param deserialize 反序列化方法回调
 @param result 缓存结果回调
 */
- (void)cacheObject:(id<NSCoding>)object forKey:(NSString *)key withSerialize:(JKCacheSerializeBlock)serialize andDeserialize:(JKCacheDeserializeBlock)deserialize whenResult:(nullable JKCacheObjectBlock)result;

/**
 缓存对象（对象必须实现NSCoding协议）

 @param object 缓存对象
 @param key 缓存对象的Key
 @param timeLimit 对象的缓存时间，单位是分钟
 @param serialize 序列化方法回调（如果为nil,默认使用NSKeyedArchiver进行序列化）
 @param deserialize 反序列化方法回调
 @param result 缓存结果回调
 */
- (void)cacheObject:(id<NSCoding>)object forKey:(NSString *)key withTiemLimit:(NSTimeInterval)timeLimit andSerialize:(JKCacheSerializeBlock)serialize andDeserialize:(JKCacheDeserializeBlock)deserialize whenResult:(nullable JKCacheObjectBlock)result;

/**
 根据key获取异步对象

 @param key 对象的key
 @param result 获取到的对象回调
 */
- (void)objectForKey:(NSString *)key whenResult:(JKCacheGetObjectBlock)result;

/**
 根据key获取对象
 若文件过大会阻塞线程，建议使用异步获取
 
 @param key 对象的key
 */
- (id)objectForKey:(NSString *)key;

/**
 根据key删除对象

 @param key 要删除对象的key
 @param result 删除对象的结果回调
 */
- (void)deleteObjectForKey:(NSString *)key whenResul:(JKCacheDeleteBlock)result;

@end

NS_ASSUME_NONNULL_END
