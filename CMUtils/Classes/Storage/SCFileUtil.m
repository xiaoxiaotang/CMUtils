//
//  SCFileUtil.m
//  SaicCarPlatform
//
//  Created by admin on 2018/7/13.
//  Copyright © 2018年 Saic. All rights reserved.
//

#import "SCFileUtil.h"

@implementation SCFileUtil

//获取Document路径
+ (NSString *)sc_getDocumentPath
{
    NSArray *filePaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [filePaths objectAtIndex:0];
}

//获取Library路径
+ (NSString *)sc_getLibraryPath
{
    NSArray *filePaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    return [filePaths objectAtIndex:0];
}

//获取应用程序路径
+ (NSString *)sc_getApplicationPath
{
    return NSHomeDirectory();
}

// 获取MainBundle资源路径
+ (NSString *)sc_getMainBundlePath {
    return [NSBundle mainBundle].bundlePath;
}

+ (NSBundle *)getCustomBundleWithClass:(Class)bundleClass {
    NSBundle *customBundle = [NSBundle bundleForClass:bundleClass];
    NSBundle *resourceBundle = [NSBundle bundleWithPath:[customBundle pathForResource:NSStringFromClass(bundleClass) ofType:@"bundle"]];
    if (resourceBundle == nil) {
        resourceBundle = customBundle;
    }
    return resourceBundle;
}

+ (NSString *)sc_getCustomBundlePathWithClass:(Class)bundleClass {
    return [self getCustomBundleWithClass:bundleClass].bundlePath;
}

//获取Cache路径
+ (NSString *)sc_getCachePath
{
    NSArray *filePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [filePaths objectAtIndex:0];
}

//获取Temp路径
+ (NSString *)sc_getTempPath
{
    return NSTemporaryDirectory();
}

//  沙盒中Preferences文件的路径
+ (NSString *)sc_getPreferencesPath {
    return [NSSearchPathForDirectoriesInDomains(NSPreferencePanesDirectory, NSUserDomainMask, YES) lastObject];
}

//判断文件是否存在于某个路径中
+ (BOOL)sc_fileIsExistOfPath:(NSString *)filePath
{
    BOOL flag = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]) {
        flag = YES;
    } else {
        flag = NO;
    }
    return flag;
}

//从某个路径中移除文件
+ (BOOL)sc_removeFileOfPath:(NSString *)filePath
{
    BOOL flag = YES;
    NSFileManager *fileManage = [NSFileManager defaultManager];
    if ([fileManage fileExistsAtPath:filePath]) {
        if (![fileManage removeItemAtPath:filePath error:nil]) {
            flag = NO;
        }
    }
    return flag;
}

//从URL路径中移除文件
- (BOOL)sc_removeFileOfURL:(NSURL *)fileURL
{
    BOOL flag = YES;
    NSFileManager *fileManage = [NSFileManager defaultManager];
    if ([fileManage fileExistsAtPath:fileURL.path]) {
        if (![fileManage removeItemAtURL:fileURL error:nil]) {
            flag = NO;
        }
    }
    return flag;
}

//创建文件路径
+(BOOL)sc_creatDirectoryWithPath:(NSString *)dirPath
{
    BOOL ret = YES;
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:dirPath];
    if (!isExist) {
        NSError *error;
        BOOL isSuccess = [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:&error];
        if (!isSuccess) {
            ret = NO;
            NSLog(@"creat Directory Failed. errorInfo:%@",error);
        }
    }
    return ret;
}

//创建文件
+ (BOOL)sc_creatFileWithPath:(NSString *)filePath
{
    BOOL isSuccess = YES;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL temp = [fileManager fileExistsAtPath:filePath];
    if (temp) {
        return YES;
    }
    NSError *error;
    //stringByDeletingLastPathComponent:删除最后一个路径节点
    NSString *dirPath = [filePath stringByDeletingLastPathComponent];
    isSuccess = [fileManager createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:&error];
    if (error) {
        NSLog(@"creat File Failed. errorInfo:%@",error);
    }
    if (!isSuccess) {
        return isSuccess;
    }
    isSuccess = [fileManager createFileAtPath:filePath contents:nil attributes:nil];
    return isSuccess;
}

