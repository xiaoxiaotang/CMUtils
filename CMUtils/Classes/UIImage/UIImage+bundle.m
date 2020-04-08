//
//  UIImage+bundle.m
//  CMUtils
//
//  Created by 小站 on 2020/4/8.
//

#import "UIImage+bundle.h"

@implementation UIImage (bundle)

+ (UIImage *)xz_imageNamed:(NSString *)imageName  bundleName:(NSString *)bundleName {
    NSString *currentBundleStr = [[NSBundle mainBundle].bundlePath stringByAppendingPathComponent:bundleName];
    return [UIImage imageNamed:imageName inBundle:[NSBundle bundleWithPath:currentBundleStr]?:[NSBundle mainBundle] compatibleWithTraitCollection:nil];
}

@end
