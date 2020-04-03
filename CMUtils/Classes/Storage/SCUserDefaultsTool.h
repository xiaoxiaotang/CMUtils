//
//  SCUserDefaultsTool.h
//  SaicUtilsDemo
//
//  Created by quxiaolei on 2018/11/6.
//  Copyright © 2018年 saic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SCUserDefaultsTool : NSObject

+ (void)sc_setString:(NSString *)v withKey:(NSString *)key;
+ (NSString *)sc_getStringWithKey:(NSString *)key;
+ (NSString *)sc_getStringWithKey:(NSString *)key withDefault:(NSString *)d;

+ (void)sc_setBool:(BOOL)v withKey:(NSString *)key;
+ (BOOL)sc_getBoolWithKey:(NSString *)key;
+ (BOOL)sc_getBoolWithKey:(NSString *)key withDefault:(BOOL)d;

+ (void)sc_setInterger:(NSInteger)v withKey:(NSString *)key;
+ (NSInteger)sc_getIntergerWithKey:(NSString *)key;
+ (NSInteger)sc_getIntergerWithKey:(NSString *)key withDefault:(NSInteger)d;

+(void)sc_setDict:(NSDictionary *)dict withKey:(NSString*)key;
+ (NSDictionary *)sc_getDictWithKey:(NSString*)key;

+(BOOL)sc_keyExists:(NSString*)key;
+ (void)sc_removeuserDefaultsWithKey:(NSString *)key;
@end