//保存文件
+ (BOOL)sc_saveFile:(NSString *)filePath withData:(NSData *)data
{
    BOOL ret = YES;
    ret = [self sc_creatFileWithPath:filePath];
    if (ret) {
        ret = [data writeToFile:filePath atomically:YES];
        if (!ret) {
            NSLog(@"%s Failed",__FUNCTION__);
        }
    } else {
        NSLog(@"%s Failed",__FUNCTION__);
    }
    return ret;
}

//追加写文件
+ (BOOL)sc_appendData:(NSData *)data withPath:(NSString *)path
{
    BOOL result = [self sc_creatFileWithPath:path];
    if (result) {
        NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:path];
        [handle seekToEndOfFile];
        [handle writeData:data];
        [handle synchronizeFile];
        [handle closeFile];
        return YES;
    } else {
        NSLog(@"%s Failed",__FUNCTION__);
        return NO;
    }
}

//获取文件
+ (NSData *)sc_getFileData:(NSString *)filePath
{
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:filePath];
    NSData *fileData = [handle readDataToEndOfFile];
    [handle closeFile];
    return fileData;
}

//读取文件
+ (NSData *)sc_getFileData:(NSString *)filePath startIndex:(long long)startIndex length:(NSInteger)length
{
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:filePath];
    [handle seekToFileOffset:startIndex];
    NSData *data = [handle readDataOfLength:length];
    [handle closeFile];
    return data;
}

//移动文件
+ (BOOL)sc_moveFileFromPath:(NSString *)fromPath toPath:(NSString *)toPath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:fromPath]) {
        NSLog(@"Error: fromPath Not Exist");
        return NO;
    }
    if (![fileManager fileExistsAtPath:toPath]) {
        NSLog(@"Error: toPath Not Exist");
        return NO;
    }
    NSString *headerComponent = [toPath stringByDeletingLastPathComponent];
    if ([self sc_creatFileWithPath:headerComponent]) {
        return [fileManager moveItemAtPath:fromPath toPath:toPath error:nil];
    } else {
        return NO;
    }
}

//拷贝文件
+(BOOL)sc_copyFileFromPath:(NSString *)fromPath toPath:(NSString *)toPath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:fromPath]) {
        NSLog(@"Error: fromPath Not Exist");
        return NO;
    }
    if (![fileManager fileExistsAtPath:toPath]) {
        NSLog(@"Error: toPath Not Exist");
        return NO;
    }
    NSString *headerComponent = [toPath stringByDeletingLastPathComponent];
    if ([self sc_creatFileWithPath:headerComponent]) {
        return [fileManager copyItemAtPath:fromPath toPath:toPath error:nil];
    } else {
        return NO;
    }
}

//获取文件夹下文件列表
+ (NSArray *)sc_getFileListInFolderWithPath:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *fileList = [fileManager contentsOfDirectoryAtPath:path error:&error];
    if (error) {
        NSLog(@"getFileListInFolderWithPathFailed, errorInfo:%@",error);
    }
    return fileList;
}

//获取文件大小
+ (long long)sc_getFileSizeWithPath:(NSString *)path
{
    unsigned long long fileLength = 0;
    NSNumber *fileSize;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:path error:nil];
    if ((fileSize = [fileAttributes objectForKey:NSFileSize])) {
        fileLength = [fileSize unsignedLongLongValue]; //单位是 B
    }
    return fileLength / 1000; //换算为K
}

//获取文件创建时间
+ (NSString *)sc_getFileCreatDateWithPath:(NSString *)path
{
    NSString *date = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:path error:nil];
    date = [fileAttributes objectForKey:NSFileCreationDate];
    return date;
}

//获取文件所有者
+ (NSString *)sc_getFileOwnerWithPath:(NSString *)path
{
    NSString *fileOwner = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:path error:nil];
    fileOwner = [fileAttributes objectForKey:NSFileOwnerAccountName];
    return fileOwner;
}

//获取文件更改日期
+ (NSString *)sc_getFileChangeDateWithPath:(NSString *)path
{
    NSString *date = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:path error:nil];
    date = [fileAttributes objectForKey:NSFileModificationDate];
    return date;
}

@end
