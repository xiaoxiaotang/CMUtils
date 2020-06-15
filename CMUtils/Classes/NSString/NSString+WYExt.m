//
//  NSString+WYExt.m
//  CMUtils
//
//  Created by 小站 on 2020/6/15.
//

#import "NSString+WYExt.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

@implementation NSString (WYExt)

#pragma mark - Hash
///=============================================================================
/// @name Hash
///=============================================================================
- (NSString *)wy_md5Mod32 {
    const char *cStr = [self UTF8String];
    unsigned char result[32];
    CC_MD5( cStr, (unsigned int)strlen(cStr), result );
    return [[NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
             result[0],result[1],result[2],result[3],
             result[4],result[5],result[6],result[7],
             result[8],result[9],result[10],result[11],
             result[12],result[13],result[14],result[15]] lowercaseString];
}

- (NSString *)wy_base64String {
    NSData *data = [NSData dataWithBytes:[self UTF8String] length:[self lengthOfBytesUsingEncoding:NSUTF8StringEncoding]];
    NSUInteger length = [data length];
    NSMutableData *mutableData = [NSMutableData dataWithLength:((length + 2) / 3) * 4];

    uint8_t *input = (uint8_t *)[data bytes];
    uint8_t *output = (uint8_t *)[mutableData mutableBytes];

    for (NSUInteger i = 0; i < length; i += 3) {
        NSUInteger value = 0;
        for (NSUInteger j = i; j < (i + 3); j++) {
            value <<= 8;
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }

        static uint8_t const kAFBase64EncodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

        NSUInteger idx = (i / 3) * 4;
        output[idx + 0] = kAFBase64EncodingTable[(value >> 18) & 0x3F];
        output[idx + 1] = kAFBase64EncodingTable[(value >> 12) & 0x3F];
        output[idx + 2] = (i + 1) < length ? kAFBase64EncodingTable[(value >> 6)  & 0x3F] : '=';
        output[idx + 3] = (i + 2) < length ? kAFBase64EncodingTable[(value >> 0)  & 0x3F] : '=';
    }

    NSString *retString = [[NSString alloc] initWithData:mutableData encoding:NSASCIIStringEncoding];
    return retString;
}

- (NSString*)wy_SHA1 {
    unsigned int outputLength = CC_SHA1_DIGEST_LENGTH;
    unsigned char output[outputLength];

    CC_SHA1(self.UTF8String, [self wy_UTF8Length], output);
    return [self wy_toHexString:output length:outputLength];;
}

- (NSString*)wy_SHA256 {
    unsigned int outputLength = CC_SHA256_DIGEST_LENGTH;
    unsigned char output[outputLength];

    CC_SHA256(self.UTF8String, [self wy_UTF8Length], output);
    return [self wy_toHexString:output length:outputLength];;
}

+ (NSString *)wy_encryptUseDES:(NSString *)clearText key:(NSString *)key {
    NSString *ciphertext = nil;
    NSData *textData = [clearText dataUsingEncoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [textData length];

    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesEncrypted = 0;

    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          [key UTF8String], kCCBlockSizeDES,
                                          NULL,
                                          [textData bytes]  , dataLength,
                                          buffer, bufferSize,
                                          &numBytesEncrypted);

    if (cryptStatus == kCCSuccess) {
        NSLog(@"DES加密成功");
        NSData *data = [NSData dataWithBytes:buffer length:(NSUInteger)numBytesEncrypted];
        ciphertext = [[NSString alloc] initWithData:data  encoding:NSUTF8StringEncoding];
    } else {
        NSLog(@"DES加密失败");
    }

    free(buffer);
    return ciphertext;
}

//textData
+ (NSString *)wy_decryptUseDESWithTextData:(NSData *)textData key:(NSString *)key {
    NSString *cleartext = nil;
    //    [self parseHexToByteArray:plainText];
    NSUInteger dataLength = [textData length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesEncrypted = 0;

    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          [key UTF8String], kCCKeySizeDES,
                                          NULL,
                                          [textData bytes]  , dataLength,
                                          buffer, bufferSize,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        NSLog(@"DES解密成功");
        NSData *data = [NSData dataWithBytes:buffer length:(NSUInteger)numBytesEncrypted];
        cleartext = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }else{
        NSLog(@"DES解密失败");
    }

    free(buffer);
    return cleartext;
}

