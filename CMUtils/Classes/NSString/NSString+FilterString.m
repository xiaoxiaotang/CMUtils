//
//  NSString+FilterString.m
//  SaicCarPlatform
//
//  Created by zhanglei on 2018/12/4.
//  Copyright © 2018年 Saic. All rights reserved.
//

#import "NSString+FilterString.h"
//static NSString *regex = @"[~`!！？【】「」《》￥（）、：‘“；。，…—@#$%^&*()_+-=[]|{};':\",./<>?]{,}/～€^¢£♂♀——〖〗『』「」﹁﹂｀〔〕";//存储需要过滤的特殊字符
@implementation NSString (FilterString)
- (NSString *)noEmoji {
    return [self stringContainsEmoji:self];
}

- (NSString *)filterSpecialString{
    NSString *replacingString = self;
//    for (int i = 0; i < regex.length; i++) {
//        NSString *subStr = [regex substringWithRange:NSMakeRange(i, 1)];
//        NSString *rString = [replacingString stringByReplacingOccurrencesOfString:subStr withString:@""];
//        replacingString = [NSString stringWithFormat:@"%@",rString];
//    }
    replacingString = [replacingString stringByReplacingOccurrencesOfString:@" " withString:@""];//去一波空格
    replacingString = [replacingString noEmoji];
    return replacingString;
}


// 过滤所有表情
#pragma mark -- 代码next day优化
- (NSString *)stringContainsEmoji:(NSString *)string {
   __block NSString *tempString = @"";
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
         
         const unichar hs = [substring characterAtIndex:0];
         // surrogate pair
         if (0xd800 <= hs && hs <= 0xdbff) {
             if (substring.length > 1) {
                 const unichar ls = [substring characterAtIndex:1];
                 const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                 if (0x1d000 <= uc && uc <= 0x1f77f) {

                 }else{
                     tempString = [tempString stringByAppendingString:substring];
                 }
             }
         } else if (substring.length > 1) {
             const unichar ls = [substring characterAtIndex:1];
             if (ls == 0x20e3) {
                 
             }else{
                 tempString = [tempString stringByAppendingString:substring];
             }
             
         } else {
             // non surrogate
             if (0x2100 <= hs && hs <= 0x27ff) {
                 
             } else if (0x2B05 <= hs && hs <= 0x2b07) {
                 
             } else if (0x2934 <= hs && hs <= 0x2935) {
                 
             } else if (0x3297 <= hs && hs <= 0x3299) {
                 
             } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                 
             }else{
                tempString = [tempString stringByAppendingString:substring];
                 
             }
         }
     }];
    
    return tempString;
}

- (BOOL)hasSpecialString {
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^A-Za-z0-9\\u4E00-\\u9FA5]" options:NSRegularExpressionCaseInsensitive error:nil];
    if (!regex) {
        return YES;
    }
    NSString *str = [self mutableCopy];
    str = [regex stringByReplacingMatchesInString:str options:NSMatchingReportProgress range:NSMakeRange(0, str.length) withTemplate:@""];
    return self.length != str.length;
}

- (BOOL)hasIllegalCharacter {
    NSString *regex = @"()（）[]〖〗【】「」『』{}《》〔〕<>﹁﹂￥$&#+-*%=—_——~～@€£¢♂♀!！?？|/:：;；、,，.。…^`｀'‘“\"";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if (![emailTest evaluateWithObject:self]) {
        return YES;
    }
    return NO;
}

- (BOOL)hasEmoji {
    __block BOOL isEmoji = NO;
    [self enumerateSubstringsInRange:NSMakeRange(0, self.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        if ([self isEmoji:substring]) {
            isEmoji = YES;
            *stop = YES;
        }
    }];
    return isEmoji;
}

- (BOOL)isEmoji:(NSString *)str {
    static NSCharacterSet *variationSelectors;
    variationSelectors = [NSCharacterSet characterSetWithRange:NSMakeRange(0xFE00, 16)];
    if ([str rangeOfCharacterFromSet:variationSelectors].location != NSNotFound) {
        return YES;
    }
    const unichar high = [str characterAtIndex:0];
    if (0xD800 <= high && high <= 0xDBFF) {
        const unichar low = [str characterAtIndex: 1];
        const int codepoint = ((high - 0xD800) * 0x400) + (low - 0xDC00) + 0x10000;
        return (0x1D000 <= codepoint && codepoint <= 0x1F9FF);
    } else {
        return (0x2100 <= high && high <= 0x27BF);
    }
}

- (NSString *)noSpecialString {
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^A-Za-z0-9\\u4E00-\\u9FA5]" options:NSRegularExpressionCaseInsensitive error:nil];
    if (!regex) {
        return self;
    }
    return [regex stringByReplacingMatchesInString:self options:NSMatchingReportProgress range:NSMakeRange(0, self.length) withTemplate:@""];
}

//  \u0020-\\u007E  标点符号，大小写字母，数字
//  \u00A0-\\u00BE  特殊标点  (¡¢£¤¥¦§¨©ª«¬­®¯°±²³´µ¶·¸¹º»¼½¾)
//  \u2E80-\\uA4CF  繁简中文,日文，韩文 彝族文字
//  \uFE30-\\uFE4F  特殊标点(︴︵︶︷︸︹)
//  \uFF00-\\uFFEF  日文  (ｵｶｷｸｹｺｻ)
//  \u2000-\\u201f  特殊字符(‐‑‒–—―‖‗‘’‚‛“”„‟)
- (NSString *)noEmojiString {
    NSRegularExpression* expression = [NSRegularExpression regularExpressionWithPattern:@"[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u2000-\\u201f\r\n]" options:NSRegularExpressionCaseInsensitive error:nil];
    NSString *result = [expression stringByReplacingMatchesInString:self options:0 range:NSMakeRange(0, self.length) withTemplate:@""];
    return result;
}

@end
