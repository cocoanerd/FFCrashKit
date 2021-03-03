//
//  NSString+Safe.m
//  FFCrashManager
//
//  Created by tt on 2021/2/23.
//

#import "NSString+Safe.h"
#import "FFSwizzle.h"
#import "NSObject+UnrecognizedSelectorSafe.h"

@implementation NSString (Safe)

// MARK: - Public Methods
+ (void)registerStringCrash {
    
    //类方法
    swizzling_exchangeMethod(object_getClass([self class]), @selector(stringWithUTF8String:), @selector(ff_stringWithUTF8String:));
    swizzling_exchangeMethod(object_getClass([self class]), @selector(stringWithCString:encoding:), @selector(ff_stringWithCString:encoding:));
    
    //alloc 实例方法
    swizzling_exchangeMethod(NSClassFromString(@"NSPlaceholderString"), @selector(initWithCString:encoding:), @selector(ff_initWithCString:encoding:));
    swizzling_exchangeMethod(NSClassFromString(@"NSPlaceholderString"), @selector(initWithString:), @selector(ff_initWithString:));
    
    //实例方法
    swizzling_exchangeMethod([self class], @selector(initWithUTF8String:), @selector(ff_stringWithUTF8String:));
    swizzling_exchangeMethod([self class], @selector(stringByAppendingString:), @selector(ff_stringByAppendingString:));
    swizzling_exchangeMethod([self class], @selector(substringFromIndex:), @selector(ff_substringFromIndex:));
    swizzling_exchangeMethod([self class], @selector(substringToIndex:), @selector(ff_substringToIndex:));
    swizzling_exchangeMethod([self class], @selector(substringWithRange:), @selector(ff_substringWithRange:));
}

// MARK: - Private Methods
+ (instancetype)ff_stringWithUTF8String:(const char *)nullTerminatedCString {
    if (NULL != nullTerminatedCString) {
        return [self ff_stringWithUTF8String:nullTerminatedCString];
    }
    [self sendCrashInfoWithMsg:[NSString stringWithUTF8String:__func__] type:(FFCrashType_String)];
    return nil;
}

+ (instancetype)ff_stringWithCString:(const char *)cString encoding:(NSStringEncoding)encoding {
    if (NULL != cString) {
        return [self ff_stringWithCString:cString encoding:encoding];
    }
    [self sendCrashInfoWithMsg:[NSString stringWithUTF8String:__func__] type:(FFCrashType_String)];
    return nil;
}


- (instancetype)ff_initWithUTF8String:(const char *)nullTerminatedCString {
    if (NULL != nullTerminatedCString) {
        return [self ff_initWithUTF8String:nullTerminatedCString];
    }
    [self sendCrashInfoWithMsg:[NSString stringWithUTF8String:__func__] type:(FFCrashType_String)];
    return nil;
}

- (instancetype)ff_initWithCString:(const char *)nullTerminatedCString encoding:(NSStringEncoding)encoding {
    if (NULL != nullTerminatedCString) {
        return [self ff_initWithCString:nullTerminatedCString encoding:encoding];
    }
    [self sendCrashInfoWithMsg:[NSString stringWithUTF8String:__func__] type:(FFCrashType_String)];
    return nil;
}

- (NSString *)ff_substringFromIndex:(NSUInteger)from {
    if (from <= self.length) {
        return [self ff_substringFromIndex:from];
    }
    [self sendCrashInfoWithMsg:[NSString stringWithUTF8String:__func__] type:(FFCrashType_String)];
    return nil;
}

- (NSString *)ff_substringToIndex:(NSUInteger)to {
    if (to > self.length) {
        [self sendCrashInfoWithMsg:[NSString stringWithUTF8String:__func__] type:(FFCrashType_String)];
        to = self.length;
    }
    return [self ff_substringToIndex:to];

}

- (NSString *)ff_substringWithRange:(NSRange)range {
    if (range.location + range.length <= self.length) {
        return [self ff_substringWithRange:range];
    }else if (range.location < self.length){
        return [self ff_substringWithRange:NSMakeRange(range.location, self.length-range.location)];
    }
    [self sendCrashInfoWithMsg:[NSString stringWithUTF8String:__func__] type:(FFCrashType_String)];
    return nil;
}

- (NSString *)ff_stringByAppendingString:(NSString *)aString {
    if (aString) {
        return [self ff_stringByAppendingString:aString];
    }
    [self sendCrashInfoWithMsg:[NSString stringWithUTF8String:__func__] type:(FFCrashType_String)];
    return [NSString stringWithString:self];
}

- (instancetype)ff_initWithString:(NSString *)aString {
    if (aString) {
        return [self ff_initWithString:aString];
    }
    [self sendCrashInfoWithMsg:[NSString stringWithUTF8String:__func__] type:(FFCrashType_String)];
    return nil;
}

@end
