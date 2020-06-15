//
//  UIFont+XZTool.m
//  XZCourseModule_Example
//
//  Created by Allen on 2019/11/15.
//  Copyright © 2019 liguoxiang. All rights reserved.
//

#import "UIFont+XZTool.h"

@implementation UIFont (XZTool)

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
