//
//  NSObject+equal.m
//  SaicUtilsDemo
//
//  Created by v-zengdongmei on 2019/4/10.
//  Copyright © 2019 saic. All rights reserved.
//

#import "NSObject+equal.h"

@implementation NSObject (equal)

- (BOOL)saic_isEqualToObject:(id)object inProperty:(NSString *)property {
    if (!object || !property || property.length == 0) {
        return NO;
    }
    if ([self isEqual:object]) {
        return YES;
    }
    SEL sel = NSSelectorFromString(property);
    if (![self respondsToSelector:sel] || ![object respondsToSelector:sel]) {
        return NO;
    }
    id value1 = [self valueForKey:property];
    id value2 = [object valueForKey:property];
    return [self saic_isEqualProperty:value1 withProp2:value2];
}

- (BOOL)saic_isEqualProperty: (id)prop1 withProp2: (id)prop2 {
    if ([prop1 isKindOfClass:[NSString class]] && [prop2 isKindOfClass:[NSString class]]) {
        NSString *obj1 = prop1;
        NSString *obj2 = prop2;
        return [obj1 isEqualToString:obj2];
    }
    
    if ([prop1 isKindOfClass:[NSDate class]] && [prop2 isKindOfClass:[NSDate class]]) {
        NSDate *obj1 = (NSDate *)prop1;
        NSDate *obj2 = (NSDate *)prop2;
        NSComparisonResult result = [obj1 compare:obj2];
        if (result == NSOrderedSame) {
            return YES;
        }
        return NO;
    }
    
    if ([prop1 isKindOfClass:[NSValue class]] && [prop2 isKindOfClass:[NSValue class]]) {
        NSValue *obj1 = (NSValue *)prop1;
        NSValue *obj2 = (NSValue *)prop2;
        return [obj1 isEqualToValue:obj2];
    }
    if ([prop1 isKindOfClass:[NSArray class]] && [prop2 isKindOfClass:[NSArray class]]) {
        NSArray *obj1 = (NSArray *)prop1;
        NSArray *obj2 = (NSArray *)prop2;
        if (obj1.count != obj2.count) {
            return NO;
        }
        __block BOOL flag = YES;
        [obj1 enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (![self saic_isEqualProperty:obj withProp2:obj2[idx]]) {
                *stop = YES;
                flag = NO;
            }
        }];
        return flag;
    }
    
    if ([prop1 isKindOfClass:[NSDictionary class]] && [prop2 isKindOfClass:[NSDictionary class]]) {
        NSDictionary *obj1 = (NSDictionary *)prop1;
        NSDictionary *obj2 = (NSDictionary *)prop2;
        if (obj1.count != obj2.count) {
            return NO;
        }
        __block BOOL flag = YES;
        [obj1 enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            if (![self saic_isEqualProperty:obj withProp2:obj2[key]]) {
                *stop = YES;
                flag = NO;
            }
        }];
        return flag;
    }
    
    return NO;
}

@end
