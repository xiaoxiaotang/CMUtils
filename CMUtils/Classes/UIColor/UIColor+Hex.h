//
//  UIColor+Hex.h
//  CMUtils
//
//  Created by 小站 on 2020/6/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (Hex)
/**
 根据十六进制字符串生成UIColor，支持带#号或者不带#号，自动去除空格
 
 @param hexColor NSString RGB or RRGGBB
 @return UIColor
 */
+(UIColor *)colorWithHexColor:(NSString *)hexColor;

/**
 根据十六进制字符串生成UIColor，支持带#号或者不带#号，自动去除空格
 
 @param hexColor NSString RGB or RRGGBB
 @param alpha 0.0~1.0
 @return UIColor
 */
+(UIColor *)colorWithHexColor:(NSString *)hexColor alpha:(CGFloat)alpha;

+(UIColor *)randomColor;
@end

NS_ASSUME_NONNULL_END
