//
//  NSMutableArray+Safe.m
//  FFCrashManager
//
//  Created by tt on 2021/2/23.
//

#import "NSMutableArray+Safe.h"
#import "FFSwizzle.h"
#import "NSObject+UnrecognizedSelectorSafe.h"

@implementation NSMutableArray (Safe)

// MARK: - Public Methods
+ (void)registerMutableArrayCrash {
    
    swizzling_exchangeMethod(NSClassFromString(@"__NSArrayM"), @selector(objectAtIndex:), @selector(arrayM_objectAtIndex:));
    swizzling_exchangeMethod(NSClassFromString(@"__NSArrayM"), @selector(objectAtIndexedSubscript:), @selector(arrayM_objectAtIndexedSubscript:));
    
    swizzling_exchangeMethod(NSClassFromString(@"__NSArrayM"), @selector(addObject:), @selector(arrayM_addObject:));
    swizzling_exchangeMethod(NSClassFromString(@"__NSArrayM"), @selector(insertObject:atIndex:), @selector(arrayM_insertObject:atIndex:));
    swizzling_exchangeMethod(NSClassFromString(@"__NSArrayM"), @selector(setObject:atIndexedSubscript:), @selector(arrayM_setObject:atIndexedSubscript:));
    swizzling_exchangeMethod(NSClassFromString(@"__NSArrayM"), @selector(removeObjectAtIndex:), @selector(arrayM_removeObjectAtIndex:));

}

// MARK: - Private Methods
- (id)arrayM_objectAtIndex:(NSUInteger)index{
    if(index < self.count){
        return [self arrayM_objectAtIndex:index];
    }
    [self sendCrashInfoWithMsg:[NSString stringWithUTF8String:__func__] type:(FFCrashType_Array)];
    return nil;
}

- (id)arrayM_objectAtIndexedSubscript:(NSUInteger)index {
    if(index < self.count){
        return [self arrayM_objectAtIndexedSubscript:index];
    }
    [self sendCrashInfoWithMsg:[NSString stringWithUTF8String:__func__] type:(FFCrashType_Array)];
    return nil;
}

- (void)arrayM_addObject:(id)anObject {
    if (anObject) {
        [self arrayM_addObject:anObject];
    } else {
        [self sendCrashInfoWithMsg:[NSString stringWithUTF8String:__func__] type:(FFCrashType_Array)];
    }
}

- (void)arrayM_insertObject:(id)anObject atIndex:(NSUInteger)index {
    if (anObject && index <= self.count) {
        [self arrayM_insertObject:anObject atIndex:index];
    } else {
        [self sendCrashInfoWithMsg:[NSString stringWithUTF8String:__func__] type:(FFCrashType_Array)];
    }
}

- (void)arrayM_removeObjectAtIndex:(NSUInteger)index {
    if (index < self.count) {
        [self arrayM_removeObjectAtIndex:index];
    } else {
        [self sendCrashInfoWithMsg:[NSString stringWithUTF8String:__func__] type:(FFCrashType_Array)];
    }
}

- (void)arrayM_setObject:(id)obj atIndexedSubscript:(NSUInteger)index {
    if (index <= self.count && obj) {
        [self arrayM_setObject:obj atIndexedSubscript:index];
    } else {
        [self sendCrashInfoWithMsg:[NSString stringWithUTF8String:__func__] type:(FFCrashType_Array)];
    }
}

@end
