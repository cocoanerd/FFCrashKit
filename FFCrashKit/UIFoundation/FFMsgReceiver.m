//
//  FFMsgReceiver.m
//  FFCrashManager
//
//  Created by tt on 2021/2/23.
//

#import "FFMsgReceiver.h"
#import <objc/runtime.h>

int commonFunc(id target, SEL cmd, ...) {
    return 0;
}

static BOOL __addMethod(Class clazz, SEL sel) {
    NSString *selName = NSStringFromSelector(sel);
    
    NSMutableString *tmpString = [[NSMutableString alloc] initWithFormat:@"%@", selName];
    
    //替换个数：冒号个数 即 入参个数
    int count = (int)[tmpString replaceOccurrencesOfString:@":"
                                                withString:@"_"
                                                   options:NSCaseInsensitiveSearch
                                                     range:NSMakeRange(0, selName.length)];
    //由于后续的参数不需要使用，无需理会传入的参数是什么
    // funcTypeEncoding：添加方法的返回值和参数
    // i(An int) @(An object whether statically typed or typed id) :(A method selector)
    // i(返回值类型)
    // @(id要添加的类)
    // :(A method selector)
    // @(参数类型为id)
    NSMutableString *val = [[NSMutableString alloc] initWithString:@"i@:"];
    for (int i = 0; i < count; i++) {
        [val appendString:@"@"];
    }
    
    const char *funcTypeEncoding = [val UTF8String];
    return class_addMethod(clazz, sel, (IMP)commonFunc, funcTypeEncoding);
}

@implementation FFMsgReceiver

+ (instancetype)sharedInstance {
    static FFMsgReceiver * instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[FFMsgReceiver alloc] init];
    });
    return instance;
}

- (BOOL)addFunc:(SEL)sel {
    return __addMethod([self class], sel);
}

+ (BOOL)addClassFunc:(SEL)sel {
    Class metaClass = objc_getMetaClass(class_getName([self class]));
    return __addMethod(metaClass, sel);
}

@end
