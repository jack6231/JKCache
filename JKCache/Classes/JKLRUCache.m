//
//  JKLRUCache.m
//  JKCache
//
//  Created by 王治恒 on 2020/3/6.
//  Copyright © 2020 王治恒. All rights reserved.
//

#import "JKLRUCache.h"
#import "JKLinkedMap.h"
#import <pthread.h>
#import <UIKit/UIKit.h>

@interface JKLRUCache()
{
    JKLinkedMap *_map;
    pthread_mutex_t _lock;
}

@end

@implementation JKLRUCache

- (instancetype)init
{
    self = [super init];
    if (self) {
        pthread_mutex_init(&_lock, NULL);
        _map = [[JKLinkedMap alloc] init];
        _costLimit = NSUIntegerMax;
        _countLimit = NSUIntegerMax;
        _timeLimit = NSUIntegerMax;
        _aotoTimeInterval = 30.f;
        _shouldRemoveAllObjectsOnMemoryWarning = YES;
        [self aotoCleaning];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(memoryWarning:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    return self;
}

- (void)aotoCleaning
{
    __weak typeof(self) weekself = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, _aotoTimeInterval * NSEC_PER_SEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        __strong typeof(weekself) strongself = weekself;
        if (!strongself) return;
        if (strongself->_map.totalCount == 0) {
            [self aotoCleaning];
            return;
        }
        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            [strongself trimCostLimit:strongself->_costLimit];
            [strongself trimCountLimit:strongself->_countLimit];
            [strongself trimTimeLimit:strongself->_timeLimit];
            [self aotoCleaning];
        });
    });
}

- (void)cacheObject:(nonnull id)object forKey:(nonnull id<NSCopying>)key
{
    pthread_mutex_lock(&_lock);
    [_map setObject:object forKey:key];
    pthread_mutex_unlock(&_lock);
}

- (void)cacheObject:(nonnull id)object forKey:(nonnull id<NSCopying>)key withCost:(NSUInteger)cost
{
    if (!key) return;
    
    pthread_mutex_lock(&_lock);
    if (!object) {
        [_map removeForKey:key];
    }
    
    [_map setObject:object forKey:key withCost:cost];
    // 判断成本
    if (_map.totalCost > _costLimit) {
        [self trimCostLimit:_costLimit];
    }
    // 判断容量
    if (_map.totalCount > _countLimit) {
        [_map removeTail];
    }
    pthread_mutex_unlock(&_lock);
}

- (id)objectForKey:(nonnull id<NSCopying>)key
{
    if (!key) return nil;
    pthread_mutex_lock(&_lock);
    JKLinkedMapNode *node = [_map objectForKey:key];
    if (node) {
        [_map bringToHead:key];
    }
    pthread_mutex_unlock(&_lock);
    return node.value;
}

- (void)removeForKey:(nonnull id<NSCopying>)key
{
    if (!key) return;
    
    pthread_mutex_lock(&_lock);
    [_map removeForKey:key];
    pthread_mutex_unlock(&_lock);
}

- (void)clearAll
{
    pthread_mutex_lock(&_lock);
    [_map removeAll];
    pthread_mutex_unlock(&_lock);
}


- (void)trimCountLimit:(NSUInteger)countLimit
{
    _countLimit = countLimit;
    
    BOOL finish = NO;
    pthread_mutex_lock(&_lock);
    if (countLimit == 0) {
        [_map removeAll];
        finish = YES;
    } else if (countLimit <= _map.totalCount) {
        finish = YES;
    }
    pthread_mutex_unlock(&_lock);
    if (finish) return;
    
    NSMutableArray *holder = [[NSMutableArray alloc] init];
    while (!finish) {
        if (pthread_mutex_trylock(&_lock) == 0) {
            if (countLimit <= _map.totalCount) {
                JKLinkedMapNode *node = [_map removeTail];
                [holder addObject:node];
            } else {
                finish = YES;
            }
            pthread_mutex_unlock(&_lock);
        } else {
            usleep(10 * 1000);
        }
    }
    
    if (holder.count) {
        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            [holder removeAllObjects];
        });
    }
}

- (void)trimCostLimit:(NSUInteger)costLimit
{
    _costLimit = costLimit;
    
    BOOL finish = NO;
    pthread_mutex_lock(&_lock);
    if (costLimit == 0) {
        [_map removeAll];
        finish = YES;
    } else if (costLimit <= _map.totalCost) {
        finish = YES;
    }
    pthread_mutex_unlock(&_lock);
    
    if (finish) return;
    
    NSMutableArray *holder = [[NSMutableArray alloc] init];
    while (!finish) {
        if (pthread_mutex_trylock(&_lock) == 0) {
            if (_map.totalCost > costLimit) {
                JKLinkedMapNode *node = [_map removeTail];
                if (node) {
                    [holder addObject:node];
                }
            } else {
                finish = YES;
            }
            pthread_mutex_unlock(&_lock);
        } else {
            usleep(10 * 1000);
        }
    }
    if (holder.count) {
        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            [holder removeAllObjects];
        });
    }
}

- (void)trimTimeLimit:(NSTimeInterval)timeLimit
{
    _timeLimit = timeLimit;
    
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    JKLinkedMapNode *node = _map.tail;
    NSMutableArray *holder = [[NSMutableArray alloc] init];
    while (node) {
        if (pthread_mutex_trylock(&_lock) == 0) {
            if (node.time + (double)_timeLimit < currentTime) {
                [_map removeForKey:node.key];
                [holder addObject:node];
            }
            node = node.prev;
            pthread_mutex_unlock(&_lock);
        }
    }
    
    if (holder.count) {
        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            [holder removeAllObjects];
        });
    }
}

- (void)memoryWarning:(id)sender
{
    if (_shouldRemoveAllObjectsOnMemoryWarning) {
        [_map removeAll];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    [_map removeAll];
    pthread_mutex_destroy(&_lock);
}


@end
