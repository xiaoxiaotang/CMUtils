//
//  UIImage+bundle.m
//  CMUtils
//
//  Created by 小站 on 2020/4/8.
//

#import "UIImage+bundle.h"

@implementation UIImage (bundle)

+ (UIImage *)xz_imageNamed:(NSString *)imageName {
    NSArray *symbols = [NSThread callStackSymbols];
    
    if (symbols.count > 1) {
        
        NSArray *subSymbols = [[symbols objectAtIndex:1] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"[]"]];
        
        if (subSymbols.count > 1) {
            
            NSArray *callerSymbols = [[subSymbols objectAtIndex:1] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
            
            NSBundle *currentBundle = [NSBundle bundleForClass:NSClassFromString(callerSymbols.firstObject)];
            return [UIImage imageNamed:imageName inBundle:currentBundle compatibleWithTraitCollection:nil];
        }
    }
    return [UIImage imageNamed:imageName?:@""];
}


+ (UIImage *)xz_imageNamed:(NSString *)imageName  bundleName:(NSString *)bundleName {
    NSString *currentBundleStr = [[NSBundle mainBundle].bundlePath stringByAppendingPathComponent:bundleName];
    return [UIImage imageNamed:imageName inBundle:[NSBundle bundleWithPath:currentBundleStr]?:[NSBundle mainBundle] compatibleWithTraitCollection:nil];
}

@end