// 16 -> 10
- (NSString *)formatFromHexString {
    if (![self wy_notEmpty]) {
        return @"";
    }
    NSScanner *scanner = [NSScanner scannerWithString:self];
    unsigned long long longlongValue;
    [scanner scanHexLongLong:&longlongValue];
    NSNumber *hexNumber = [NSNumber numberWithLongLong:longlongValue];
    return [hexNumber stringValue];
}

// 10 -> 16
- (NSString *)formatToHexString {
    if (![self wy_notEmpty]) {
        return @"";
    }
    NSNumber *longNumber = [NSNumber numberWithLongLong:llabs([self longLongValue])];
    return [NSString stringWithFormat:@"%llx", [longNumber unsignedLongLongValue]];
}

- (unsigned int)wy_UTF8Length {
    return (unsigned int) [self lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
}

- (NSString*)wy_toHexString:(unsigned char*) data length: (unsigned int) length {
    NSMutableString* hash = [NSMutableString stringWithCapacity:length * 2];
    for (unsigned int i = 0; i < length; i++) {
        [hash appendFormat:@"%02x", data[i]];
        data[i] = 0;
    }
    return hash;
}

#pragma mark - Verify
///=============================================================================
/// @name Verify
///=============================================================================

- (BOOL)wy_notEmpty {
    if (!self || [self isKindOfClass:[NSNull class]]) {
        return NO;
    }
    if ([self isKindOfClass:[NSString class]] && self.length >0) {
        return YES;
    }
    return NO;
}

+ (BOOL)wy_notEmpty:(NSString *)string {
    if (!string) return NO;
    static NSSet *emptySet;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        emptySet = [NSSet setWithObjects:@"", @"(null)", @"null", @"", @"NULL", nil];
    });
    if ([emptySet containsObject:string]) return NO;
    if ([string isKindOfClass:NSNull.class]) return NO;
    return YES;
}

#pragma mark - Regular Expression
///=============================================================================
/// @name Regular Expression
///=============================================================================

// [a-zA-z]+://[^\s]* 或 ^http://([\w-]+\.)+[\w-]+(/[\w-./?%&=]*)?$
- (BOOL)wy_isValidUrl {
    if (![self wy_notEmpty]) {
        return NO;
    }
    NSString *regex =@"[a-zA-z]+://[^\\s]*";
    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [urlTest evaluateWithObject:self];
}
// ^(13[0-9]|14[5|7]|15[0|1|2|3|5|6|7|8|9]|18[0|1|2|3|5|6|7|8|9])\d{8}$
// 乘客端:^(13[0-9]|14[5|7]|15[0|1|2|3|5|6|7|8|9]|17(6|7|8)|18[0-9])\d{8}$
// ^(13[0-9]|14[5|7]|15[0|1|2|3|5|6|7|8|9]|16(5|6|7|)|17(6|7|8)|18[0|1|2|3|5|6|7|8|9]|19[1|9])\d{8}$
- (BOOL)wy_isValidPhoneNumber {
    if (![self wy_notEmpty]) {
        return NO;
    }
    NSString *match = @"^(13[0-9]|14[5|7]|15[0|1|2|3|5|6|7|8|9]|18[0|1|2|3|5|6|7|8|9])\\d{8}$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF matches %@", match];
    return [predicate evaluateWithObject:self];
}

- (BOOL)wy_isValidTelNumber {
    if (![self wy_notEmpty]) {
        return NO;
    }
    NSString *match = @"^(\\(\\d{3,4}-)|\\d{3.4}-)?\\d{7,8}$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF matches %@", match];
    return [predicate evaluateWithObject:self];
}
// (^\d{15}$)|(^\d{18}$)|(^\d{17}(\d|X|x)$)
- (BOOL)wy_isValidIDCardNumber {
    if (![self wy_notEmpty]) {
        return NO;
    }
    NSString *match = @"(^\\d{15}$)|(^\\d{18}$)|(^\\d{17}(\\d|X|x)$)";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF matches %@", match];
    return [predicate evaluateWithObject:self];
}

