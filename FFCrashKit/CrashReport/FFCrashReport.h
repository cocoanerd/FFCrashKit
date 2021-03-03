//
//  FFCrashReport.h
//  FFCrashManager
//
//  Created by tt on 2021/2/23.
//
// ⚠️⚠️⚠️ 输出崩溃信息报告类，用户存储、获取崩溃信息

#import <Foundation/Foundation.h>
#import "FFSwizzle.h"

@class FFCrashModel;

@protocol FFCrashReportDelegate <NSObject>

/// 处理Crash信息
/// @param model model
/// @param type Crash类型
- (void)handleCrashInfo:(FFCrashModel *)model type:(NSString *)type;

@end

@interface FFCrashReport : NSObject

/// 代理
@property (nonatomic, weak ) id<FFCrashReportDelegate> delegate;

/// 单例
+ (instancetype)sharedReport;

/// 上报崩溃信息
/// @param model model
/// @param type Crash类型
+ (void)crashInfo:(FFCrashModel *)model type:(FFCrashType)type;

/// 获取崩溃信息
/// @param type Crash类型
+ (NSDictionary *)getCrashReportWithType:(FFCrashType)type;

/// 获取所有崩溃信息
+ (NSArray *)getAllCrashReport;

@end
