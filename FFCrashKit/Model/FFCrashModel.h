//
//  FFCrashModel.h
//  FFCrashManager
//
//  Created by tt on 2021/2/23.
// ⚠️⚠️⚠️不同的crash 信息当有不同的侧重点，主要是类名，方法名，由于什么原因崩溃，堆栈信息

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FFCrashModel : NSObject

/// 类名
@property (nonatomic, copy) NSString * className;
/// could be selector name or other
@property (nonatomic, copy) NSString * msg;
/// 堆栈
@property (nonatomic, copy) NSArray  * threadStack;
/// 时间戳
@property (nonatomic, copy) NSString *timeStr;
/// 设备类型
@property (nonatomic, copy, readonly) NSString * deviceType;
/// 系统版本
@property (nonatomic, copy, readonly) NSString * systemVersion;

@end

NS_ASSUME_NONNULL_END
