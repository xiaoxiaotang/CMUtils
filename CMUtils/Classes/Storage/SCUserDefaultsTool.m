//
//  SCUserDefaultsTool.m
//  SaicUtilsDemo
//
//  Created by quxiaolei on 2018/11/6.
//  Copyright © 2018年 saic. All rights reserved.
//

#import "SCUserDefaultsTool.h"

@implementation SCUserDefaultsTool

+ (NSString *)sc_getStringWithKey:(NSString *)key {
    if (!key) {
        return nil;
    }
    NSString *string = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if(!string){
        string = @"";
    }
    return string;
}

+ (NSString *)sc_getStringWithKey:(NSString *)key withDefault:(NSString *)d {
    if (!key) {
        return d;
    }
    NSString *string = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if(!string){
        string = d;
    }
    return string;
}

+ (void)sc_setString:(NSString *)v withKey:(NSString *)key {
    if (!v || !key) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setObject:v forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)sc_getBoolWithKey:(NSString *)key {
    if (!key) {
        return NO;
    }
    return [[[NSUserDefaults standardUserDefaults] objectForKey:key] boolValue];
}

+ (BOOL)sc_getBoolWithKey:(NSString *)key withDefault:(BOOL)d {
    if (!key) {
        return d;
    }
    if([[NSUserDefaults standardUserDefaults] objectForKey:key] == nil) {
        return d;
    }
    return [[[NSUserDefaults standardUserDefaults] objectForKey:key] boolValue];
}

+ (void)sc_setBool:(BOOL)v withKey:(NSString *)key {
    if (!key) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setObject:v ? @"1" : @"0" forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSInteger)sc_getIntergerWithKey:(NSString *)key {
    if (!key) {
        return 0;
    }
    return [[NSUserDefaults standardUserDefaults] integerForKey:key];
}

+ (NSInteger)sc_getIntergerWithKey:(NSString *)key withDefault:(NSInteger)d {
    if (!key) {
        return d;
    }
    if([[NSUserDefaults standardUserDefaults] objectForKey:key] == nil) {
        return d;
    }
    return [[NSUserDefaults standardUserDefaults] integerForKey:key];
}

+ (void)sc_setInterger:(NSInteger)v withKey:(NSString *)key {
    if (!v || !key) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setInteger:v forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)sc_setDict:(NSDictionary *)dict withKey:(NSString*)key {
    if (!dict || !key) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setObject:dict forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSDictionary *)sc_getDictWithKey:(NSString*)key {
    if (!key) {
        return @{};
    }
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:key];
    if(!dict){
        dict = @{};
    }
    return dict;
}

+ (BOOL)sc_keyExists:(NSString *)key {
    if (!key) {
        return NO;
    }
    return [[NSUserDefaults standardUserDefaults] objectForKey:key] != nil;
}

+ (void)sc_removeuserDefaultsWithKey:(NSString *)key {
    if (!key) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
}

@end
