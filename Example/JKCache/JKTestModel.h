//
//  JKTestModel.h
//  JKCache_Example
//
//  Created by 王治恒 on 2020/7/13.
//  Copyright © 2020 王治恒. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JKCacheObject.h"

typedef NS_ENUM(NSInteger, Gender){
    NOTyping,
    Boy,
    Girl
};

NS_ASSUME_NONNULL_BEGIN

@interface JKTestModel : JKCacheObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) NSInteger age;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) Gender gender;
@property (nonatomic, copy) NSArray<NSString *> *readBooks;

@end

NS_ASSUME_NONNULL_END
