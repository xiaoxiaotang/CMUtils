//
//  NSDecimalNumber+Arithmetic.m
//  SaicUtilsDemo
//
//  Created by quxiaolei on 2018/11/2.
//  Copyright © 2018年 saic. All rights reserved.
//

#import "NSDecimalNumber+Arithmetic.h"

// 暂时精确到小数点后4位
static int DecimalNumberScale = 4;
@implementation NSDecimalNumber (Arithmetic)

- (NSDecimalNumber *(^)(NSString *))sc_add {
    NSDecimalNumberHandler *decimalNumberHandler = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundBankers scale:DecimalNumberScale raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:YES];
    return ^(NSString *decimalString){
        NSDecimalNumber *secondDecimalNumber = [NSDecimalNumber decimalNumberWithString:decimalString];
        NSDecimalNumber *resultDecimalNumber = [self decimalNumberByAdding:secondDecimalNumber withBehavior:decimalNumberHandler];
        return resultDecimalNumber;
    };
}

- (NSDecimalNumber *(^)(NSString *))sc_subtract {
    NSDecimalNumberHandler *decimalNumberHandler = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundBankers scale:DecimalNumberScale raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:YES];
    return ^(NSString *decimalString){
        NSDecimalNumber *secondDecimalNumber = [NSDecimalNumber decimalNumberWithString:decimalString];
        NSDecimalNumber *resultDecimalNumber = [self decimalNumberBySubtracting:secondDecimalNumber withBehavior:decimalNumberHandler];
        return resultDecimalNumber;
    };
}

- (NSDecimalNumber *(^)(NSString *))sc_multiply {
    NSDecimalNumberHandler *decimalNumberHandler = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundBankers scale:DecimalNumberScale raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:YES];
    return ^(NSString *decimalString){
        NSDecimalNumber *secondDecimalNumber = [NSDecimalNumber decimalNumberWithString:decimalString];
        NSDecimalNumber *resultDecimalNumber = [self decimalNumberByMultiplyingBy:secondDecimalNumber withBehavior:decimalNumberHandler];
        return resultDecimalNumber;
    };
}

- (NSDecimalNumber *(^)(NSString *))sc_divide {
    NSDecimalNumberHandler *decimalNumberHandler = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundBankers scale:DecimalNumberScale raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:YES];
    return ^(NSString *decimalString){
        NSDecimalNumber *secondDecimalNumber = [NSDecimalNumber decimalNumberWithString:decimalString];
        NSDecimalNumber *resultDecimalNumber = [self decimalNumberByDividingBy:secondDecimalNumber withBehavior:decimalNumberHandler];
        return resultDecimalNumber;
    };
}

// 向下取整
- (NSString *)sc_roundingDown:(short )position {
    NSDecimalNumberHandler *roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundDown scale:position raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    NSDecimalNumber *roundedOunces = [self decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
    return [NSString stringWithFormat:@"%@",[roundedOunces descriptionWithLocale:nil]];
}

@end
