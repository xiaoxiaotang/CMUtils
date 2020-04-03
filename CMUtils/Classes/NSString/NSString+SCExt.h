//
//  NSString+SCExt.h
//  SaicUtilsDemo
//
//  Created by zhenglaixian on 2018/9/6.
//  Copyright © 2018年 saic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Provide hash, encrypt, encode and some common method for 'NSString'.
 */
@interface NSString (SCExt)

#pragma mark - Hash
///=============================================================================
/// @name Hash
///=============================================================================
/**
    md5加密
*/
- (NSString *)sc_md5Mod32;
/// base64
- (NSString *)sc_base64String;
/// SHA1
- (NSString*)sc_SHA1;
/// SHA256
- (NSString*)sc_SHA256;

/****** 加密 ******/
+ (NSString *)sc_encryptUseDES:(NSString *)clearText key:(NSString *)key;
/****** 解密 ******/
+ (NSString *)sc_decryptUseDESWithTextData:(NSData *)textData key:(NSString *)key;

/// 十六进制转换为十进制字符串
- (NSString *)formatFromHexString;
/// 十进制转换为十六进制字符串
- (NSString *)formatToHexString;

#pragma mark - Verify
///=============================================================================
/// @name Verify
///=============================================================================

- (BOOL)sc_notEmpty;
+ (BOOL)sc_notEmpty:(NSString *)string;
#pragma mark - Regular Expression
///=============================================================================
/// @name Regular Expression
///=============================================================================

/// url
- (BOOL)sc_isValidUrl;
/// 手机号码
- (BOOL)sc_isValidPhoneNumber;
/// 固话号码
- (BOOL)sc_isValidTelNumber;
/// 身份证号码
- (BOOL)sc_isValidIDCardNumber;
/**
 身份证号码的精确检验

 @param value 身份证号
 @return 正则验证成功返回YES, 否则返回NO
 */
+ (BOOL)sc_accurateVerifyIDCardNumber:(NSString *)value;
/// 银行卡的有效性
- (BOOL)sc_bankCardluhmCheck;
/// 车牌号
- (BOOL)sc_isCarNumber;
/// 邮政编码
- (BOOL)sc_isValidPostalcode;
/// 工商税号
- (BOOL)sc_isValidTaxNo;

/// ip地址
- (BOOL)sc_isIPAddress;
/// mac地址
- (BOOL)sc_isMacAddress;

/// Email
- (BOOL)sc_isValidEmail;
/// 密码(以字母开头，长度在6~18之间，只能包含字母、数字和下划线)
- (BOOL)sc_isValidPassword;
/// 验证码(6位纯数字)
- (BOOL)sc_isValidCode;
/// 是否包含emoji表情
- (BOOL)sc_isContainsEmoji;
/// 纯汉字
- (BOOL)sc_isPureChinese;

/**
 是否符合最小长度、最长长度，是否包含中文,数字，字母，其他字符，首字母是否可以为数字

 @param minLenth 最小长度
 @param maxLenth 最长长度
 @param containChinese 是否包含中文
 @param containDigtal 包含数字
 @param containLetter 包含字母
 @param containOtherCharacter 其他字符
 @param firstCannotBeDigtal 首字母是否可为数字
 @return 正则验证成功返回YES, 否则返回NO
 */
- (BOOL)sc_isValidWithMinLenth:(NSInteger)minLenth
                      maxLenth:(NSInteger)maxLenth
                containChinese:(BOOL)containChinese
                 containDigtal:(BOOL)containDigtal
                 containLetter:(BOOL)containLetter
         containOtherCharacter:(NSString *)containOtherCharacter
           firstCannotBeDigtal:(BOOL)firstCannotBeDigtal;
#pragma mark - NSNumber Compatible
///=============================================================================
/// @name NSNumber Compatible
///=============================================================================

//判断字符串是否是整型
- (BOOL)sc_isPureInt;
//判断是否为浮点型
- (BOOL)sc_isPureFloat;
//判断是否为双精度类型
- (BOOL)sc_isPureDouble;
//判断是否为纯数字
- (BOOL)sc_isPureNumCharacters;

#pragma mark - NSDate Compatible
///=============================================================================
/// @name NSDate Compatible
///=============================================================================

/**
 格式化url的参数

 @param urlString url地址
 @return url地址中的参数
 */
+ (NSDictionary *)sc_formatURLParamsWithURLString:(NSString *)urlString;

#pragma mark - Path
///=============================================================================
/// @name Path
///=============================================================================

/**
*  快速返回沙盒中，Documents文件的路径
*
*  @return Documents文件的路径
*/
+ (NSString *)sc_pathForDocuments;

/**
*  快速返回沙盒中，Library下Caches文件的路径
*
*  @return 快速返回沙盒中Library下Caches文件的路径
*/
+ (NSString *)sc_pathForCaches;

/**
*  快速返回沙盒中，MainBundle(资源捆绑包的)的路径
*
*  @return 快速返回MainBundle(资源捆绑包的)的路径
*/
+ (NSString *)sc_pathForMainBundle;

/**
 *  快速返回沙盒中，tmp(临时文件)文件的路径
 *
 *  @return 快速返回沙盒中tmp文件的路径
 */
+ (NSString *)sc_pathForTemp;

/**
 *  快速返回沙盒中，Library下Preferences文件的路径
 *
 *  @return 快速返回沙盒中Library下Caches文件的路径
 */
+ (NSString *)sc_pathForPreferences;

/**
 *  快速返回沙盒中，你指定的系统文件的路径。tmp文件除外，tmp用系统的NSTemporaryDirectory()函数更加便捷
 *
 *  @param directory NSSearchPathDirectory枚举
 *
 *  @return 快速你指定的系统文件的路径
 */
+ (NSString *)sc_pathForSystemFile:(NSSearchPathDirectory)directory;

#pragma mark - Font
///=============================================================================
/// @name Font
///=============================================================================

/**
 *  快速计算出文本的真实尺寸
 *
 *  @param font    文字的字体
 *  @param maxSize 文本的最大尺寸
 *
 *  @return 快速计算出文本的真实尺寸
 */
- (CGSize)sc_sizeWithFont:(UIFont *)font andMaxSize:(CGSize)maxSize;

/**
 计算文字的高度

 @param font 字体(默认为系统字体)
 @param width 约束宽度
 @return 文字的高度
 */
- (CGFloat)sc_heightWithFont:(UIFont *)font constrainedToWidth:(CGFloat)width;
/**
 计算文字的宽度

 @param font 字体(默认为系统字体)
 @param height 约束高度
 @return 文字的宽度
 */
- (CGFloat)sc_widthWithFont:(UIFont *)font constrainedToHeight:(CGFloat)height;

#pragma mark - Other
///=============================================================================
/// @name Other
///=============================================================================
/**
 * @brief IM 历史聊天显示时间格式处理
 * @param timestamp 时间戳
 */
+(NSString *)sc_imTime:(NSString *)timestamp;

/**
 * @brief 历史显示时间格式处理
 * @param time 入参数时间暂时必须未：yyyy-MM-dd HH:mm
 */
+(NSString *)sc_processingTime:(NSString *)time;


/**
 反转字符串

 @return 反转后字符串
 */
- (NSString *)sc_reverseString;
@end


NS_ASSUME_NONNULL_END
