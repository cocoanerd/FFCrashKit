//
//  FFCrashManager.h
//  FFCrashManager
//
//  Created by tt on 2021/2/23.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, FFCrashRegisterType) {
    FFCrashRegisterType_None = 0,
    FFCrashRegisterType_UnrecognizedSelector = 1 << 1,
    FFCrashRegisterType_Array = 1 << 2,
    FFCrashRegisterType_Dictionary = 1 << 3,
    FFCrashRegisterType_Set = 1 << 4,
    FFCrashRegisterType_Null = 1 << 5,
    FFCrashRegisterType_String = 1 << 6,
    FFCrashRegisterType_NotificationCenter = 1 << 7,
    FFCrashRegisterType_KVC = 1 << 8,
    FFCrashRegisterType_KVO = 1 << 9,
    FFCrashRegisterType_All = (FFCrashRegisterType_UnrecognizedSelector |
                               FFCrashRegisterType_Array |
                               FFCrashRegisterType_Dictionary |
                               FFCrashRegisterType_Set |
                               FFCrashRegisterType_Null |
                               FFCrashRegisterType_String |
                               FFCrashRegisterType_NotificationCenter|
                               FFCrashRegisterType_KVC|
                               FFCrashRegisterType_KVO)
};

@interface FFCrashRegeister : NSObject

/// 单例对象
+ (instancetype)sharedManager;

/// 注册crash
/// @param type 注册类型
+ (void)regeisterCrashWithType:(FFCrashRegisterType)type;

@end
