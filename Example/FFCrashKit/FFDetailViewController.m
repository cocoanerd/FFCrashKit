//
//  FFDetailViewController.m
//  FFCrashKit_Example
//
//  Created by tt on 2021/3/3.
//  Copyright © 2021 张慧芳. All rights reserved.
//

#import "FFDetailViewController.h"

@interface FFDetailViewController ()

@end

@implementation FFDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(printLog:) name:@"printLog" object:nil];
    // Do any additional setup after loading the view.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
