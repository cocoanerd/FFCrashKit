//
//  FFCrashReport.m
//  FFCrashManager
//
//  Created by tt on 2021/2/23.
//

#import "FFCrashReport.h"
#import "FFCrashModel.h"

static NSString * FFeStr = @"FF++";

@implementation FFCrashReport

/// 单例对象
+ (instancetype)sharedReport {
    static FFCrashReport * instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[FFCrashReport alloc] init];
    });
    return  instance;
}

// MARK: - 存储相关
/// 存储Crash信息：原因+stack
/// @param model model
/// @param type Crash类型
+ (void)crashInfo:(FFCrashModel *)model type:(FFCrashType)type {
    
    // 获取崩溃类型key标识
    NSString * crashTypeKey = [self getPathKeyWithType:type];
#ifdef DEBUG
    NSLog(@"============================================");
    NSLog(@"Crash");
    NSLog(@"CrashDevice : %@(%@)",model.deviceType,model.systemVersion);
    NSLog(@"CrashType : %@",crashTypeKey);
    NSLog(@"CrashClass : %@",model.className);
    NSLog(@"CrashMsg : %@",model.msg);
    NSLog(@"CrashStackInfo ↓↓↓↓↓↓↓↓ ");
    NSLog(@"%@",model.threadStack);
    NSLog(@"============================================");
#endif
    FFCrashReport * report = [self sharedReport];
    // 这里可以根据实际情况进行上报到第三方，便于跟踪修复
    // 预留：崩溃信息处理
    if ([report.delegate respondsToSelector:@selector(handleCrashInfo:type:)]) {
        [report.delegate handleCrashInfo:model type:crashTypeKey];
    }
    
    [self storageCrashToLocal:model type:type];
    
}

/// 本地存储Crash
/// @param model model
/// @param type type
+ (void)storageCrashToLocal:(FFCrashModel *)model type:(FFCrashType)type {
    NSDictionary * dict = [self getCrashReportWithType:type];
    if (dict) {
        // newLogDict以crash类型为key，存放所有crashLog
        NSMutableDictionary * newLogDict = [[NSMutableDictionary alloc] initWithDictionary:dict];
        BOOL isFisrtReport = YES;
        for (NSString * key in [newLogDict allKeys]) {
            // 此类型已经上报过
            if ([key isEqualToString:model.className]) {
                NSArray * infos = [newLogDict objectForKey:key];
                NSMutableArray * newInfos = [NSMutableArray array];
                for (NSString * info in infos) {//分割 +selname分割符count
                    NSArray * result = [info componentsSeparatedByString:FFeStr];
                    // 已经上报过此类型此方法的崩溃，崩溃次数+1；否则加入此类型方此方法的崩溃信息
                    if ([result.firstObject isEqualToString:model.msg]) {
                        NSUInteger count = [[result objectAtIndex:1] integerValue] + 1;
                        NSString * countStr = [NSString stringWithFormat:@"%lu",(unsigned long)count];
                        NSString * str = [NSString stringWithFormat:@"%@%@%@%@%@",model.msg,FFeStr,countStr,FFeStr,model.timeStr];
                        [newInfos addObject:str];
                        isFisrtReport = NO;
                    } else {
                        [newInfos addObject:info];
                    }
                }
                // 首次上报此类型
                if (isFisrtReport) {
                    NSString * str = [NSString stringWithFormat:@"%@%@1%@%@",model.msg,FFeStr,FFeStr,model.timeStr];
                    isFisrtReport = NO;
                    [newInfos addObject:str];
                }
                [newLogDict setValue:newInfos forKey:key];
                break;
            }
        }
        //首次上报
        if (isFisrtReport) {
            NSString * str = [NSString stringWithFormat:@"%@%@1%@%@",model.msg,FFeStr,FFeStr,model.timeStr];
            [newLogDict setValue:@[str] forKey:model.className];
            isFisrtReport = NO;
        }
        NSString * path = [self getCrashLogPathType:type];
        if (path) {
            __unused BOOL flag = [newLogDict writeToFile:path atomically:YES];
        }
    }
}

/// 根据Crash类型获取崩溃日志pathKey
/// @param type Crash类型
+ (NSString * _Nullable)getPathKeyWithType:(FFCrashType)type {
    switch (type) {
        case FFCrashType_UnrecognizedSelector:
            return @"UnrecognizedSelector";
        case FFCrashType_Array:
            return @"Array";
        case FFCrashType_Dictionary:
            return @"Dictionary";
        case FFCrashType_Set:
            return @"Set";
        case FFCrashType_Null:
            return @"Null";
        case FFCrashType_NotificationCenter:
            return @"NotificationCenter";
        case FFCrashType_String:
            return @"String";
        case FFCrashType_KVC:
            return @"KVC";
        case FFCrashType_KVO:
            return @"KVO";
    }
    return nil;
}

/// 根据崩溃类型获取崩溃日志路径
/// @param type Crash类型
+ (NSString * _Nullable)getCrashLogPathType:(FFCrashType)type {
    NSString * key = [self getPathKeyWithType:type];
    if (!key) {
        return nil;
    }
    NSString *documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString * lastPath = [NSString stringWithFormat:@"FF_%@.CrashLog",key];
    NSString *logPath = [documentsPath stringByAppendingPathComponent:lastPath];
    return logPath;
}

/// 根据path获取内容
/// @param path path
+ (NSDictionary *)getContentWithPath:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isExist = [fileManager fileExistsAtPath:path];
    if (isExist) {
        return [NSDictionary dictionaryWithContentsOfFile:path];
    }
    return @{};
}

/// 获取崩溃报告
/// @param type Crash类型
+ (NSDictionary *)getCrashReportWithType:(FFCrashType)type {
    NSString * path  = [self getCrashLogPathType:type];
    if (!path) {
        return @{};
    }
    return [self getContentWithPath:path];
}

/// 获取所有崩溃报告
+ (NSArray *)getAllCrashReport {
    NSMutableArray * arr = [[NSMutableArray alloc] init];
    NSArray *typeArray = @[[NSNumber numberWithInteger:FFCrashType_UnrecognizedSelector],
                           [NSNumber numberWithInteger:FFCrashType_Array],
                           [NSNumber numberWithInteger:FFCrashType_Dictionary],
                           [NSNumber numberWithInteger:FFCrashType_Set],
                           [NSNumber numberWithInteger:FFCrashType_Null],
                           [NSNumber numberWithInteger:FFCrashType_String],
                           [NSNumber numberWithInteger:FFCrashType_NotificationCenter],
                           [NSNumber numberWithInteger:FFCrashType_KVC],
                           [NSNumber numberWithInteger:FFCrashType_KVO]
                           ];
    for (NSNumber *number in typeArray) {
        [arr addObject:[self getCrashReportWithType:[number integerValue]]];
    }
    return arr.copy;
}

@end
