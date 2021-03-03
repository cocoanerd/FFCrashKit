//
//  NSMutableSet+Safe.m
//  FFCrashManager
//
//  Created by tt on 2021/2/23.
//

#import "NSMutableSet+Safe.h"
#import "FFSwizzle.h"
#import "NSObject+UnrecognizedSelectorSafe.h"

@implementation NSMutableSet (Safe)

// MARK: - Public Methods
+ (void)registerMutableSetCrash {
    
    swizzling_exchangeMethod(NSClassFromString(@"__NSSetM"), @selector(addObject:), @selector(ff_addObject:));
    swizzling_exchangeMethod(NSClassFromString(@"__NSSetM"), @selector(removeObject:), @selector(ff_removeObject:));
    
}

// MARK: - Private Methods
- (void)ff_removeObject:(id)object {
    if (object) {
        [self ff_removeObject:object];
    } else {
        [self sendCrashInfoWithMsg:[NSString stringWithUTF8String:__func__] type:(FFCrashType_Set)];
    }
}
-(void)ff_addObject:(id)object {
    if (object) {
        [self ff_addObject:object];
    } else {
        [self sendCrashInfoWithMsg:[NSString stringWithUTF8String:__func__] type:(FFCrashType_Set)];
    }
}

@end