//精确的身份证号码有效性检测
+ (BOOL)wy_accurateVerifyIDCardNumber:(NSString *)value {
    value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    int length =0;
    if (!value) {
        return NO;
    }else {
        length = (int)value.length;

        if (length !=15 && length !=18) {
            return NO;
        }
    }
    // 省份代码
    NSArray *areasArray =@[@"11",@"12", @"13",@"14", @"15",@"21", @"22",@"23", @"31",@"32", @"33",@"34", @"35",@"36", @"37",@"41", @"42",@"43", @"44",@"45", @"46",@"50", @"51",@"52", @"53",@"54", @"61",@"62", @"63",@"64", @"65",@"71", @"81",@"82", @"91"];

    NSString *valueStart2 = [value substringToIndex:2];
    BOOL areaFlag =NO;
    for (NSString *areaCode in areasArray) {
        if ([areaCode isEqualToString:valueStart2]) {
            areaFlag =YES;
            break;
        }
    }

    if (!areaFlag) {
        return false;
    }

    NSRegularExpression *regularExpression;
    NSUInteger numberofMatch;

    int year =0;
    switch (length) {
        case 15:
            year = [value substringWithRange:NSMakeRange(6,2)].intValue +1900;

            if (year %4 ==0 || (year %100 ==0 && year %4 ==0)) {

                regularExpression = [[NSRegularExpression alloc] initWithPattern:@"^[1-9][0-9]{5}[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|[1-2][0-9]))[0-9]{3}$"
                                                                         options:NSRegularExpressionCaseInsensitive
                                                                           error:nil];//测试出生日期的合法性
            }else {
                regularExpression = [[NSRegularExpression alloc]initWithPattern:@"^[1-9][0-9]{5}[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|1[0-9]|2[0-8]))[0-9]{3}$"
                                                                        options:NSRegularExpressionCaseInsensitive
                                                                          error:nil];//测试出生日期的合法性
            }
            numberofMatch = [regularExpression numberOfMatchesInString:value
                                                               options:NSMatchingReportProgress
                                                                 range:NSMakeRange(0, value.length)];

            if(numberofMatch >0) {
                return YES;
            }else {
                return NO;
            }
        case 18:
            year = [value substringWithRange:NSMakeRange(6,4)].intValue;
            if (year %4 ==0 || (year %100 ==0 && year %4 ==0)) {

                regularExpression = [[NSRegularExpression alloc] initWithPattern:@"^[1-9][0-9]{5}19[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|[1-2][0-9]))[0-9]{3}[0-9Xx]$"
                                                                         options:NSRegularExpressionCaseInsensitive
                                                                           error:nil];//测试出生日期的合法性
            }else {
                regularExpression = [[NSRegularExpression alloc] initWithPattern:@"^[1-9][0-9]{5}19[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|1[0-9]|2[0-8]))[0-9]{3}[0-9Xx]$"
                                                                         options:NSRegularExpressionCaseInsensitive
                                                                           error:nil];//测试出生日期的合法性
            }
            numberofMatch = [regularExpression numberOfMatchesInString:value
                                                               options:NSMatchingReportProgress
                                                                 range:NSMakeRange(0, value.length)];

            if(numberofMatch >0) {
                int S = ([value substringWithRange:NSMakeRange(0,1)].intValue + [value substringWithRange:NSMakeRange(10,1)].intValue) *7 + ([value substringWithRange:NSMakeRange(1,1)].intValue + [value substringWithRange:NSMakeRange(11,1)].intValue) *9 + ([value substringWithRange:NSMakeRange(2,1)].intValue + [value substringWithRange:NSMakeRange(12,1)].intValue) *10 + ([value substringWithRange:NSMakeRange(3,1)].intValue + [value substringWithRange:NSMakeRange(13,1)].intValue) *5 + ([value substringWithRange:NSMakeRange(4,1)].intValue + [value substringWithRange:NSMakeRange(14,1)].intValue) *8 + ([value substringWithRange:NSMakeRange(5,1)].intValue + [value substringWithRange:NSMakeRange(15,1)].intValue) *4 + ([value substringWithRange:NSMakeRange(6,1)].intValue + [value substringWithRange:NSMakeRange(16,1)].intValue) *2 + [value substringWithRange:NSMakeRange(7,1)].intValue *1 + [value substringWithRange:NSMakeRange(8,1)].intValue *6 + [value substringWithRange:NSMakeRange(9,1)].intValue *3;
                int Y = S %11;
                NSString *M =@"F";
                NSString *JYM =@"10X98765432";
                M = [JYM substringWithRange:NSMakeRange(Y,1)];// 判断校验位
                if ([M isEqualToString:[value substringWithRange:NSMakeRange(17,1)]]) {
                    return YES;// 检测ID的校验位
                }else {
                    return NO;
                }

            }else {
                return NO;
            }
        default:
            return NO;
    }
}



