//
//  NSObject+KVCSafe.h
//  FFCrashManager
//
//  Created by tt on 2021/2/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (KVCSafe)

+ (void)registerKVCCrash;

@end

NS_ASSUME_NONNULL_END
