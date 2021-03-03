//
//  NSArray+Safe.m
//  FFCrashManager
//
//  Created by tt on 2021/2/23.
//

#import "NSArray+Safe.h"
#import "FFSwizzle.h"
#import "NSObject+UnrecognizedSelectorSafe.h"

@implementation NSArray (Safe)

// MARK: - Public Methods
+ (void)registerArrayCrash{
    swizzling_exchangeMethod(objc_getClass("__NSArray0"), @selector(objectAtIndex:), @selector(emptyArray_objectAtIndex:));
    swizzling_exchangeMethod(objc_getClass("__NSArrayI"), @selector(objectAtIndex:), @selector(arrayI_objectAtIndex:));
    swizzling_exchangeMethod(objc_getClass("__NSSingleObjectArrayI"), @selector(objectAtIndex:), @selector(singleObjectArrayI_objectAtIndex:));
    
    swizzling_exchangeMethod(objc_getClass("__NSArray0"), @selector(objectAtIndexedSubscript:), @selector(emptyArray_objectAtIndexedSubscript:));
    swizzling_exchangeMethod(objc_getClass("__NSArrayI"), @selector(objectAtIndexedSubscript:), @selector(arrayI_objectAtIndexedSubscript:));
    swizzling_exchangeMethod(objc_getClass("__NSSingleObjectArrayI"), @selector(objectAtIndex:), @selector(singleObjectArrayI_objectAtIndexedSubscript:));
    
    
    swizzling_exchangeMethod(objc_getClass("__NSArray0"), @selector(arrayWithObjects:count:), @selector(emptyArray_arrayWithObjects:count:));
    swizzling_exchangeMethod(objc_getClass("__NSArrayI"), @selector(arrayWithObjects:count:), @selector(arrayI_arrayWithObjects:count:));
    swizzling_exchangeMethod(objc_getClass("__NSSingleObjectArrayI"), @selector(arrayWithObjects:count:), @selector(singleObjectArrayI_arrayWithObjects:count:));
    
    swizzling_exchangeMethod(objc_getClass("__NSPlaceholderArray"), @selector(initWithObjects:count:), @selector(placeholderArray_initWithObjects:count:));
}

// MARK: - Private Methods
- (id)emptyArray_objectAtIndex:(NSUInteger)index {
    [self sendCrashInfoWithMsg:[NSString stringWithUTF8String:__func__] type:(FFCrashType_Array)];
    return nil;
}

- (id)arrayI_objectAtIndex:(NSUInteger)index {
    if(index < self.count){
        return [self arrayI_objectAtIndex:index];
    }
    [self sendCrashInfoWithMsg:[NSString stringWithUTF8String:__func__] type:(FFCrashType_Array)];
    return nil;
}

- (id)singleObjectArrayI_objectAtIndex:(NSUInteger)index {
    if(index < self.count){
        return [self singleObjectArrayI_objectAtIndex:index];
    }
    [self sendCrashInfoWithMsg:[NSString stringWithUTF8String:__func__] type:(FFCrashType_Array)];
    return nil;
}

- (id)emptyArray_objectAtIndexedSubscript:(NSUInteger)index {
    [self sendCrashInfoWithMsg:[NSString stringWithUTF8String:__func__] type:(FFCrashType_Array)];
    return nil;
}

- (id)arrayI_objectAtIndexedSubscript:(NSUInteger)index {
    if(index < self.count){
        return [self arrayI_objectAtIndex:index];
    }
    [self sendCrashInfoWithMsg:[NSString stringWithUTF8String:__func__] type:(FFCrashType_Array)];
    return nil;
}

- (id)singleObjectArrayI_objectAtIndexedSubscript:(NSUInteger)index {
    if(index < self.count){
        return [self singleObjectArrayI_objectAtIndexedSubscript:index];
    }
    [self sendCrashInfoWithMsg:[NSString stringWithUTF8String:__func__] type:(FFCrashType_Array)];
    return nil;
}

+ (instancetype)emptyArray_arrayWithObjects:(id  _Nonnull const [])objects count:(NSUInteger)count {
    //去掉 nil的数据
    NSInteger newObjsIndex = 0;
    id  _Nonnull __unsafe_unretained newObjects[count];
    for (int i = 0; i < count; i++) {
        
        id objc = objects[i];
        if (objc == nil) {
            [self sendCrashInfoWithMsg:[NSString stringWithUTF8String:__func__] type:(FFCrashType_Array)];
            continue;
        }
        newObjects[newObjsIndex++] = objc;
    }
    return [self emptyArray_arrayWithObjects:newObjects count:newObjsIndex];
}

+ (instancetype)arrayI_arrayWithObjects:(id  _Nonnull const [])objects count:(NSUInteger)count {
    //去掉 nil的数据
    NSInteger newObjsIndex = 0;
    id  _Nonnull __unsafe_unretained newObjects[count];
    for (int i = 0; i < count; i++) {
        
        id objc = objects[i];
        if (objc == nil) {
            [self sendCrashInfoWithMsg:[NSString stringWithUTF8String:__func__] type:(FFCrashType_Array)];
            continue;
        }
        newObjects[newObjsIndex++] = objc;
    }
    return [self arrayI_arrayWithObjects:newObjects count:newObjsIndex];
}

+ (instancetype)singleObjectArrayI_arrayWithObjects:(id  _Nonnull const [])objects count:(NSUInteger)count {
    //去掉 nil的数据
    NSInteger newObjsIndex = 0;
    id  _Nonnull __unsafe_unretained newObjects[count];
    for (int i = 0; i < count; i++) {
        
        id objc = objects[i];
        if (objc == nil) {
            [self sendCrashInfoWithMsg:[NSString stringWithUTF8String:__func__] type:(FFCrashType_Array)];
            continue;
        }
        newObjects[newObjsIndex++] = objc;
    }
    return [self singleObjectArrayI_arrayWithObjects:newObjects count:newObjsIndex];
}

- (instancetype)placeholderArray_initWithObjects:(id  _Nonnull const [])objects count:(NSUInteger)count {
    //去掉 nil的数据
    NSInteger newObjsIndex = 0;
    id  _Nonnull __unsafe_unretained newObjects[count];
    for (int i = 0; i < count; i++) {
        
        id objc = objects[i];
        if (objc == nil) {
            [self sendCrashInfoWithMsg:[NSString stringWithUTF8String:__func__] type:(FFCrashType_Array)];
            continue;
        }
        newObjects[newObjsIndex++] = objc;
    }
    return [self placeholderArray_initWithObjects:newObjects count:newObjsIndex];
}

@end
