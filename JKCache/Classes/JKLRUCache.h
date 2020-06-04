//
//  JKLRUCache.h
//  JKCache
//
//  Created by 王治恒 on 2020/3/6.
//  Copyright © 2020 王治恒. All rights reserved.
//
//  1、使用 JKLienkedMap 作为内存储数据结构
//  2、JKLRUCache 是线程安全的
//  3、使用 LRU 算法进行对象在数据结构中的顺序
//  4、使用 count、cost、time 三个维度进行缓存对象管理
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JKLRUCache : NSObject

@property (nonatomic, strong) NSString * _Nullable name;       // 缓存名称
@property (assign, readonly) NSUInteger totalCount;            // 缓存总大小
@property (assign, readonly) NSUInteger totalCost;             // 缓存总成本
@property (nonatomic, assign) NSUInteger countLimit;           // 缓存大小的上限，默认最大值
@property (nonatomic, assign) NSUInteger costLimit;            // 缓存成本的上限，默认最大值
@property (nonatomic, assign) NSTimeInterval timeLimit;        // 缓存时间上限(秒)，默认最大值
@property (nonatomic, assign) NSTimeInterval aotoTimeInterval; // 自动清理时间间隔(秒)，默认30秒
@property BOOL shouldRemoveAllObjectsOnMemoryWarning;          // 系统内容异常时是否清除缓存

/**
 添加缓存数据

 @param object 缓存对象
 @param key    缓存对象的key
 */
- (void)cacheObject:(nonnull id)object forKey:(nonnull id<NSCopying>)key;

/**
 添加缓存数据

 @param object 缓存对象
 @param key    缓存对象的key
 @param cost   缓存对象的成本
 */
- (void)cacheObject:(nonnull id)object forKey:(nonnull id<NSCopying>)key withCost:(NSUInteger)cost;

/**
 获取缓存对象

 @param key 缓存对象的key
 @return 缓存对象
 */
- (id _Nonnull )objectForKey:(nonnull id<NSCopying>)key;

/**
 通过对象的key将对象移出缓存

 @param key 缓存对象
 */
- (void)removeForKey:(nonnull id<NSCopying>)key;

/**
 清空缓存
 */
- (void)clearAll;

/**
 整理缓存内容，通过缓存大小的限制
 超出缓存数据会放在优先级比较低的队列中进行回收

 @param countLimit 缓存上线
 */
- (void)trimCountLimit:(NSUInteger)countLimit;

/**
 整理缓存内容，通过成本上限限制
 超出缓存数据会放在优先级比较低的队列中进行回收
 
 @param costLimit 成本上限
 */
- (void)trimCostLimit:(NSUInteger)costLimit;

/**
 整理缓存内容，通过缓存数据的缓存时间上限
 单位是秒
 超出缓存数据会放在优先级比较低的队列中进行回收

 @param timeLimit 时间上限
 */
- (void)trimTimeLimit:(NSTimeInterval)timeLimit;

@end

NS_ASSUME_NONNULL_END
