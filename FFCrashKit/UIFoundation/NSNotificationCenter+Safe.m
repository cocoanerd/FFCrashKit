//
//  NSNotificationCenter+Safe.m
//  FFCrashManager
//
//  Created by tt on 2021/2/23.
//

#import "NSNotificationCenter+Safe.h"
#import "FFSwizzle.h"

// MARK: - FFNotifiProxy
@interface FFNotifiProxy : NSObject

@end

@implementation FFNotifiProxy{
    __strong NSMutableArray *_centers;
    __unsafe_unretained id _obs;
}

- (instancetype)initWithObserver:(id)obs {
    if (self = [super init]) {
        _obs = obs;
        _centers = @[].mutableCopy;
    }
    return self;
}

- (void)addCenter:(NSNotificationCenter*)center {
    if (center) {
        [_centers addObject:center];
    }
}

- (void)dealloc {
    @autoreleasepool {
        for (NSNotificationCenter *center in _centers) {
            [center removeObserver:_obs];
        }
    }
}

@end

// MARK: - NSNotificationCenter(Safe)
@implementation NSNotificationCenter (Safe)

// MARK: - Public Methods
+ (void)registerNotificationCenterCrash {
    swizzling_exchangeMethod([self class], @selector(addObserver:selector:name:object:), @selector(ff_addObserver:selector:name:object:));
}

// MARK: - Private Methods
- (void)ff_addObserver:(id)observer selector:(SEL)aSelector name:(NSNotificationName)aName object:(id)anObject
{
    [self ff_addObserver:observer selector:aSelector name:aName object:anObject];
    [self addCenterForObserver:self obs:observer];
}

- (void)addCenterForObserver:(NSNotificationCenter *)center obs:(id)obs {
    FFNotifiProxy *remover = nil;
    static char removerKey;
    @autoreleasepool {
        remover = objc_getAssociatedObject(obs, &removerKey);
        if (!remover) {
            remover = [[FFNotifiProxy alloc] initWithObserver:obs];
            objc_setAssociatedObject(obs, &removerKey, remover, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        [remover addCenter:center];
    }
}
@end
