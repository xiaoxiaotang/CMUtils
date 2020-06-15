//
//  UIFont+Tools.h
//  CMUtils
//
//  Created by 小站 on 2020/6/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIFont (Tools)

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
