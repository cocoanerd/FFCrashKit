#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "FFCrashKit.h"
#import "FFCrashReport.h"
#import "FFSwizzle.h"
#import "FFCrashRegeister.h"
#import "FFCrashModel.h"
#import "FFMsgReceiver.h"
#import "NSArray+Safe.h"
#import "NSDictionary+Safe.h"
#import "NSMutableArray+Safe.h"
#import "NSMutableDictionary+Safe.h"
#import "NSMutableSet+Safe.h"
#import "NSMutableString+Safe.h"
#import "NSNotificationCenter+Safe.h"
#import "NSNull+Safe.h"
#import "NSObject+KVCSafe.h"
#import "NSObject+KVOSafe.h"
#import "NSObject+UnrecognizedSelectorSafe.h"
#import "NSString+Safe.h"

FOUNDATION_EXPORT double FFCrashKitVersionNumber;
FOUNDATION_EXPORT const unsigned char FFCrashKitVersionString[];

