//
//  SCEncryption.m
//  SaicCarPlatform
//
//  Created by ZT_L on 2018/9/5.
//  Copyright © 2018年 Saic. All rights reserved.
//

#import "SCEncryption.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
#import "NSString+SCExt.h"
/// md5加密的SALT
static const char salt[] = {'7', '*', 'w', '3', '%', 'M', 'M', '1'};

@implementation SCEncryption

+ (NSString *)sc_md5String:(NSString *)plainText {
    
    if (!plainText.sc_notEmpty) {
        return nil;
    }
    const char *cStr = [plainText UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (int)strlen(cStr), digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i ++) {
        [output appendFormat:@"%02x",digest[i]];
    }
    return output;
}

+ (NSString *)sc_signatureVerificationDict:(NSDictionary *)dict{
    
    NSArray * allKeys = [dict allKeys];
    NSArray *sortedArray  = [allKeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2 options:NSCaseInsensitiveSearch];
    }];
    NSString * md5String = @"";
    
    for (NSString *key in sortedArray) {
        
        id value = [dict objectForKey:key];
        if([value isKindOfClass:[NSString class]] ){
            if(![value isEqualToString:@""]){
                md5String = [NSString stringWithFormat:@"%@%@",md5String,value];
            }
        }else if ([value isKindOfClass:[NSNumber class]]){
            md5String = [NSString stringWithFormat:@"%@%@",md5String,[self fromTypeToString:value]];
        }
        else if ([value isKindOfClass:[NSArray class]]){
            md5String = [NSString stringWithFormat:@"%@%@",md5String,[self fromArrayToString:value]];
        }
    }
    
    md5String = [self hmacSHA256:md5String withKey:[self saltStringFormat]];
    
    return md5String;
}

+ (NSString *)sc_signatureVerificationText:(NSString *)plainText{
    NSString * md5String = @"";
    
    md5String = [self hmacSHA256:plainText withKey:[self saltStringFormat]];
    
    return md5String;
}

+ (NSString*)fromArrayToString:(NSArray *)array{
    NSString * md5String = @"";
    for(int i = 0; i < [array count]; i++){
        NSDictionary *dict = [array objectAtIndex:i];
        md5String = [NSString stringWithFormat:@"%@%@",md5String,[self fromDicToString:dict]];
    }
    return md5String;
}

+ (NSString*)fromDicToString:(NSDictionary *)dict{
    NSArray * allKeys = [dict allKeys];
    NSArray *sortedArray  = [allKeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2 options:NSCaseInsensitiveSearch];
    }];
    NSString * md5String = @"";
    
    for (NSString *key in sortedArray) {
        
        id value = [dict objectForKey:key];
        if([value isKindOfClass:[NSString class]] ){
            if(![value isEqualToString:@""]){
                md5String = [NSString stringWithFormat:@"%@%@",md5String,value];
            }
        }else if ([value isKindOfClass:[NSNumber class]]){
            md5String = [NSString stringWithFormat:@"%@%@",md5String,[self fromTypeToString:value]];
        }
    }
    
    return md5String;
}

+ (NSString*)fromTypeToString:(NSNumber *)data{
    
    if (strcmp([data objCType], @encode(BOOL)) == 0) {
        NSLog(@"this is a bool");

        return @"BOOL";
    
    } else if (strcmp([data objCType], @encode(int)) == 0 || strcmp([data objCType], @encode(long)) == 0) {
        
        long value = [data longValue];
        if (value == 0){
            return @"";
        }else{
            return [NSString stringWithFormat:@"%ld",value];
        }
        
    } else if (strcmp([data objCType], @encode(int)) == 0 || strcmp([data objCType], @encode(long long)) == 0) {
        
        long long value = [data longLongValue];
        if (value == 0){
            return @"";
        }else{
            return [NSString stringWithFormat:@"%lld",value];
        }
        
    } else if (strcmp([data objCType], @encode(float)) == 0 || strcmp([data objCType], @encode(double)) == 0) {
        
        double value = round([data doubleValue] * 1000.0);
        if (value == 0){
            return @"";
        }else{
            return [NSString stringWithFormat:@"%.0f",value];
        }
        
    }
    return @"";
}
+ (NSString *)saltStringFormat {
    NSMutableString *saltMuta = [@"" mutableCopy];
    for (int i = 0; i < 8; i++) {//sizeof(salt)
        [saltMuta appendFormat:@"%c", salt[i]];
    }
    return saltMuta;
}

+(NSString *)sha256Encryption:(NSString *)string {
    const char *cstr = [string cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:string.length];
    
    uint8_t digest[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(data.bytes, (int)data.length, digest);
    
    NSMutableString* result = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [result appendFormat:@"%02x", digest[i]];
    }
    
    return result;
}

/**
 加密方式,MAC算法: HmacSHA256

 @param plaintext 要加密的文本
 @param key 秘钥
 @return 加密后的字符串
 */
+ (NSString *)hmacSHA256:(NSString *)plaintext withKey:(NSString *)key
{
    const char *cKey  = [key cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [plaintext cStringUsingEncoding:NSUTF8StringEncoding];
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    NSData *HMACData = [NSData dataWithBytes:cHMAC length:sizeof(cHMAC)];
    const unsigned char *buffer = (const unsigned char *)[HMACData bytes];
    NSMutableString *HMAC = [NSMutableString stringWithCapacity:HMACData.length * 2];
    for (int i = 0; i < HMACData.length; ++i){
        [HMAC appendFormat:@"%02x", buffer[i]];
    }
    
    return HMAC;
}

@end
