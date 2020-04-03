//
//  SCPrivacyUtil.h
//  SaicUtils
//
//  Created by quxiaolei on 2020/1/14.
//  Copyright © 2020 saic. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SCPrivacyUtil : NSObject

/// 打开APP隐私权限设置界面
+ (void)openAppPrivacySetting;
/// 检查相机权限
/// @param block 授权结果回调
/// @note 未请求授权时会主动请求
+ (void)checkingCameraPrivacyWithStatus:(void (^)(BOOL isAvailable))block;
/// 检查相册权限
/// @param block 授权结果回调
/// @note 未请求授权时会主动请求
+ (void)checkingPhotoLibraryPrivacyStatus:(void (^)(BOOL isAvailable))block;
/// 检查是否有定位权限
/// @note 同步方法返回结果,yes表示有权限
+ (BOOL)checkingLocationPrivacyStatus;
/// 检查是否有通知权限
/// @param block 授权结果回调
/// @note 未请求授权时会主动请求
+ (void)checkingNotificationPrivacyStatus:(void (^)(BOOL isAvailable))block;
/// 检查录音权限
/// @param block 授权结果回调
/// @note 未请求授权时会主动请求
+ (void)checkingRecordPrivacyStatus:(void (^)(BOOL isAvailable))block;
@end

NS_ASSUME_NONNULL_END
