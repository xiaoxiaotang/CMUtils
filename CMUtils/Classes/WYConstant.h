//
//  WYConstant.h
//  CMUtils
//
//  Created by 小站 on 2020/4/8.
//

#ifndef WYConstant_h
#define WYConstant_h

#pragma mark - 常用Block定义
typedef void(^WYVoidBlock)(void);
typedef void(^WYInBlock)(id info);
typedef id(^WYInOutBlock)(id info);

#pragma mark - 屏幕相关

#define WY_Screen_Height CGRectGetHeight([UIScreen mainScreen].bounds)  //当前屏幕高度
#define WY_Screen_Width CGRectGetWidth([UIScreen mainScreen].bounds)    //当前屏幕宽度
#define WY_isIPhoneX (WY_Screen_Height >= 812.0 )   // 是否为iPhone X
#define WY_NavTopHeight (WY_isIPhoneX ? 88.0f : 64.0f)     //导航栏高度
#define WY_Screen_statusBar_Height CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame]) //状态栏的高度
#define WY_BottomHeight (WY_isIPhoneX ? 34.0f : 0)   //iPhone X底部手势区域

#define WY_ONEPX (1.0f / [UIScreen mainScreen].scale)  // 1像素
#define WY_Screen_Scale (MIN(WY_Screen_Height, WY_Screen_Width) / 375.0f)  // 375屏幕比例

// 设备方向
#define WY_Device_Portrait            ([[UIDevice currentDevice] orientation]==UIInterfaceOrientationPortrait ? YES : NO)
#define WY_Device_PortraitUpsideDown  ([[UIDevice currentDevice] orientation]==UIInterfaceOrientationPortraitUpsideDown ? YES : NO)
#define WY_Device_LandscapeLeft       ([[UIDevice currentDevice] orientation]==UIInterfaceOrientationLandscapeLeft ? YES : NO)
#define WY_Device_LandscapeRight      ([[UIDevice currentDevice] orientation]==UIInterfaceOrientationLandscapeRight ? YES : NO)

//弱引用
#define WEAK_SELF __weak __typeof(&*self)weakSelf = self;
#define STRONG_SELF  __strong __typeof(&*weakSelf) strongSelf = weakSelf;
#define CHECK_WEAK_SELF if (weakSelf == nil) { return; }

#pragma mark - 线程校验
#define DispatchOnMainThread(block, ...) if(block) dispatch_async(dispatch_get_main_queue(), ^{ block(__VA_ARGS__); })

#pragma mark - app信息
#define WY_APP_Version [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleShortVersionString"]
#define WY_APP_BuildNo [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleVersion"]

#pragma mark - 角度弧度转换
//由角度转换弧度
#define kDegreesToRadian(x)      (M_PI * (x) / 180.0)
//由弧度转换角度
#define kRadianToDegrees(radian) (radian * 180.0) / (M_PI)

#endif /* WYConstant_h */
