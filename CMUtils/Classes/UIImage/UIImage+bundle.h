//
//  UIImage+bundle.h
//  CMUtils
//
//  Created by 小站 on 2020/4/8.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (bundle)

+ (UIImage *)xz_imageNamed:(NSString *)imageName bundleName:(NSString *)bundleName;

@end

NS_ASSUME_NONNULL_END
