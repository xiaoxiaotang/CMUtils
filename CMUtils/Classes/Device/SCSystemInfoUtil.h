//
//  SCSystemInfoUtil.h
//  SaicCarPlatform
//
//  Created by Mr.Zhang on 2018/8/6.
//  Copyright © 2018年 Saic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SCSystemInfoUtil : NSObject

/** 获取系统版本 */
+(NSString*)sc_getOSVersion;

/** 获取app版本号 */
+(NSString*)sc_getAppVersion;

/** 获取app包名 */
+ (NSString *)sc_getAppPackageName;

/** 获取app名称 */
+ (NSString *)sc_getAppName;

/** 获取构建版本号 */
+(NSString *)sc_getBuildVersion;

/** 获取设备名称 */
+(NSString *)sc_getDeviceName;

/** 获取手机型号 */
+(NSString *)sc_getDeviceModelName;

/** 获取设备标识IDFV */
+(NSString *)sc_getDeviceIDFV;

/** 获取随机标识GUID */
+(NSString *)sc_getRandomGUID;

/** 获取本地时区 */
+(NSString *)sc_getLocalTimeZone;

/** 获取运营商名称 */
+(NSString *)sc_getNetworkName;

/** 获取运营商国家代码 */
+(NSString *)sc_getNetworkCountryCode;

/** 获取deviceID */
+(NSString *)sc_deviceID;

/** 获取客户端IP地址 */
+ (NSString *)sc_getIPAddress;

@end
