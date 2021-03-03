//
//  NSString+Safe.h
//  FFCrashManager
//
//  Created by tt on 2021/2/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Safe)

+ (void)registerStringCrash;

@end

NS_ASSUME_NONNULL_END
