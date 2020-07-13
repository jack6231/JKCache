#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "JKCache.h"
#import "JKCacheManager.h"
#import "JKCacheObject.h"
#import "JKFileCache.h"
#import "JKLRUCache.h"
#import "JKLinkedMap.h"

FOUNDATION_EXPORT double JKCacheVersionNumber;
FOUNDATION_EXPORT const unsigned char JKCacheVersionString[];

