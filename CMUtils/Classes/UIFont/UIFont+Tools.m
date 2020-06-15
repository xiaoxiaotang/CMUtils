//
//  UIFont+Tools.m
//  CMUtils
//
//  Created by 小站 on 2020/6/15.
//

#import "UIFont+Tools.h"

@implementation UIFont (Tools)

+ (UIFont *)regularFontSize:(CGFloat)size {
    
    return [UIFont fontWithName:@"PingFangSC-Regular" size:size];
}

+ (UIFont *)semiboldFontSize:(CGFloat)size {
    
    return [UIFont fontWithName:@"PingFangSC-Semibold" size:size];
}

+ (UIFont *)mediumFontSize:(CGFloat)size {
    
    return [UIFont fontWithName:@"PingFangSC-Medium" size:size];
}
@end