/** 银行卡号有效性问题Luhn算法
 *  现行 16 位银联卡现行卡号开头 6 位是 622126～622925 之间的，7 到 15 位是银行自定义的，
 *  可能是发卡分行，发卡网点，发卡序号，第 16 位是校验码。
 *  16 位卡号校验位采用 Luhm 校验方法计算：
 *  1，将未带校验位的 15 位卡号从右依次编号 1 到 15，位于奇数位号上的数字乘以 2
 *  2，将奇位乘积的个十位全部相加，再加上所有偶数位上的数字
 *  3，将加法和加上校验位能被 10 整除。
 */
- (BOOL)wy_bankCardluhmCheck {
    NSString * lastNum = [[self substringFromIndex:(self.length-1)] copy];//取出最后一位
    NSString * forwardNum = [[self substringToIndex:(self.length -1)] copy];//前15或18位

    NSMutableArray * forwardArr = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i=0; i<forwardNum.length; i++) {
        NSString * subStr = [forwardNum substringWithRange:NSMakeRange(i, 1)];
        [forwardArr addObject:subStr];
    }

    NSMutableArray * forwardDescArr = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i = (int)(forwardArr.count-1); i> -1; i--) {//前15位或者前18位倒序存进数组
        [forwardDescArr addObject:forwardArr[i]];
    }

    NSMutableArray * arrOddNum = [[NSMutableArray alloc] initWithCapacity:0];//奇数位*2的积 < 9
    NSMutableArray * arrOddNum2 = [[NSMutableArray alloc] initWithCapacity:0];//奇数位*2的积 > 9
    NSMutableArray * arrEvenNum = [[NSMutableArray alloc] initWithCapacity:0];//偶数位数组

    for (int i=0; i< forwardDescArr.count; i++) {
        NSInteger num = [forwardDescArr[i] intValue];
        if (i%2) {//偶数位
            [arrEvenNum addObject:[NSNumber numberWithInteger:num]];
        }else{//奇数位
            if (num * 2 < 9) {
                [arrOddNum addObject:[NSNumber numberWithInteger:num * 2]];
            }else{
                NSInteger decadeNum = (num * 2) / 10;
                NSInteger unitNum = (num * 2) % 10;
                [arrOddNum2 addObject:[NSNumber numberWithInteger:unitNum]];
                [arrOddNum2 addObject:[NSNumber numberWithInteger:decadeNum]];
            }
        }
    }

    __block  NSInteger sumOddNumTotal = 0;
    [arrOddNum enumerateObjectsUsingBlock:^(NSNumber * obj, NSUInteger idx, BOOL *stop) {
        sumOddNumTotal += [obj integerValue];
    }];

    __block NSInteger sumOddNum2Total = 0;
    [arrOddNum2 enumerateObjectsUsingBlock:^(NSNumber * obj, NSUInteger idx, BOOL *stop) {
        sumOddNum2Total += [obj integerValue];
    }];

    __block NSInteger sumEvenNumTotal =0 ;
    [arrEvenNum enumerateObjectsUsingBlock:^(NSNumber * obj, NSUInteger idx, BOOL *stop) {
        sumEvenNumTotal += [obj integerValue];
    }];

    NSInteger lastNumber = [lastNum integerValue];

    NSInteger luhmTotal = lastNumber + sumEvenNumTotal + sumOddNum2Total + sumOddNumTotal;

    return (luhmTotal%10 ==0)?YES:NO;
}

- (BOOL)wy_isCarNumber {
    //车牌号:湘K-DE829 香港车牌号码:粤Z-J499港
    if (![self wy_notEmpty]) {
        return NO;
    }
    NSString *carRegex = @"^[\u4e00-\u9fff]{1}[a-zA-Z]{1}[-][a-zA-Z_0-9]{4}[a-zA-Z_0-9_\u4e00-\u9fff]$";//其中\u4e00-\u9fa5表示unicode编码中汉字已编码部分，\u9fa5-\u9fff是保留部分，将来可能会添加
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF matches %@", carRegex];
    return [predicate evaluateWithObject:self];
}

- (BOOL)wy_isValidPostalcode {
    if (![self wy_notEmpty]) {
        return NO;
    }
    NSString *postalRegex = @"^[0-8]\\d{5}(?!\\d)$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF matches %@", postalRegex];
    return [predicate evaluateWithObject:self];
}

