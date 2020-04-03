//
//  NSString+FilterString.h
//  SaicCarPlatform
//
//  Created by zhanglei on 2018/12/4.
//  Copyright © 2018年 Saic. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (FilterString)

- (NSString *)filterSpecialString;
- (BOOL)hasSpecialString;
- (BOOL)hasIllegalCharacter;
- (BOOL)hasEmoji;
- (NSString *)noSpecialString;
- (NSString *)noEmojiString;

@end

NS_ASSUME_NONNULL_END
