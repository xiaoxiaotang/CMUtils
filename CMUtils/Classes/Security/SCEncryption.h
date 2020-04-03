//
//  SCEncryption.h
//  SaicCarPlatform
//
//  Created by ZT_L on 2018/9/5.
//  Copyright © 2018年 Saic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SCEncryption : NSObject

/**
 md5 加密

 @param plainText 需要加密的字符串
 @return 加密后的字符串
 */
+ (NSString *)sc_md5String:(NSString *)plainText;

/**
 字典升序加密

 @param dict 需要加密的字典
 @return 加密后的字符串
 */
+ (NSString *)sc_signatureVerificationDict:(NSDictionary *)dict;

/**
 文本加密

 @param plainText 需要加密的文本
 @return 加密后的字符串
 */
+ (NSString *)sc_signatureVerificationText:(NSString *)plainText;

@end