- (BOOL)wy_isValidTaxNo {
    if (![self wy_notEmpty]) {
        return NO;
    }
    NSString *taxNoRegex = @"[0-9]\\d{13}([0-9]|X)$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF matches %@", taxNoRegex];
    return [predicate evaluateWithObject:self];
}

- (BOOL)wy_isIPAddress {
    if (![self wy_notEmpty]) {
        return NO;
    }
    NSString *regex = [NSString stringWithFormat:@"^(\\d{1,3})\\.(\\d{1,3})\\.(\\d{1,3})\\.(\\d{1,3})$"];
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    BOOL rc = [pre evaluateWithObject:self];

    if (rc) {
        NSArray *componds = [self componentsSeparatedByString:@","];

        BOOL v = YES;
        for (NSString *s in componds) {
            if (s.integerValue > 255) {
                v = NO;
                break;
            }
        }

        return v;
    }

    return NO;
}
- (BOOL)wy_isMacAddress {
    if (![self wy_notEmpty]) {
        return NO;
    }
    NSString *macAddRegex = @"([A-Fa-f\\d]{2}:){5}[A-Fa-f\\d]{2}";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF matches %@", macAddRegex];
    return [predicate evaluateWithObject:self];

}
// ^\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*$
- (BOOL)wy_isValidEmail {
    if (![self wy_notEmpty]) {
        return NO;
    }
    NSString *match = @"^\\w+([-+.]\\w+)*@\\w+([-.]\\w+)*\\.\\w+([-.]\\w+)*$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF matches %@", match];
    return [predicate evaluateWithObject:self];
}
// 密码(以字母开头，长度在6~18之间，只能包含字母、数字和下划线)：^[a-zA-Z]\w{5,17}$
- (BOOL)wy_isValidPassword {
    if (![self wy_notEmpty]) {
        return NO;
    }
    NSString *match = @"^[a-zA-Z]\\w{5,17}$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF matches %@", match];
    return [predicate evaluateWithObject:self];
}
- (BOOL)wy_isValidCode {
    if (![self wy_notEmpty]) {
        return NO;
    }
    NSString *match = @"^\\d{6}$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF matches %@", match];
    return [predicate evaluateWithObject:self];
}
// [\ud83c\udc00-\ud83c\udfff]|[\ud83d\udc00-\ud83d\udfff]|[\u2600-\u27ff]
/**
- (BOOL)wy_isContainsEmoji {
    if (![self wy_notEmpty]) {
        return NO;
    }
    NSString *match = @"[\\ud83c\\udc00-\\ud83c\\udfff]|[\\ud83d\\udc00-\\ud83d\\udfff]|[\\u2600-\\u27ff]";
    NSRange range = [self rangeOfString:match options:NSRegularExpressionSearch];
    return range.location != NSNotFound;
}
 **/

- (BOOL)wy_isContainsEmoji {
    if (![self wy_notEmpty]) {
        return NO;
    }
    __block BOOL returnValue = NO;

    [self enumerateSubstringsInRange:NSMakeRange(0, [self length])
                             options:NSStringEnumerationByComposedCharacterSequences
                          usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                              const unichar hs = [substring characterAtIndex:0];
                              if (0xd800 <= hs && hs <= 0xdbff) {
                                  if (substring.length > 1) {
                                      const unichar ls = [substring characterAtIndex:1];
                                      const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                                      if (0x1d000 <= uc && uc <= 0x1f77f) {
                                          returnValue = YES;
                                      }
                                  }
                              } else if (substring.length > 1) {
                                  const unichar ls = [substring characterAtIndex:1];
                                  if (ls == 0x20e3 || ls ==0xfe0f) {
                                      returnValue = YES;
                                  }
                              } else {
                                  if (0x2100 <= hs && hs <= 0x27ff && hs != 0x263b) {
                                      returnValue = YES;
                                  } else if (0x2B05 <= hs && hs <= 0x2b07) {
                                      returnValue = YES;
                                  } else if (0x2934 <= hs && hs <= 0x2935) {
                                      returnValue = YES;
                                  } else if (0x3297 <= hs && hs <= 0x3299) {
                                      returnValue = YES;
                                  } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50 || hs == 0x231a) {
                                      returnValue = YES;
                                  }
                              }
                          }];

    return returnValue;
}

- (BOOL)wy_isPureChinese {
    if (![self wy_notEmpty]) {
        return NO;
    }
    NSString *chineseRegex = @"^[\u4e00-\u9fa5]+$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF matches %@", chineseRegex];
    return [predicate evaluateWithObject:self];
}

