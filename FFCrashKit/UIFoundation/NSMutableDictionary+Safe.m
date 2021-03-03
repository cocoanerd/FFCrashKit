//
//  NSMutableDictionary+Safe.m
//  FFCrashManager
//
//  Created by tt on 2021/2/23.
//

#import "NSMutableDictionary+Safe.h"
#import "FFSwizzle.h"
#import "NSObject+UnrecognizedSelectorSafe.h"

@implementation NSMutableDictionary (Safe)

// MARK: - Public Methods
+ (void)registerMutableDictionaryCrash {

    swizzling_exchangeMethod(NSClassFromString(@"__NSDictionaryM"), @selector(setObject:forKey:), @selector(ff_setObject:forKey:));
    swizzling_exchangeMethod(NSClassFromString(@"__NSDictionaryM"), @selector(setObject:forKeyedSubscript:), @selector(ff_setObject:forKeyedSubscript:));
    swizzling_exchangeMethod(NSClassFromString(@"__NSDictionaryM"), @selector(removeObjectForKey:), @selector(ff_removeObjectForKey:));

}

// MARK: - Private Methods
- (void)ff_setObject:(id)anObject forKey:(id<NSCopying>)aKey {
    if (aKey && anObject) {
        [self ff_setObject:anObject forKey:aKey];
        return;
    }
    [self sendCrashInfoWithMsg:[NSString stringWithUTF8String:__func__] type:(FFCrashType_Dictionary)];
}

- (void)ff_setObject:(id)obj forKeyedSubscript:(id<NSCopying>)key {
    if (key && obj) {
        [self ff_setObject:obj forKeyedSubscript:key];
        return;
    }
    [self sendCrashInfoWithMsg:[NSString stringWithUTF8String:__func__] type:(FFCrashType_Dictionary)];
}

- (void)ff_removeObjectForKey:(id)aKey {
    if (aKey) {
        [self ff_removeObjectForKey:aKey];
        return;
    }
    [self sendCrashInfoWithMsg:[NSString stringWithUTF8String:__func__] type:(FFCrashType_Dictionary)];
}

@end
