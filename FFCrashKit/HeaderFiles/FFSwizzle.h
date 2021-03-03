//
//  FFSwizzle.h
//  FFCrashManager
//
//  Created by tt on 2021/2/23.
//

#import <objc/runtime.h>

typedef enum : NSUInteger {
    FFCrashType_UnrecognizedSelector = 0,
    FFCrashType_Array,
    FFCrashType_Dictionary,
    FFCrashType_Set,
    FFCrashType_Null,
    FFCrashType_String,
    FFCrashType_NotificationCenter,
    FFCrashType_KVC,
    FFCrashType_KVO
} FFCrashType;

static inline void swizzling_exchangeMethod(Class clazz, SEL originalSelector, SEL exchangeSelector) {
    
    Method originalMethod = class_getInstanceMethod(clazz, originalSelector);
    Method exchangeMethod = class_getInstanceMethod(clazz, exchangeSelector);
    
    BOOL didAddMethod = class_addMethod(clazz, originalSelector,
                            method_getImplementation(exchangeMethod),
                            method_getTypeEncoding(exchangeMethod));

    if (didAddMethod) {
        class_replaceMethod(clazz, exchangeSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    }else{
        method_exchangeImplementations(originalMethod, exchangeMethod);
    }
}

