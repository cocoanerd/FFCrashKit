//
//  NSObject+KVOSafe.m
//  FFCrashManager
//
//  Created by tt on 2021/3/1.
//

#import "NSObject+KVOSafe.h"
#import "FFSwizzle.h"
#import <objc/runtime.h>
#import "NSObject+UnrecognizedSelectorSafe.h"

// 判断是否是系统类
static inline BOOL IsSystemClass(Class cls){
    BOOL isSystem = NO;
    NSString *className = NSStringFromClass(cls);
    if ([className hasPrefix:@"NS"] || [className hasPrefix:@"__NS"] || [className hasPrefix:@"OS_xpc"]) {
        isSystem = YES;
        return isSystem;
    }
    NSBundle *mainBundle = [NSBundle bundleForClass:cls];
    if (mainBundle == [NSBundle mainBundle]) {
        isSystem = NO;
    }else{
        isSystem = YES;
    }
    return isSystem;
}

// MARK:  - FFKVOProxy 相关
@interface FFKVOProxy : NSObject

/// 获取所有被观察的 keyPaths
- (NSArray *)getAllKeyPaths;

@end

@implementation FFKVOProxy {
    // 关系数据表结构：{keypath : [observer1, observer2 , ...](NSHashTable)}
    @private
    NSMutableDictionary<NSString *, NSHashTable<NSObject *> *> *_kvoInfoMap;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _kvoInfoMap = [NSMutableDictionary dictionary];
    }
    return self;
}

// 添加 KVO 信息操作, 添加成功返回 YES
- (BOOL)addInfoToMapWithObserver:(NSObject *)observer
                      forKeyPath:(NSString *)keyPath
                         options:(NSKeyValueObservingOptions)options
                         context:(void *)context {
    
    @synchronized (self) {
        if (!observer || !keyPath ||
            ([keyPath isKindOfClass:[NSString class]] && keyPath.length <= 0)) {
            return NO;
        }
        
        NSHashTable<NSObject *> *info = _kvoInfoMap[keyPath];
        if (info.count == 0) {
            info = [[NSHashTable alloc] initWithOptions:(NSPointerFunctionsWeakMemory) capacity:0];
            [info addObject:observer];

            _kvoInfoMap[keyPath] = info;
            
            return YES;
        }
        
        if (![info containsObject:observer]) {
            [info addObject:observer];
        }
        
        return NO;
    }
}

// 移除 KVO 信息操作, 添加成功返回 YES
- (BOOL)removeInfoInMapWithObserver:(NSObject *)observer
                         forKeyPath:(NSString *)keyPath {
    
    @synchronized (self) {
        if (!observer || !keyPath ||
            ([keyPath isKindOfClass:[NSString class]] && keyPath.length <= 0)) {
            return NO;
        }
        
        NSHashTable<NSObject *> *info = _kvoInfoMap[keyPath];
        
        if (info.count == 0) {
            return NO;
        }
        
        [info removeObject:observer];
        
        if (info.count == 0) {
            [_kvoInfoMap removeObjectForKey:keyPath];
            
            return YES;
        }
        
        return NO;
    }
}

// 添加 KVO 信息操作, 添加成功返回 YES
- (BOOL)removeInfoInMapWithObserver:(NSObject *)observer
                         forKeyPath:(NSString *)keyPath
                            context:(void *)context {
    @synchronized (self) {
        if (!observer || !keyPath ||
            ([keyPath isKindOfClass:[NSString class]] && keyPath.length <= 0)) {
            return NO;
        }
    
        NSHashTable<NSObject *> *info = _kvoInfoMap[keyPath];
    
        if (info.count == 0) {
            return NO;
        }
    
        [info removeObject:observer];
    
        if (info.count == 0) {
            [_kvoInfoMap removeObjectForKey:keyPath];
            
            return YES;
        }
    
        return NO;
    }
}

