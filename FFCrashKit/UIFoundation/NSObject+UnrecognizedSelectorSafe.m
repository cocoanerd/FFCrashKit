//
//  NSObject+UnrecognizedSelectorSafe.m
//  FFCrashManager
//
//  Created by tt on 2021/2/23.
//

#import "NSObject+UnrecognizedSelectorSafe.h"
#import "FFMsgReceiver.h"
#import "FFCrashReport.h"
#import "FFCrashModel.h"

@implementation NSObject (UnrecognizedSelectorSafe)

// MARK: - Public Methods
+ (void)registerUnrecognizedSelectorCrash {
    
    swizzling_exchangeMethod([self class], @selector(forwardingTargetForSelector:), @selector(ff_forwardingTargetForSelector:));
    swizzling_exchangeMethod(objc_getMetaClass([NSStringFromClass([self class]) UTF8String]) , @selector(forwardingTargetForSelector:), @selector(ff_forwardingTargetForSelector:));
    
}

- (void)sendCrashInfoWithMsg:(NSString *)msg type:(FFCrashType)type {
    FFCrashModel * model = [[FFCrashModel alloc] init];
    model.className = NSStringFromClass([self class]);
    model.msg =  msg;
    model.threadStack = [NSThread callStackSymbols];
    [FFCrashReport crashInfo:model type:type];
}

// MARK: - Private Methods
- (id)ff_forwardingTargetForSelector:(SEL)aSelector {
    
    // 如果当前类实现了这两个方法中的一个，则调用原生。防止系统类自己实现转发被拦截
    if ([self canRespondForwardingMsg] || [self isInWhiteList]) {
        // 即便是子类实现了forwardingTargetForSelector且调用了self或父类的方法，这里也不会崩溃
        // 因为如果出错了，是会走到NSObject的forwardingTargetForSelector
        return [self ff_forwardingTargetForSelector:aSelector];
    }
    
    NSString * selName = NSStringFromSelector(aSelector);
    if ([self isKindOfClass:[NSNumber class]] && [NSString instancesRespondToSelector:aSelector]) {
        NSNumber *number = (NSNumber *)self;
        NSString *str = [number stringValue];
        return str;
    } else if ([self isKindOfClass:[NSString class]] && [NSNumber instancesRespondToSelector:aSelector]) {
        NSString *str = (NSString *)self;
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        NSNumber *number = [formatter numberFromString:str];
        return number;
    }
    BOOL aBool = [self respondsToSelector:aSelector];
    NSMethodSignature *signatrue = [self methodSignatureForSelector:aSelector];
    if (aBool && signatrue) {
        return [self ff_forwardingTargetForSelector:aSelector];
    } else {
        NSLog(@"实例方法出错了");
        [[FFMsgReceiver sharedInstance] addFunc:aSelector];
        [self sendCrashInfoWithMsg:[@"-" stringByAppendingString:selName] type:FFCrashType_UnrecognizedSelector];
        return [FFMsgReceiver sharedInstance];
    }
}

+ (id)ff_forwardingTargetForSelector:(SEL)aSelector {
    NSString * selName = NSStringFromSelector(aSelector);
    
    BOOL aBool = [self respondsToSelector:aSelector];
    NSMethodSignature *signatrue = [self methodSignatureForSelector:aSelector];
    if (aBool && signatrue) {
        return [self ff_forwardingTargetForSelector:aSelector];
    } else {
        NSLog(@"类方法出错了");
        [FFMsgReceiver addClassFunc:aSelector];
        [self sendCrashInfoWithMsg:[@"+" stringByAppendingString:selName] type:FFCrashType_UnrecognizedSelector];
        return [FFMsgReceiver class];
    }
}

- (BOOL)canRespondForwardingMsg {
    // 只要实现了forwardinvocation方法，则表明系统类实现了转发流程
    NSArray * selectors = @[NSStringFromSelector(@selector(forwardInvocation:))];
    BOOL result = NO;
    u_int count;
    Method *methods= class_copyMethodList([self class], &count);
    for (int i = 0; i < count ; i++) {
        SEL name = method_getName(methods[i]);
        for (NSString * selName in selectors) {
            SEL selector = NSSelectorFromString(selName);
            //如果有任意一个 则直接yes
            if (name == selector) {
                result = YES;
                break;
            }
        }
        if (result) {
            break;
        }
    }
    
    if (methods != NULL) {
        free(methods);
        methods = NULL;
    }
    
    return result;
}

- (BOOL)isInWhiteList {
    if ([[NSObject msgWhiteList] containsObject:NSStringFromClass([self class])]) {
        return YES;
    }
    return NO;
}

+ (NSArray *)msgWhiteList {
    static NSArray * whiteList = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        whiteList = @[@"_UIBarItemAppearance",
                      @"_UIPropertyBasedAppearance",
                      @"_NSXPCDistantObjectSynchronousWithError",
                      @"_UITraitBasedAppearance",
                      @"UIWebBrowserView"];
    });
    return whiteList;
}

@end
