//
//  NSMutableString+Safe.m
//  FFCrashManager
//
//  Created by tt on 2021/2/23.
//

#import "NSMutableString+Safe.h"
#import "FFSwizzle.h"
#import "NSObject+UnrecognizedSelectorSafe.h"

@implementation NSMutableString (Safe)

// MARK: - Public Methods
+ (void)registerMutableStringCrash {
    
    swizzling_exchangeMethod(NSClassFromString(@"__NSCFString"), @selector(appendString:), @selector(ff_appendString:));
    swizzling_exchangeMethod(NSClassFromString(@"__NSCFString"), @selector(insertString:atIndex:), @selector(ff_insertString:atIndex:));
    
}

// MARK: - Private Methods
- (void)ff_appendString:(NSString *)aString {
    if (aString) {
        [self ff_appendString:aString];
        return;
    }
    [self sendCrashInfoWithMsg:[NSString stringWithUTF8String:__func__] type:(FFCrashType_String)];
}

- (void)ff_insertString:(NSString *)aString atIndex:(NSUInteger)index {
    if (aString && index <= self.length) {
        [self ff_insertString:aString atIndex:index];
        return;
    }
    [self sendCrashInfoWithMsg:[NSString stringWithUTF8String:__func__] type:(FFCrashType_String)];

}

@end
