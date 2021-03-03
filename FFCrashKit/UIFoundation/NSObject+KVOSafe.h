//
//  NSObject+KVOSafe.h
//  FFCrashManager
//
//  Created by tt on 2021/3/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (KVOSafe)

+ (void)registerKVOCrash;

@end

NS_ASSUME_NONNULL_END
