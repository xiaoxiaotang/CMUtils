//
//  SCConstant.h
//  SaicUtilsDemo
//
//  Created by quxiaolei on 2018/11/2.
//  Copyright © 2018年 saic. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifndef SCConstant_h
#define SCConstant_h

#pragma mark - 常用Block定义
typedef void(^SCVoidBlock)(void);
typedef void(^SCInBlock)(id info);
typedef id(^SCInOutBlock)(id info);

#pragma mark - 屏幕相关

#define SC_Screen_Height CGRectGetHeight([UIScreen mainScreen].bounds)  //当前屏幕高度
#define SC_Screen_Width CGRectGetWidth([UIScreen mainScreen].bounds)    //当前屏幕宽度
#define SC_isIPhoneX (SC_Screen_Height >= 812.0 )   // 是否为iPhone X
#define SC_NavTopHeight (SC_isIPhoneX ? 88.0f : 64.0f)     //导航栏高度
#define SC_Screen_statusBar_Height CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame]) //状态栏的高度
#define SC_BottomHeight (SC_isIPhoneX ? 34.0f : 0)   //iPhone X底部手势区域

#define SC_ONEPX (1.0f / [UIScreen mainScreen].scale)  // 1像素
#define SC_Screen_Scale (MIN(SC_Screen_Height, SC_Screen_Width) / 375.0f)  // 375屏幕比例

// 设备方向
#define SC_Device_Portrait            ([[UIDevice currentDevice] orientation]==UIInterfaceOrientationPortrait ? YES : NO)
#define SC_Device_PortraitUpsideDown  ([[UIDevice currentDevice] orientation]==UIInterfaceOrientationPortraitUpsideDown ? YES : NO)
#define SC_Device_LandscapeLeft       ([[UIDevice currentDevice] orientation]==UIInterfaceOrientationLandscapeLeft ? YES : NO)
#define SC_Device_LandscapeRight      ([[UIDevice currentDevice] orientation]==UIInterfaceOrientationLandscapeRight ? YES : NO)

//弱引用
#define WEAK_SELF __weak __typeof(&*self)weakSelf = self;
#define STRONG_SELF  __strong __typeof(&*weakSelf) strongSelf = weakSelf;
#define CHECK_WEAK_SELF if (weakSelf == nil) { return; }

#pragma mark - 线程校验
#define DispatchOnMainThread(block, ...) if(block) dispatch_async(dispatch_get_main_queue(), ^{ block(__VA_ARGS__); })

#pragma mark - app信息
#define SC_APP_Version [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleShortVersionString"]
#define SC_APP_BuildNo [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleVersion"]

#pragma mark - 角度弧度转换
//由角度转换弧度
#define kDegreesToRadian(x)      (M_PI * (x) / 180.0)
//由弧度转换角度
#define kRadianToDegrees(radian) (radian * 180.0) / (M_PI)

#pragma mark - extern

#endif /* SCConstant_h */
