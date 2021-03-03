//
//  NSObject+KVCSafe.m
//  FFCrashManager
//
//  Created by tt on 2021/2/26.
//

#import "NSObject+KVCSafe.h"
#import "FFSwizzle.h"
#import "NSObject+UnrecognizedSelectorSafe.h"

@implementation NSObject (KVCSafe)

+ (void)registerKVCCrash {
    swizzling_exchangeMethod([self class], @selector(setValue:forKey:), @selector(ff_setValue:forKey:));
}

- (void)ff_setValue:(id)value forKey:(NSString *)key {
    if (key == nil) {
        NSString *crashMessages = [NSString stringWithFormat:@"[<%@ %p> setNilValueForKey]: could not set nil as the value for the key %@.",[NSString stringWithUTF8String:__func__],self,key];
        [self sendCrashInfoWithMsg:crashMessages type:(FFCrashType_KVC)];
        return;
    }
    [self ff_setValue:value forKey:key];
}

- (void)setNilValueForKey:(NSString *)key {
    NSString *crashMessages = [NSString stringWithFormat:@"[<%@ %p> setNilValueForKey]: could not set nil as the value for the key %@.",[NSString stringWithUTF8String:__func__],self,key];
    [self sendCrashInfoWithMsg:crashMessages type:(FFCrashType_KVC)];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    NSString *crashMessages = [NSString stringWithFormat:@"[<%@ %p> setValue:forUndefinedKey]:",[NSString stringWithUTF8String:__func__],self];
    [self sendCrashInfoWithMsg:crashMessages type:(FFCrashType_KVC)];
}

- (nullable id)valueForUndefinedKey:(NSString *)key {
    NSString *crashMessages = [NSString stringWithFormat:@"[<%@ %p> valueForUndefinedKey:]: this class is not key value coding-compliant for the key: %@",[NSString stringWithUTF8String:__func__],self,key];
    [self sendCrashInfoWithMsg:crashMessages type:(FFCrashType_KVC)];
    return self;
}

@end
