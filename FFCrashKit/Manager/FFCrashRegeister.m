//
//  FFCrashManager.m
//  FFCrashManager
//
//  Created by tt on 2021/2/23.
//

#import "FFCrashRegeister.h"
#import "FFCrashReport.h"
#import "NSArray+Safe.h"
#import "NSMutableArray+Safe.h"
#import "NSDictionary+Safe.h"
#import "NSMutableDictionary+Safe.h"
#import "NSMutableSet+Safe.h"
#import "NSString+Safe.h"
#import "NSMutableString+Safe.h"
#import "NSNull+Safe.h"
#import "NSNotificationCenter+Safe.h"
#import "NSObject+UnrecognizedSelectorSafe.h"
#import "NSObject+KVCSafe.h"
#import "NSObject+KVOSafe.h"

__attribute__((constructor)) static void constInit(void) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @autoreleasepool {
            //默认全部开启，如需关闭或开启某几个再次调用此方法，即可实现
            [FFCrashRegeister regeisterCrashWithType:FFCrashRegisterType_All];
        }
    });
}

@interface FFCrashRegeister ()<FFCrashReportDelegate>

@property (nonatomic, assign) FFCrashRegisterType type;

@end

@implementation FFCrashRegeister

// MARK: - Public Methods
+ (instancetype)sharedManager
{
    static FFCrashRegeister * instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[FFCrashRegeister alloc] init];
        [FFCrashReport sharedReport].delegate = instance;
    });
    return instance;
}

+ (void)regeisterCrashWithType:(FFCrashRegisterType)type {
    
    FFCrashRegeister * manager = [self sharedManager];
    if (type == manager.type) {
        return;
    }
    
    //等于none时，表明之前注册过的需要全部 取消注册，第二次注册则可以取消
    if (type == FFCrashRegisterType_None) {
        [self registerWithType:manager.type];
    } else if (manager.type == FFCrashRegisterType_None) {
        [self registerWithType:type];
    } else {
        //异或 实现 取消注册部分的功能
        [self registerWithType:manager.type ^ type];
    }
    manager.type = type;
}

// MARK: - FFivate Methods
+ (void)registerWithType:(FFCrashRegisterType)type {
    if (type & FFCrashRegisterType_UnrecognizedSelector) {
        [NSObject registerUnrecognizedSelectorCrash];
    }
    if (type & FFCrashRegisterType_NotificationCenter) {
        [NSNotificationCenter registerNotificationCenterCrash];
    }
    if (type & FFCrashRegisterType_Array) {
        [NSArray registerArrayCrash];
        [NSMutableArray registerMutableArrayCrash];
    }
    if (type & FFCrashRegisterType_Dictionary) {
        [NSDictionary registerDictonaryCrash];
        [NSMutableDictionary registerMutableDictionaryCrash];
    }
    if (type & FFCrashRegisterType_Set) {
        [NSMutableSet registerMutableSetCrash];
    }
    if (type & FFCrashRegisterType_String) {
        [NSString registerStringCrash];
        [NSMutableString registerMutableStringCrash];
    }
    if (type & FFCrashRegisterType_Null) {
        [NSNull registerNullCrash];
    }
    if (type & FFCrashRegisterType_KVC) {
        [NSObject registerKVCCrash];
    }
    if (type & FFCrashRegisterType_KVO) {
        [NSObject registerKVOCrash];
    }
}

// MARK: - FFCrashReportDelegate
- (void)handleCrashInfo:(FFCrashModel *)model type:(NSString *)type
{
    ///TODO:数据上传处理，如果需要的话
    
}

@end
