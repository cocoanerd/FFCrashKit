//
//  NSDictionary+Safe.m
//  FFCrashManager
//
//  Created by tt on 2021/2/23.
//

#import "NSDictionary+Safe.h"
#import "FFSwizzle.h"
#import "NSObject+UnrecognizedSelectorSafe.h"

@implementation NSDictionary (Safe)

// MARK: - Public Methods
+ (void)registerDictonaryCrash {
    swizzling_exchangeMethod(NSClassFromString(@"__NSPlaceholderDictionary"), @selector(initWithObjects:forKeys:count:), @selector(ff_initWithObjects:forKeys:count:));
}

// MARK: - Private Methods
- (instancetype)ff_initWithObjects:(id  _Nonnull const [])objects forKeys:(id<NSCopying>  _Nonnull const [])keys count:(NSUInteger)cnt {
    NSUInteger index = 0;
    id  _Nonnull __unsafe_unretained newObjects[cnt];
    id  _Nonnull __unsafe_unretained newkeys[cnt];
    for (int i = 0; i < cnt; i++) {
        id tmpItem = objects[i];
        id tmpKey = keys[i];
        if (tmpItem == nil || tmpKey == nil) {
            [self sendCrashInfoWithMsg:[NSString stringWithUTF8String:__func__] type:(FFCrashType_Dictionary)];
            continue;
        }
        newObjects[index] = objects[i];
        newkeys[index] = keys[i];
        index++;
    }
    
    return [self ff_initWithObjects:newObjects forKeys:newkeys count:index];
}

@end
