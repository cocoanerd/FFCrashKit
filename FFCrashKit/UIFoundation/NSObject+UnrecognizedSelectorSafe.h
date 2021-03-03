//
//  NSObject+UnrecognizedSelectorSafe.h
//  FFCrashManager
//
//  Created by tt on 2021/2/23.
//

#import <Foundation/Foundation.h>
#import "FFSwizzle.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (UnrecognizedSelectorSafe)

+ (void)registerUnrecognizedSelectorCrash;

- (void)sendCrashInfoWithMsg:(NSString *)msg type:(FFCrashType)type;

@end

NS_ASSUME_NONNULL_END
