//
//  SCJsonHelper.h
//  SaicCarPlatform
//
//  Created by 刘旭 on 2018/6/14.
//  Copyright © 2018年 Saic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SCJsonHelper : NSObject

/**
 @brief 将JSON串转化为字典或者数组
 
 @param jsonData json字符串
 */
+(id)sc_jsonValueToArrayOrDictionary:(NSString *)jsonData;

//
/**
 @brief 将字典or数组转化为Json
 
 @param object 字典or数组
 */
+(NSString*)sc_arrayOrDictionaryToJsonValue:(id)object;

@end