// 实际观察者 FFKVOProxy 进行监听，并分发
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {

    NSHashTable<NSObject *> *info = _kvoInfoMap[keyPath];
    
    for (NSObject *observer in info) {
        @try {
            [observer observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        } @catch (NSException *exception) {
            NSString *reason = [NSString stringWithFormat:@"KVO CrashInfo : %@",[exception description]];
            NSLog(@"%@",reason);
        }
    }
}

// 获取所有被观察的 keyPaths
- (NSArray *)getAllKeyPaths {
    NSArray <NSString *>*keyPaths = _kvoInfoMap.allKeys;
    return keyPaths;
}

@end


// MARK: - NSObject+KVOSafe
@implementation NSObject (KVOSafe)

+ (void)registerKVOCrash {
    
    swizzling_exchangeMethod([self class], @selector(addObserver:forKeyPath:options:context:), @selector(ff_addObserver:forKeyPath:options:context:));
    swizzling_exchangeMethod([self class], @selector(removeObserver:forKeyPath:), @selector(ff_removeObserver:forKeyPath:));
    swizzling_exchangeMethod([self class], @selector(removeObserver:forKeyPath:context:), @selector(ff_removeObserver:forKeyPath:context:));
    swizzling_exchangeMethod([self class], NSSelectorFromString(@"dealloc"), @selector(ff_kvodealloc));
}

static void *FFKVOProxyKey = &FFKVOProxyKey;
static NSString *const KVOSafeValue = @"ff_KVOSafeValue";
static void *KVOSafeKey = &KVOSafeKey;

// FFKVOProxy setter 方法
- (void)setFFKVOProxy:(FFKVOProxy *)FFKVOProxy {
    objc_setAssociatedObject(self, FFKVOProxyKey, FFKVOProxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// FFKVOProxy getter 方法
- (FFKVOProxy *)FFKVOProxy {
    id FFKVOProxy = objc_getAssociatedObject(self, FFKVOProxyKey);
    if (FFKVOProxy == nil) {
        FFKVOProxy = [[FFKVOProxy alloc] init];
        self.FFKVOProxy = FFKVOProxy;
    }
    return FFKVOProxy;
}

- (void)ff_addObserver:(NSObject *)observer
             forKeyPath:(NSString *)keyPath
                options:(NSKeyValueObservingOptions)options
                context:(void *)context {
    
    if (!IsSystemClass(self.class)) {
        objc_setAssociatedObject(self, KVOSafeKey, KVOSafeValue, OBJC_ASSOCIATION_RETAIN);
        if ([self.FFKVOProxy addInfoToMapWithObserver:observer forKeyPath:keyPath options:options context:context]) {
            // 如果添加 KVO 信息操作成功，则调用系统添加方法
            [self ff_addObserver:self.FFKVOProxy forKeyPath:keyPath options:options context:context];
        } else {
            // 添加 KVO 信息操作失败：重复添加
            NSString *className = (NSStringFromClass(self.class) == nil) ? @"" : NSStringFromClass(self.class);
            NSString *reason = [NSString stringWithFormat:@"KVO CrashInfo : Repeated additions to the observer:%@ for the key path:'%@' from %@",
                                observer, keyPath, className];
            [self sendCrashInfoWithMsg:reason type:(FFCrashType_KVO)];
        }
    } else {
        [self ff_addObserver:observer forKeyPath:keyPath options:options context:context];
    }
}

- (void)ff_removeObserver:(NSObject *)observer
                forKeyPath:(NSString *)keyPath
                   context:(void *)context {
    
    if (!IsSystemClass(self.class)) {
        if ([self.FFKVOProxy removeInfoInMapWithObserver:observer forKeyPath:keyPath context:context]) {
            // 如果移除 KVO 信息操作成功，则调用系统移除方法
            [self ff_removeObserver:self.FFKVOProxy forKeyPath:keyPath context:context];
        } else {
            // 移除 KVO 信息操作失败：移除了未注册的观察者
            NSString *className = NSStringFromClass(self.class) == nil ? @"" : NSStringFromClass(self.class);
            NSString *reason = [NSString stringWithFormat:@"KVO CrashInfo : Cannot remove an observer %@ for the key path '%@' from %@ , because it is not registered as an observer", observer, keyPath, className];
            [self sendCrashInfoWithMsg:reason type:(FFCrashType_KVO)];
        }
    } else {
        [self ff_removeObserver:observer forKeyPath:keyPath context:context];
    }
}

- (void)ff_removeObserver:(NSObject *)observer
                forKeyPath:(NSString *)keyPath {
    
    if (!IsSystemClass(self.class)) {
        if ([self.FFKVOProxy removeInfoInMapWithObserver:observer forKeyPath:keyPath]) {
            // 如果移除 KVO 信息操作成功，则调用系统移除方法
            [self ff_removeObserver:self.FFKVOProxy forKeyPath:keyPath];
        } else {
            // 移除 KVO 信息操作失败：移除了未注册的观察者
            NSString *className = NSStringFromClass(self.class) == nil ? @"" : NSStringFromClass(self.class);
            NSString *reason = [NSString stringWithFormat:@"KVO CrashInfo : Cannot remove an observer %@ for the key path '%@' from %@ , because it is not registered as an observer", observer, keyPath, className];
            [self sendCrashInfoWithMsg:reason type:(FFCrashType_KVO)];
        }
    } else {
        [self ff_removeObserver:observer forKeyPath:keyPath];
    }
    
}

- (void)ff_kvodealloc {
    @autoreleasepool {
        if (!IsSystemClass(self.class)) {
            NSString *value = (NSString *)objc_getAssociatedObject(self, KVOSafeKey);
            if ([value isEqualToString:KVOSafeValue]) {
                NSArray *keyPaths =  [self.FFKVOProxy getAllKeyPaths];
                // 被观察者在 dealloc 时仍然注册着 KVO
                if (keyPaths.count > 0) {
                    NSString *reason = [NSString stringWithFormat:@"KVO CrashInfo : An instance %@ was deallocated while key value observers were still registered with it. The Keypaths is:'%@'", self, [keyPaths componentsJoinedByString:@","]];
                    [self sendCrashInfoWithMsg:reason type:(FFCrashType_KVO)];
                }
                
                // 移除多余的观察者
                for (NSString *keyPath in keyPaths) {
                    [self ff_removeObserver:self.FFKVOProxy forKeyPath:keyPath];
                }
            }
        }
    }
    
    [self ff_kvodealloc];
}

@end
