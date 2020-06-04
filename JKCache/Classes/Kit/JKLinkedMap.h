//
//  JKLinkedMap.h
//  JKCache
//
//  Created by 王治恒 on 2020/3/6.
//  Copyright © 2020 王治恒. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JKLinkedMapNode : NSObject

@property (nonatomic, strong) JKLinkedMapNode * _Nullable prev;
@property (nonatomic, strong) JKLinkedMapNode * _Nullable next;
@property (nonatomic, strong) id _Nullable key;
@property (nonatomic, strong) id _Nullable value;
@property (nonatomic, assign) NSUInteger cost;
@property (nonatomic, assign) NSTimeInterval time;

@end

@interface JKLinkedMap : NSObject

@property (strong, readonly) JKLinkedMapNode * _Nullable head; // 栈顶对象
@property (strong, readonly) JKLinkedMapNode * _Nullable tail; // 栈底对象
@property (assign, readonly) NSUInteger totalCost;  // 链表元素中成本
@property (assign, readonly) NSUInteger totalCount; // 链表元素总数


/**
 添加一对数据
 新添加的数据会排在栈顶

 @param object 存储对象
 @param key   存储对象的Key
 */
- (void)setObject:(nonnull id)object forKey:(nonnull id<NSCopying>)key;

/**
 添加一对数据
 新添加的数据会排在栈顶

 @param object 存储的对象
 @param key   存储对象的Key
 @param cost  存储对象的成本
 */
- (void)setObject:(nonnull id)object forKey:(nonnull id<NSCopying>)key withCost:(NSUInteger)cost;

/**
 将对象至于栈顶

 @param key 对象的Key
 */
- (void)bringToHead:(nonnull id<NSCopying>)key;

/**
 将对象至于栈底

 @param key 对象的key
 */
- (void)bringToTail:(nonnull id<NSCopying>)key;

/**
 从链表中移除对象

 @param key 对象的key
 */
- (void)removeForKey:(nonnull id<NSCopying>)key;

/**
 获取对象

 @param key 对象的key
 @return 对象本身
 */
- (JKLinkedMapNode *_Nullable)objectForKey:(nonnull id<NSCopying>)key;

/**
 将栈低数据移出栈、并从内存中删除

 @return 返回所移出的数据
 */
- (JKLinkedMapNode *_Nullable)removeTail;

/**
 清空栈数据
 内存不会立即回收，会放在优先级比较低的任务队列中回收
 */
- (void)removeAll;

@end

NS_ASSUME_NONNULL_END
