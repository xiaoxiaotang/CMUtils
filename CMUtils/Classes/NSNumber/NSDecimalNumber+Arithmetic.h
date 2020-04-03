//
//  NSDecimalNumber+Arithmetic.h
//  SaicUtilsDemo
//
//  Created by quxiaolei on 2018/11/2.
//  Copyright © 2018年 saic. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDecimalNumber (Arithmetic)

/**
 加法
 */
- (NSDecimalNumber *(^)(NSString *))sc_add;

/**
 减法
 */
- (NSDecimalNumber *(^)(NSString *))sc_subtract;

/**
 乘法
 */
- (NSDecimalNumber *(^)(NSString *))sc_multiply;

/**
 除法
 */
- (NSDecimalNumber *(^)(NSString *))sc_divide;

/**
 向下取整
 @param position 取整的位数(小数点后)
 @return 返回取整后的本地化字符串
 */
- (NSString *)sc_roundingDown:(short )position;

@end

NS_ASSUME_NONNULL_END
