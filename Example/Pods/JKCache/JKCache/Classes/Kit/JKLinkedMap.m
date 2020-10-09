//
//  JKLinkedMap.m
//  JKCache
//
//  Created by 王治恒 on 2020/3/6.
//  Copyright © 2020 王治恒. All rights reserved.
//

#import "JKLinkedMap.h"
#import <QuartzCore/QuartzCore.h>

@implementation JKLinkedMapNode

- (instancetype)init
{
    self = [super init];
    if (self) {
        _time = [[NSDate date] timeIntervalSince1970];
    }
    return self;
}

@end

@interface JKLinkedMap()
{
    CFMutableDictionaryRef _dict;
}
@end

@implementation JKLinkedMap

- (instancetype)init
{
    self = [super init];
    if (self) {
        _dict = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    }
    return self;
}

- (void)setObject:(nonnull id)object forKey:(nonnull id<NSCopying>)key
{
    [self setObject:object forKey:key withCost:0];
}

- (void)setObject:(nonnull id)object forKey:(nonnull id<NSCopying>)key withCost:(NSUInteger)cost
{
    if (!key) return;
    if (!object) return;
    
    id obj = CFDictionaryGetValue(_dict, (__bridge const void *)key);
    if (obj) {
        [self removeForKey:key];
    }
    
    JKLinkedMapNode *node = [[JKLinkedMapNode alloc] init];
    node.key = key;
    node.value = object;
    node.cost = cost;
    [self addNode:node];
}

- (void)addNode:(JKLinkedMapNode *)node
{
    if (!node) return;
    
    CFDictionarySetValue(_dict, (__bridge const void *)node.key, (__bridge const void *)node);
    _totalCost += node.cost;
    _totalCount ++;
    if (_head) {
        node.next = _head;
        _head.prev = node;
        _head = node;
    } else {
        _head = _tail = node;
    }
}

- (void)bringToHead:(id<NSCopying>)key
{
    if (!key) return;
    
    JKLinkedMapNode *node = CFDictionaryGetValue(_dict, (__bridge const void *)key);
    if (_head) {
        node.prev = nil;
        node.next = _head;
        _head.prev = node;
        _head = node;
    } else {
        _head = _tail = node;
    }
}

- (void)bringToTail:(id<NSCopying>)key
{
    if (!key) return;
    
    JKLinkedMapNode *node = CFDictionaryGetValue(_dict, (__bridge const void *)key);
    if (_tail) {
        node.next = _tail;
        _tail.prev = node;
        _tail = node;
    } else {
        _head = _tail = node;
    }
}

- (void)removeForKey:(id<NSCopying>)key
{
    if (!key) return;
    
    JKLinkedMapNode *node = CFDictionaryGetValue(_dict, (__bridge const void *)key);
    _totalCount --;
    _totalCost -= node.cost;
    if (node.prev) node.prev.next = node.next;
    if (node.next) node.next.prev = node.prev;
    if (node == _head) _head = node.next;
    if (node == _tail) _tail = node.prev;
    
    CFDictionaryRemoveValue(_dict, (__bridge const void *)key);
}

- (JKLinkedMapNode *)objectForKey:(id<NSCopying>)key
{
    if (!key) return nil;
    JKLinkedMapNode *node = CFDictionaryGetValue(_dict, (__bridge const void *)key);
    return node;
}

- (JKLinkedMapNode *)removeTail
{
    if (!_tail) return nil;
    
    CFDictionaryRemoveValue(_dict, (__bridge const void *)_tail.key);
    _totalCount --;
    _totalCost -= _tail.cost;
    if (_tail == _head) {
        return nil;
    } else {
        _tail = _tail.prev;
    }
    return _tail;
}

- (void) removeAll
{
    _totalCount = 0;
    _totalCost = 0;
    _head = _tail = nil;
    
    if (CFDictionaryGetCount(_dict) > 0)
    {
        CFMutableDictionaryRef holder = _dict;
        _dict = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            CFRelease(holder);
        });
    }
}

- (void)dealloc {
    CFRelease(_dict);
}


@end
