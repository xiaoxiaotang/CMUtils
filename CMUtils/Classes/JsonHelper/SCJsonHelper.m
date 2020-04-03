//
//  SCJsonHelper.m
//  SaicCarPlatform
//
//  Created by 刘旭 on 2018/6/14.
//  Copyright © 2018年 Saic. All rights reserved.
//

#import "SCJsonHelper.h"

@implementation SCJsonHelper

+(id)sc_jsonValueToArrayOrDictionary:(NSString *)jsonData {
    if (jsonData != nil) {
        NSData* data = [jsonData dataUsingEncoding:NSUTF8StringEncoding];
        id jsonObject = [NSJSONSerialization JSONObjectWithData:data
                                                        options:NSJSONReadingAllowFragments
                                                          error:nil];
        
        if (jsonObject != nil){
            return jsonObject;
        }else{
            // 解析错误
            return nil;
        }
    }
    return nil;
}

+(NSString*)sc_arrayOrDictionaryToJsonValue:(id)object {
    if (object != nil) {
        if (![NSJSONSerialization isValidJSONObject:object]) {
            return nil;
        }
        NSError *parseError = nil;
        NSData  *jsonData = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:&parseError];
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return nil;
}

@end