- (BOOL)wy_isValidWithMinLenth:(NSInteger)minLenth
                      maxLenth:(NSInteger)maxLenth
                containChinese:(BOOL)containChinese
                 containDigtal:(BOOL)containDigtal
                 containLetter:(BOOL)containLetter
         containOtherCharacter:(NSString *)containOtherCharacter
           firstCannotBeDigtal:(BOOL)firstCannotBeDigtal {
    if (![self wy_notEmpty]) {
        return NO;
    }
    NSString *hanzi = containChinese ? @"\u4e00-\u9fa5" : @"";
    NSString *first = firstCannotBeDigtal ? @"^[a-zA-Z_]" : @"";
    NSString *lengthRegex = [NSString stringWithFormat:@"(?=^.{%@,%@}$)", @(minLenth), @(maxLenth)];
    NSString *digtalRegex = containDigtal ? @"(?=(.*\\d.*){1})" : @"";
    NSString *letterRegex = containLetter ? @"(?=(.*[a-zA-Z].*){1})" : @"";
    NSString *characterRegex = [NSString stringWithFormat:@"(?:%@[%@A-Za-z0-9%@]+)", first, hanzi, containOtherCharacter ? containOtherCharacter : @""];
    NSString *regex = [NSString stringWithFormat:@"%@%@%@%@", lengthRegex, digtalRegex, letterRegex, characterRegex];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF matches %@", regex];
    return [predicate evaluateWithObject:self];
}

#pragma mark - NSNumber Compatible
///=============================================================================
/// @name NSNumber Compatible
///=============================================================================
//判断字符串是否是整型
- (BOOL)wy_isPureInt {
    NSScanner *scan = [NSScanner scannerWithString:self];
    int val;
    return[scan scanInt:&val] && [scan isAtEnd];
}
//判断是否为浮点形
- (BOOL)wy_isPureFloat {
    NSScanner *scan = [NSScanner scannerWithString:self];
    float val;
    return[scan scanFloat:&val] && [scan isAtEnd];
}
//判断是否为双精度类型
- (BOOL)wy_isPureDouble {
    NSScanner *scan = [NSScanner scannerWithString:self];
    double val;
    return[scan scanDouble:&val] && [scan isAtEnd];
}

//判断是否为纯数字
- (BOOL)wy_isPureNumCharacters {
    NSString *string = [self stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]];
    if(string.length > 0){
        return NO;
    }
    return YES;
}
#pragma mark - NSDate Compatible
///=============================================================================
/// @name NSDate Compatible
///=============================================================================

