//
//  JKViewController.m
//  JKCache
//
//  Created by 王治恒 on 06/03/2020.
//  Copyright (c) 2020 王治恒. All rights reserved.
//

#import "JKViewController.h"
#import "JKCache/JKCache.h"
#import "JKTestModel.h"

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
    NSThread *t = [[NSThread alloc] initWithBlock:^{
        for (int i = 0; i < 1000; i++) {
            dispatch_queue_t concurrentQueue=dispatch_queue_create("并行队列", DISPATCH_QUEUE_CONCURRENT);
            dispatch_async(concurrentQueue, ^{
                JKTestModel *testModel = [[JKTestModel alloc] init];
                testModel.name = @"Jack";
                testModel.age = 18;
                testModel.height = 175;
                testModel.gender = Boy;
                testModel.readBooks = @[@"三国演义", @"红楼梦"];
                [[JKCache shareInstance] cacheObject:testModel forKey:@"test1" whenResult:^(BOOL isSuccess) {
                    NSLog(@"--------------");
                }];
            });

            dispatch_async(concurrentQueue, ^{
                NSString *obj = @"亮躬耕陇亩，好为《梁父吟》。身长八尺，每自比于管仲、乐毅，时人莫之许也。惟博陵崔州平、颍川徐庶元直与亮友善，谓为信然。时先主屯新野。徐庶见先主，先主器之，谓先主曰：“诸葛孔明者，卧龙也，将军岂愿见之乎？”先主曰：“君与俱来。”庶曰：“此人可就见，不可屈致也。将军宜枉驾顾之。”由是先主遂诣亮，凡三往，乃见。因屏人曰：“汉室倾颓，奸臣窃命，主上蒙尘。孤不度德量力，欲信大义于天下，而智术浅短，遂用猖蹶，至于今日。然志犹未已，君谓计将安出？”亮答曰：“自董卓已来，豪杰并起，跨州连郡者不可胜数。曹操比于袁绍，则名微而众寡，然操遂能克绍，以弱为强者，非惟天时，抑亦人谋也。今操已拥百万之众，挟天子而令诸侯，此诚不可与争锋。孙权据有江东，已历三世，国险而民附，贤能为之用，此可以为援而不可图也。荆州北据汉、沔，利尽南海，东连吴会，西通巴、蜀，此用武之国，而其主不能守，此殆天所以资将军，将军岂有意乎？益州险塞，沃野千里，天府之土，高祖因之以成帝业。刘璋暗弱，张鲁在北，民殷国富而不知存恤，智能之士思得明君。将军既帝室之胄，信义著于四海，总揽英雄，思贤如渴，若跨有荆、益，保其岩阻，西和诸戎，南抚夷越，外结好孙权，内修政理；天下有变，则命一上将将荆州之军以向宛、洛，将军身率益州之众出于秦川，百姓孰敢不箪食壶浆以迎将军者乎？诚如是，则霸业可成，汉室可兴矣。”先主曰：“善！”于是与亮情好日密。关羽、张飞等不悦，先主解之曰：“孤之有孔明，犹鱼之有水也。愿诸君勿复言。”羽、飞乃止。";
                [[JKCache shareInstance] cacheObject:obj forKey:@"test2" whenResult:^(BOOL isSuccess) {
                    NSLog(@"---------------2：%d", isSuccess);
                }];
            });
            dispatch_async(concurrentQueue, ^{
                NSString *obj = @"先帝创业未半而中道崩殂，今天下三分，益州疲弊，此诚危急存亡之秋也。然侍卫之臣不懈于内，忠志之士忘身于外者，盖追先帝之殊遇，欲报之于陛下也。诚宜开张圣听，以光先帝遗德，恢弘志士之气，不宜妄自菲薄，引喻失义，以塞忠谏之路也。宫中府中，俱为一体，陟罚臧否，不宜异同。若有作奸犯科及为忠善者，宜付有司论其刑赏，以昭陛下平明之理，不宜偏私，使内外异法也。侍中、侍郎郭攸之、费祎、董允等，此皆良实，志虑忠纯，是以先帝简拔以遗陛下。愚以为宫中之事，事无大小，悉以咨之，然后施行，必能裨补阙漏，有所广益。将军向宠，性行淑均，晓畅军事，试用于昔日，先帝称之曰能，是以众议举宠为督。愚以为营中之事，悉以咨之，必能使行阵和睦，优劣得所。亲贤臣，远小人，此先汉所以兴隆也；亲小人，远贤臣，此后汉所以倾颓也。先帝在时，每与臣论此事，未尝不叹息痛恨于桓、灵也。侍中、尚书、长史、参军，此悉贞良死节之臣，愿陛下亲之信之，则汉室之隆，可计日而待也。臣本布衣，躬耕于南阳，苟全性命于乱世，不求闻达于诸侯。先帝不以臣卑鄙，猥自枉屈，三顾臣于草庐之中，咨臣以当世之事，由是感激，遂许先帝以驱驰。后值倾覆，受任于败军之际，奉命于危难之间，尔来二十有一年矣。先帝知臣谨慎，故临崩寄臣以大事也。受命以来，夙夜忧叹，恐托付不效，以伤先帝之明，故五月渡泸，深入不毛。今南方已定，兵甲已足，当奖率三军，北定中原，庶竭驽钝，攘除奸凶，兴复汉室，还于旧都。此臣所以报先帝而忠陛下之职分也。至于斟酌损益，进尽忠言，则攸之、祎、允之任也。愿陛下托臣以讨贼兴复之效，不效，则治臣之罪，以告先帝之灵。若无兴德之言，则责攸之、祎、允等之慢，以彰其咎；陛下亦宜自谋，以咨诹善道，察纳雅言，深追先帝遗诏，臣不胜受恩感激。今当远离，临表涕零，不知所言。";
                [[JKCache shareInstance] cacheObject:obj forKey:@"test3" whenResult:^(BOOL isSuccess) {
                    NSLog(@"---------------3：%d", isSuccess);
                }];
            });
        }
    }];
    [t start];
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
            id object = [[JKCache shareInstance] objectForKey:@"test3"];
            NSLog(@"---key: test3, value:%@",object);
        });
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
