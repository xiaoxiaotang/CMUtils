//
//  SCFileUtil.h
//  SaicCarPlatform
//
//  Created by admin on 2018/7/13.
//  Copyright © 2018年 Saic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SCFileUtil : NSObject

/** 获取Document路径*/
+ (NSString *)sc_getDocumentPath;

/** 获取Library路径*/
+ (NSString *)sc_getLibraryPath;

/** 获取应用程序路径*/
+ (NSString *)sc_getApplicationPath;

/** 获取MainBundle资源路径*/
+ (NSString *)sc_getMainBundlePath;

/**
 获取自定义bundle资源路径

 @param bundleClass 自定义bundle类名
 @return 返回自定义资源路径
 @note 自定义资源名和bundleClass一致
 */
+ (NSString *)sc_getCustomBundlePathWithClass:(Class)bundleClass;

/** 获取Cache路径*/
+ (NSString *)sc_getCachePath;

/** 获取Temp路径*/
+ (NSString *)sc_getTempPath;

/** 沙盒中Preferences文件的路径*/
+ (NSString *)sc_getPreferencesPath;

/** 判断文件是否存在于某个路径中*/
+ (BOOL)sc_fileIsExistOfPath:(NSString *)filePath;

/** 从某个路径中移除文件*/
+ (BOOL)sc_removeFileOfPath:(NSString *)filePath;

/** 从URL路径中移除文件*/
- (BOOL)sc_removeFileOfURL:(NSURL *)fileURL;

/** 创建文件路径*/
+(BOOL)sc_creatDirectoryWithPath:(NSString *)dirPath;

/** 创建文件*/
+ (BOOL)sc_creatFileWithPath:(NSString *)filePath;

/** 保存文件*/
+ (BOOL)sc_saveFile:(NSString *)filePath withData:(NSData *)data;

/** 追加写文件*/
+ (BOOL)sc_appendData:(NSData *)data withPath:(NSString *)path;

/** 获取文件*/
+ (NSData *)sc_getFileData:(NSString *)filePath;

/** 读取文件*/
+ (NSData *)sc_getFileData:(NSString *)filePath startIndex:(long long)startIndex length:(NSInteger)length;

/** 移动文件*/
+ (BOOL)sc_moveFileFromPath:(NSString *)fromPath toPath:(NSString *)toPath;

/** 拷贝文件*/
+(BOOL)sc_copyFileFromPath:(NSString *)fromPath toPath:(NSString *)toPath;

/** 获取文件夹下文件列表*/
+ (NSArray *)sc_getFileListInFolderWithPath:(NSString *)path;

/** 获取文件大小*/
+ (long long)sc_getFileSizeWithPath:(NSString *)path;

/** 获取文件创建时间*/
+ (NSString *)sc_getFileCreatDateWithPath:(NSString *)path;

/** 获取文件所有者*/
+ (NSString *)sc_getFileOwnerWithPath:(NSString *)path;

/** 获取文件更改日期*/
+ (NSString *)sc_getFileChangeDateWithPath:(NSString *)path;

@end