+ (NSDictionary *)wy_formatURLParamsWithURLString:(NSString *)urlString {
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionaryWithCapacity:0];
    if ([urlString wy_isValidUrl]) {
        // 处理特殊字符
        urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        NSURLComponents *URLComponents = [NSURLComponents componentsWithString:urlString];
        NSArray *URLqueryItems = URLComponents.queryItems;
        if (URLComponents && URLqueryItems.count >0) {
            for (NSURLQueryItem *item in URLqueryItems) {
                // 编码格式转换
                NSString *valueName = [item.value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                NSString *itemName = [item.name stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                [mutableDict setObject:valueName forKey:itemName];
            }
        }
    }
    return [mutableDict copy];
}
+ (NSString *)wy_formatURL:(NSString *)sourceURL withParams:(NSDictionary *)paramsDict {
    //guard
    if(![sourceURL wy_isValidUrl] || nil == paramsDict){
        return sourceURL;
    }

    //格式化地址中重复的//
    NSURL *URL = [NSURL URLWithString:sourceURL];
    NSString *relativePath = [URL.relativePath stringByReplacingOccurrencesOfString:@"//" withString:@"/"];
    sourceURL = [sourceURL stringByReplacingOccurrencesOfString:URL.relativePath withString:relativePath];
    //1,获取URL中的所有参数
    NSDictionary *originParamsDict = [NSString wy_formatURLParamsWithURLString:sourceURL];
    NSMutableDictionary *mutableParamsDict = [NSMutableDictionary dictionaryWithDictionary:originParamsDict];

    //2,追加传入的参数
    [mutableParamsDict addEntriesFromDictionary:paramsDict];

    NSString *URLString = [[sourceURL componentsSeparatedByString:@"?"] firstObject];
    NSURLComponents *urlComponts = [NSURLComponents componentsWithString:URLString];

    __block NSMutableArray *URLqueryItems = [NSMutableArray arrayWithCapacity:0];
    //遍历参数字典追加或者更新或者更新参数
    [mutableParamsDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSURLQueryItem *itemSid = [NSURLQueryItem queryItemWithName:key value:obj];
        [URLqueryItems addObject:itemSid];
    }];
    [urlComponts setQueryItems:URLqueryItems];
    return urlComponts.URL.absoluteString;
}
#pragma mark - path
///=============================================================================
/// @name path
///=============================================================================
+ (NSString *)wy_pathForDocuments{
    
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

+ (NSString *)wy_pathForCaches{
    
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
}

+ (NSString *)wy_pathForMainBundle{
    
    return [NSBundle mainBundle].bundlePath;
}

+ (NSString *)wy_pathForTemp{
    
    return NSTemporaryDirectory();
}

+ (NSString *)wy_pathForPreferences{
    
    return [NSSearchPathForDirectoriesInDomains(NSPreferencePanesDirectory, NSUserDomainMask, YES) lastObject];
}

+ (NSString *)wy_pathForSystemFile:(NSSearchPathDirectory)directory{
    
    return [NSSearchPathForDirectoriesInDomains(directory, NSUserDomainMask, YES) lastObject];
}

#pragma mark - Font
///=============================================================================
/// @name Font
///=============================================================================
- (CGSize)wy_sizeWithFont:(UIFont *)font andMaxSize:(CGSize)maxSize{
    
    NSDictionary *arrts = @{NSFontAttributeName:font};
    return [self boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:arrts context:nil].size;
}

- (CGFloat)wy_heightWithFont:(UIFont *)font constrainedToWidth:(CGFloat)width {
    UIFont *textFont = font ? font : [UIFont systemFontOfSize:[UIFont systemFontSize]];

    CGSize textSize;

#if __IPHONE_OS_VERSION_MIN_REQUIRED < 70000
    if ([self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
        paragraph.lineBreakMode = NSLineBreakByWordWrapping;
        NSDictionary *attributes = @{NSFontAttributeName: textFont,
                                     NSParagraphStyleAttributeName: paragraph};
        textSize = [self boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                      options:(NSStringDrawingUsesLineFragmentOrigin |
                                               NSStringDrawingTruncatesLastVisibleLine)
                                   attributes:attributes
                                      context:nil].size;
    } else {
        textSize = [self sizeWithFont:textFont
                    constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)
                        lineBreakMode:NSLineBreakByWordWrapping];
    }
#else
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{NSFontAttributeName: textFont,
                                 NSParagraphStyleAttributeName: paragraph};
    textSize = [self boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                  options:(NSStringDrawingUsesLineFragmentOrigin |
                                           NSStringDrawingTruncatesLastVisibleLine)
                               attributes:attributes
                                  context:nil].size;
#endif

    return ceil(textSize.height);
}

- (CGFloat)wy_widthWithFont:(UIFont *)font constrainedToHeight:(CGFloat)height {
    UIFont *textFont = font ? font : [UIFont systemFontOfSize:[UIFont systemFontSize]];

    CGSize textSize;

#if __IPHONE_OS_VERSION_MIN_REQUIRED < 70000
    if ([self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
        paragraph.lineBreakMode = NSLineBreakByWordWrapping;
        NSDictionary *attributes = @{NSFontAttributeName: textFont,
                                     NSParagraphStyleAttributeName: paragraph};
        textSize = [self boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, height)
                                      options:(NSStringDrawingUsesLineFragmentOrigin |
                                               NSStringDrawingTruncatesLastVisibleLine)
                                   attributes:attributes
                                      context:nil].size;
    } else {
        textSize = [self sizeWithFont:textFont
                    constrainedToSize:CGSizeMake(CGFLOAT_MAX, height)
                        lineBreakMode:NSLineBreakByWordWrapping];
    }
#else
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{NSFontAttributeName: textFont,
                                 NSParagraphStyleAttributeName: paragraph};
    textSize = [self boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, height)
                                  options:(NSStringDrawingUsesLineFragmentOrigin |
                                           NSStringDrawingTruncatesLastVisibleLine)
                               attributes:attributes
                                  context:nil].size;
#endif

    return ceil(textSize.width);
}

