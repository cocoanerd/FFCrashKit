//
//  FFMsgReceiver.h
//  FFCrashManager
//
//  Created by tt on 2021/2/23.
//
// ⚠️⚠️⚠️ 给类添加方法，用于runtime找不到方法，进行三步挽救措施提供便捷

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FFMsgReceiver : NSObject

/// 单例对象
+ (instancetype)sharedInstance;

/// 添加实例方法
/// @param sel sel
- (BOOL)addFunc:(SEL)sel;

/// 添加类方法
/// @param sel sel
+ (BOOL)addClassFunc:(SEL)sel;


@end

NS_ASSUME_NONNULL_END
