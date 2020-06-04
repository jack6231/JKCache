//
//  JKViewController.m
//  JKCache
//
//  Created by 王治恒 on 06/03/2020.
//  Copyright (c) 2020 王治恒. All rights reserved.
//

#import "JKViewController.h"
#import "JKCache/JKCache.h"

@interface JKViewController ()

@end

@implementation JKViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)clickAddButton:(id)sender
{
    for (int i = 0; i < 1; i++) {
        dispatch_queue_t concurrentQueue=dispatch_queue_create("并行队列", DISPATCH_QUEUE_CONCURRENT);
        dispatch_async(concurrentQueue, ^{
            [[JKCache shareInstance] cacheObject:@"测试哈哈哈1" forKey:@"test1" whenResult:^(BOOL isSuccess) {
                NSLog(@"---------------1：%d", isSuccess);
            }];
        });
        dispatch_async(concurrentQueue, ^{
            [[JKCache shareInstance] cacheObject:@"测试嘿嘿嘿2" forKey:@"test2" whenResult:^(BOOL isSuccess) {
                NSLog(@"---------------2：%d", isSuccess);
            }];
        });
        dispatch_async(concurrentQueue, ^{
            [[JKCache shareInstance] cacheObject:@"测试嘻嘻嘻3" forKey:@"test3" whenResult:^(BOOL isSuccess) {
                NSLog(@"---------------3：%d", isSuccess);
            }];
        });
        usleep(10*1000);
    }
}

- (IBAction)clickRomveButton:(id)sender
{
    [[JKCache shareInstance] deleteObjectForKey:@"test2" whenResul:^(BOOL isSuccess, NSError *error) {
        NSLog(@"---isSuccess:%d, eroor:%@", isSuccess, error);
    }];
}

- (IBAction)clickPrintButton:(id)sender
{
    dispatch_queue_t concurrentQueue=dispatch_queue_create("并行队列", DISPATCH_QUEUE_CONCURRENT);
    for (int i = 0; i < 1; i++) {
        dispatch_async(concurrentQueue, ^{
                    [[JKCache shareInstance] objectForKey:@"test1" whenResult:^(id object, NSString *key) {
                        NSLog(@"---key:%@, value:%@", key, object);
                    }];
        });
        
        dispatch_async(concurrentQueue, ^{
                    [[JKCache shareInstance] objectForKey:@"test2" whenResult:^(id object, NSString *key) {
                        NSLog(@"---key:%@, value:%@", key, object);
                    }];
        });
        dispatch_async(concurrentQueue, ^{
                    [[JKCache shareInstance] objectForKey:@"test3" whenResult:^(id object, NSString *key) {
                        NSLog(@"---key:%@, value:%@", key, object);
                    }];
        });
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