#pragma mark - Other
///=============================================================================
/// @name Other
///=============================================================================
+ (NSString *)wy_imTime:(NSString *)timestamp{
    
    if (!timestamp || timestamp.length == 0) return @" ";
    @try {
        NSTimeInterval interval = [timestamp doubleValue] / 1000.0;
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:MM"];
        NSString * dateStr = [formatter stringFromDate:date];
        NSString *resStr = [dateStr stringByReplacingOccurrencesOfString:@"-" withString:@""];
        NSDate *jt = [NSDate date];
        NSString *jtStr= [formatter stringFromDate:jt];
        jtStr = [jtStr stringByReplacingOccurrencesOfString:@"-" withString:@""];;
        
        NSRange y = {.location=4,.length=2};
        NSRange r = {.location=6,.length=2};
        NSRange hm = {.location=9,.length=5};
        NSString *nianJt = [jtStr substringToIndex:4];
        NSString *yueJt = [jtStr substringWithRange: y];
        NSString *riJt = [jtStr substringWithRange: r];
        
        NSString *nianT = [resStr substringToIndex:4];
        NSString *yueT = [resStr substringWithRange: y];
        NSString *riT = [resStr substringWithRange: r];
        NSString *hhMMT = [resStr substringWithRange: hm];
        
        int jT = [[NSString stringWithFormat:@"%@%@%@",nianJt,yueJt,riJt] intValue];
        int T = [[NSString stringWithFormat:@"%@%@%@",nianT,yueT,riT] intValue];
        if (jT - T == 0) {
            return [NSString stringWithFormat:@"今天 %@",hhMMT];
        }else if (jT - T == 1) {
            return [NSString stringWithFormat:@"昨天 %@",hhMMT];
        }else if ([nianJt intValue] == [nianT intValue]) {
            return [NSString stringWithFormat:@"%@月%@日 %@",yueT,riT,hhMMT];
        }
        return [NSString stringWithFormat:@"%@年%@月%@日 %@",nianT,yueT,riT,hhMMT];
    } @catch (NSException *exception) {
        return timestamp;
    }
}

+ (NSString *)wy_processingTime:(NSString *)time{
    
    if (!time || time.length < 16) return @"时间格式错误";
    @try {
        NSString *resStr = [time stringByReplacingOccurrencesOfString:@"-" withString:@""];;
        NSDateFormatter *sdf2=[[NSDateFormatter alloc] init];
        //YYYY表示当天所在的周属于的年份，一周从周日开始，周六结束，只要本周跨年，那么这周就算入下一年。
        sdf2.dateFormat=@"yyyy-MM-dd HH:mm";
        NSDate *jt = [NSDate date];
        NSString *jtStr= [sdf2 stringFromDate:jt];
        jtStr = [jtStr stringByReplacingOccurrencesOfString:@"-" withString:@""];;
        
        NSRange y = {.location=4,.length=2};
        NSRange r = {.location=6,.length=2};
        NSRange hm = {.location=9,.length=5};
        NSString *nianJt = [jtStr substringToIndex:4];
        NSString *yueJt = [jtStr substringWithRange: y];
        NSString *riJt = [jtStr substringWithRange: r];
        
        NSString *nianT = [resStr substringToIndex:4];
        NSString *yueT = [resStr substringWithRange: y];
        NSString *riT = [resStr substringWithRange: r];
        NSString *hhmmT = [resStr substringWithRange: hm];
        if (nianJt != nianT) {
            NSString *str = [NSString stringWithFormat:@"%@年%@月%@日 %@",nianT,yueT,riT,hhmmT];
            return str;
        }
        int res = [[NSString stringWithFormat:@"%@%@",yueJt,riJt] intValue] -
        [[NSString stringWithFormat:@"%@%@",yueT,riT] intValue];
        if (res == 0) {
            return [NSString stringWithFormat:@"今天 %@",hhmmT];
        }else if (res == 1){
            return [NSString stringWithFormat:@"昨天 %@",hhmmT];
        }
        return [NSString stringWithFormat:@"%@月%@日 %@",yueT,riT,hhmmT];
    }@catch (NSException *exception){
        return @"时间格式错误";
    }
}

- (NSString *)wy_reverseString {
    NSMutableString *reverseString = [[NSMutableString alloc] init];
    NSInteger charIndex = [self length];
    while (charIndex > 0) {
        charIndex --;
        NSRange subStrRange = NSMakeRange(charIndex, 1);
        [reverseString appendString:[self substringWithRange:subStrRange]];
    }
    return reverseString;
}
@end
