//
//  NSNull+Safe.m
//  FFCrashManager
//
//  Created by tt on 2021/2/23.
//

#import "NSNull+Safe.h"
#import "FFSwizzle.h"
#import "FFCrashModel.h"
#import "FFCrashReport.h"

@implementation NSNull (Safe)

// MARK: - Public Methods
+ (void)registerNullCrash {
    swizzling_exchangeMethod([self class], @selector(forwardingTargetForSelector:), @selector(FFNullsafe_forwardingTargetForSelector:));
}

// MARK: - Private Methods
- (id)FFNullsafe_forwardingTargetForSelector:(SEL)aSelector {
    static NSArray * stubObjArr = nil;
    if (!stubObjArr) {
        stubObjArr = @[@"",@0,@[],@{}];
    }
    for (id obj in stubObjArr) {
        if ([obj respondsToSelector:aSelector]) {
            FFCrashModel * model = [[FFCrashModel alloc] init];
            model.className = NSStringFromClass([self class]);
            model.msg = [NSString stringWithFormat:@"send %@'s method %@ to null",NSStringFromClass([obj class]),NSStringFromSelector(aSelector)];
            model.threadStack = [NSThread callStackSymbols];
            [FFCrashReport crashInfo:model type:(FFCrashType_Null)];
            return obj;
        }
    }
    return [self FFNullsafe_forwardingTargetForSelector:aSelector];
}
@end
