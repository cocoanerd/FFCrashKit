//
//  FFViewController.m
//  FFCrashManager
//
//  Created by 张慧芳 on 02/23/2021.
//  Copyright (c) 2021 张慧芳. All rights reserved.
//

#import "FFViewController.h"
#import "FFDetailViewController.h"
#import "FFObject.h"

@interface FFViewController ()

@property (nonatomic, strong) UIButton *arrayButton;
@property (nonatomic, strong) UIButton *dictionaryButton;
@property (nonatomic, strong) UIButton *stringButton;
@property (nonatomic, strong) UIButton *nullButton;
@property (nonatomic, strong) UIButton *unrecognizedButton;
@property (nonatomic, strong) UIButton *notificationButton;

@end

@implementation FFViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSArray *buttonTitle = @[@"array",@"dictionary",@"string",@"null",@"notification",@"sel", @"KVC", @"KVO"];
    for (int i = 0; i < buttonTitle.count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.frame = CGRectMake(0, 100 + (80)*i, 200, 30);
        [button setTitle:buttonTitle[i] forState:UIControlStateNormal];
        button.tag = 100 + i;
        [button addTarget:self action:@selector(buttonTaped:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
    }
}

- (void)buttonTaped:(UIButton *)button {
    switch (button.tag) {
        case 100: // array
        {
            NSMutableArray *array = [NSMutableArray array];
            __unused NSString *element = array[3];
            [array removeObjectAtIndex:4];
        }
            break;
        case 101: // dictionary
        {
            NSString *key = nil;
            NSMutableDictionary *mutableDic = [[NSMutableDictionary alloc] init];
            [mutableDic setValue:nil forKey:@""];
            [mutableDic setValue:@"" forKey:key];
        }
            break;
        case 102: // string
        {
            __unused NSString *str = [@"" substringToIndex:3];
        }
            break;
        case 103: { // null
            id dic = [NSNull null];
            NSLog(@"%@", dic[@"age"]);
        }
            break;
        case 104: {  // notification
            FFDetailViewController *detail = [[FFDetailViewController alloc] init];
            [self.navigationController pushViewController:detail animated:YES];
        }
            break;
        case 105:// selector
        {
            // 找不到实例方法
            UIButton *button = [[UIButton alloc] init];
            [button performSelector:@selector(taped:)];
            // 找不到类方法
            [FFViewController test];
        }
            break;
        case 106:// kvc
        {
            // 不是对象的属性，造成崩溃
            NSObject *objc = [[NSObject alloc] init];
            [objc setValue:@"value" forKey:@"address"];
            // keyPath 不正确，造成崩溃
            NSObject *objc1 = [[NSObject alloc] init];
            [objc1 setValue:@"张朵朵" forKeyPath:@"user.name"];
            // key 为 nil，造成崩溃
            NSObject *objc2 = [[NSObject alloc] init];
            NSString *keyName;
            [objc2 setValue:@"value" forKey:keyName];
            // value 为 nil，造成崩溃
            NSObject *objc3 = [[NSObject alloc] init];
            [objc3 setValue:nil forKey:@"age"];
        }
            break;
        case 107: {
            FFObject *obj = [[FFObject alloc] init];
            //   移除了未注册的观察者
            [obj removeObserver:self forKeyPath:@"name"];

            //   移除次数多于添加次数
            [obj addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:NULL];
            obj.name = @"0";
            [obj removeObserver:self forKeyPath:@"name"];
            [obj removeObserver:self forKeyPath:@"name"];
            //    未实现observeValueForKeyPath:ofObject:change:context
            FFObject *obj2 = [[FFObject alloc] init];
            [self addObserver: obj2
                   forKeyPath: @"title"
                      options: NSKeyValueObservingOptionNew
                      context: nil];
            self.title = @"111";
            // keypath == nil
            FFObject *obj3 = [[FFObject alloc] init];
               [self addObserver: obj3
                      forKeyPath: @""
                         options: NSKeyValueObservingOptionNew
                         context: nil];
            
        }
        
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
