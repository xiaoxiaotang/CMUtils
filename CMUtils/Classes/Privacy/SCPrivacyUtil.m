//
//  SCPrivacyUtil.m
//  SaicUtils
//
//  Created by quxiaolei on 2020/1/14.
//  Copyright © 2020 saic. All rights reserved.
//

#import "SCPrivacyUtil.h"
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import <CoreLocation/CoreLocation.h>
#import <NotificationCenter/NotificationCenter.h>
#import <UserNotifications/UserNotifications.h>

@implementation SCPrivacyUtil

+ (void)openAppPrivacySetting {
    UIApplication *application = [UIApplication sharedApplication];
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if ([application canOpenURL:url]) {
        if (@available(iOS 10.0, *)) {
            [application openURL:url options:@{} completionHandler:nil];
        } else {
            [application openURL:url];
        }
   }
}

// 相机权限
+ (void)checkingCameraPrivacyWithStatus:(void (^)(BOOL isAvailable))block {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusNotDetermined) {
        // 未授权,请求授权
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (block) {
                    block(granted);
                }
            });
        }];
    } else {
        if (block) {
            block(authStatus == AVAuthorizationStatusAuthorized);
        }
    }
}

// 相册权限
+ (void)checkingPhotoLibraryPrivacyStatus:(void (^)(BOOL isAvailable))block {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusNotDetermined) {
        // 未授权,请求授权
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (block) {
                    block(status == PHAuthorizationStatusAuthorized);
                }
            });
        }];
    } else {
        if (block) {
            block(status == PHAuthorizationStatusAuthorized);
        }
    }
}

// 定位权限
+ (BOOL)checkingLocationPrivacyStatus {
    if ([CLLocationManager locationServicesEnabled]) {
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        if (status == kCLAuthorizationStatusAuthorizedWhenInUse ||
            status == kCLAuthorizationStatusAuthorizedAlways) {
            return YES;
        }
    }

    /*
    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    [locationManager requestAlwaysAuthorization];
    [locationManager requestWhenInUseAuthorization];*/
    return NO;
}

// 通知权限
+ (void)checkingNotificationPrivacyStatus:(void (^)(BOOL isAvailable))block {
    if (@available(iOS 10.0, *)) {
        [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            if (UNAuthorizationStatusNotDetermined == settings.authorizationStatus) {
                // 未授权,请求授权
                [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (block) {
                            block(granted);
                        }
                    });
                }];
            } else {
                if (block) {
                    block(UNAuthorizationStatusAuthorized == settings.authorizationStatus);
                }
            }
        }];
    } else {
        UIUserNotificationSettings *setting = [[UIApplication sharedApplication] currentUserNotificationSettings];
        if (block) {
            block(UIUserNotificationTypeNone != setting.types);
        }
    }
}

// 录音权限
+ (void)checkingRecordPrivacyStatus:(void (^)(BOOL isAvailable))block {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (authStatus == AVAuthorizationStatusNotDetermined) {
        // 未授权,请求授权
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (block) {
                    block(granted);
                }
            });
        }];
    } else {
        if (block) {
            block(authStatus == AVAuthorizationStatusAuthorized);
        }
    }
}
@end
