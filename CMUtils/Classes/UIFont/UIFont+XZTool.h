//
//  UIFont+XZTool.h
//  XZCourseModule_Example
//
//  Created by Allen on 2019/11/15.
//  Copyright © 2019 liguoxiang. All rights reserved.
//
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIFont (XZTool)

/// 平方字体-Regular大小的对象
/// @param size 字体大小
+ (UIFont *)regularFontSize:(CGFloat)size;

/// 平方字体-Semibold大小的对象
/// @param size 字体大小
+ (UIFont *)semiboldFontSize:(CGFloat)size;

/// 平方字体-Medium大小的对象
/// @param size 字体大小
+ (UIFont *)mediumFontSize:(CGFloat)size;

@end

NS_ASSUME_NONNULL_END
