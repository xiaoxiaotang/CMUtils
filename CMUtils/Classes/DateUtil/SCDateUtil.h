//
//  SCDateUtil.h
//  SaicCarPlatform
//
//  Created by hext on 2018/8/23.
//  Copyright © 2018年 Saic. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Date工具类, 处理日期时间装换相关
 */
@interface SCDateUtil : NSObject

/**
 根据传入的date和格式, 返回一个时间字符串
 @param date 日期时间
 @param format 格式
 @return 格式化后的时间字符串
 */
+ (NSString *)sc_stringWithDate:(NSDate *)date format:(NSString *)format;

/**
 根据传入的时间字符串和格式, 返回一个date
 @param string 时间字符串
 @param format 格式
 @return 格式化后的date
 */
+ (NSDate *)sc_dateWithString:(NSString *)string format:(NSString *)format;

/**
 根据传入的时间字符串, 用"yyyy-MM-dd HH:mm:ss"格式化返回一个date
 @param string 时间字符串
 @return 格式化后的date
 */
+ (NSDate *)sc_dateWithString:(NSString *)string;

/**
 传入一个"yyyy-MM-dd HH:mm:ss"格式的时间字符串, 转换为另一个给定格式的时间字符串
 @param fromString "yyyy-MM-dd HH:mm:ss"格式的时间字符串
 @param toFormat 目标时间字符串的格式
 @return 转换后的时间字符串
 */
+ (NSString *)sc_stringWithFromString:(NSString *)fromString toFormat:(NSString *)toFormat;

/**
 把"yyyy-MM-dd HH:mm:ss"格式的时间字符串 转换成友好显示的时间字符串. 如:
 今天 14:24
 昨天 09:22
 明天 15:04
 2019.07.24 22:11
 
 @param fromString "yyyy-MM-dd HH:mm:ss"格式的时间字符串
 @return 友好显示的时间字符串
 */
+ (NSString *)sc_friendlyDisplayWithFromString:(NSString *)fromString;

/**
 把传入date转换成友好显示的时间字符串. 如:
 今天 14:24
 昨天 09:22
 明天 15:04
 2019.07.24 22:11
 
 @param date date
 @return 友好显示的时间字符串
 */
+ (NSString *)sc_friendlyDisplayWithDate:(NSDate *)date;

/**
 把传入date转换成友好显示的时间字符串. 如:
 今天 14:24
 昨天 09:22
 明天 15:04
 其它日期的时间格式需要传入
 
 @param date date
 @param yearFormat 其它日期(非今天昨天明天)的时间格式
 @return 友好显示的时间字符串
 */
+ (NSString *)sc_friendlyDisplayWithDate:(NSDate *)date yearFormat:(NSString *)yearFormat;

/**
 把传入date转换成友好显示的时间字符串. 如:
 今天 14:24
 昨天 09:22
 当前年的格式需要传入
 非当前年的格式需要传入

 @param date 源date
 @param inYearFormat 当前年的格式
 @param outYearFormat 非当前年的格式
 @return 友好显示的时间字符串
 */
+ (NSString *)sc_friendlyDisplayWithDate:(NSDate *)date inYearFormat:(NSString *)inYearFormat outYearFormat:(NSString *)outYearFormat;

/** 获取当前时间 yyyy-MM-dd HH:mm:ss */
+ (NSString *)sc_currentTime;

/// 获取当前时间戳
+ (NSString *)sc_currentTimestamp;

/**
 当前时间

 @return 时间：2019-07-10
 */
+ (NSString * )getCurrentDay;

/**
 @brief 时间转化为秒单位的时间戳
 
 @param date 时间
 */
+(double)timestampFromDate:(NSDate *)date;

/**
 @brief 时间转化为毫秒单位的时间戳
 
 @param date 时间
 */
+(long long)MSTimestampFromDate:(NSDate *)date;

/**
 @brief 把时间字符串转化为特定格式的字符串
 
 @param type 字符串输出格式 （例：yyyy-MM-dd HH:mm:ss）
 @param string 时间字符串 精确到毫秒
 */
+(NSString *)formatStringWithType:(NSString *)type fromDateString:(NSString *)string;

/**
 @brief 获取当前时间和某个时间的秒数差
 
 @param string 时间字符串
 */
+(long long)secondsSinceNowWithDateString:(NSString *)string;

/**
 @brief 时间戳转string

 @param timeInterval 时间戳 单位：毫秒
 @param dateFormat 时间格式类型
 @return 对应时间格式的string
 */
+(NSString *)formatStringFromTimeInterval:(NSTimeInterval)timeInterval dateFormat:(NSString *)dateFormat;

/**
 @brief 根据传入的月份获取上个月

 @param monthString 传入的月份（格式为xx年xx月 或 xx月 或 本月）
 @return 传入月份的上个月
 */
+(NSString *)getLastMonth:(NSString *)monthString;

/**
 @brief 根据传入的月份获取下个月

 @param monthString 传入的月份（格式为xx年xx月 或 xx月）
 @return 传入月份的下个月
 */
+(NSString *)getNextMonth:(NSString *)monthString;

/**
 @brief 根据后台的时间格式返回钱包页面所需的时间格式

 @param dateStr 时间string 格式：yyyy-MM-dd HH:mm:ss
 @return 返回的时间戳格式
 */
+(NSString *)formatWalletDateStringWithDateString:(NSString *)dateStr;

/**
 @brief 根据传入的钱包月份返回该月第一天的时间

 @param monthString 钱包中的月份string
 @return 对应月份第一天的时间 格式为yyyy-MM-01 00:00:00
 */
+(NSString *)getDateStringWithWalletMonthString:(NSString *)monthString;

/** 获取本周周一的日期  yyyy.MM.dd */
+(NSString *)getCurrentMondayString;

/** 获取本周的起止日期 yyyy.MM.dd-yyyy.MM.dd */
+(NSString *)getCurrentWeekDateString;

/**
 @brief 获取下周的起止日期

 @param string 传入的起止日期  yyyy.MM.dd-yyyy.MM.dd
 @return 传入日期下周的起止日期  yyyy.MM.dd-yyyy.MM.dd
 */
+(NSString *)getNextWeekDateStringWithSting:(NSString *)string;

/**
 @brief 获取上周的起止日期
 
 @param string 传入的起止日期  yyyy.MM.dd-yyyy.MM.dd
 @return 传入日期上周的起止日期  yyyy.MM.dd-yyyy.MM.dd
 */
+(NSString *)getLastWeekDateStringWithSting:(NSString *)string;

/** 根据传入的date，返回星期 */
+(NSString *)getWeekDayWithDate:(NSDate *)date;

/**
 @brief 根据传入的最早时间，返回至今为止的星期的数组

 @param formatStr 时间格式
 @param minDate 最早时间
 @param separateStr 周一和周末之间的连接符
 @return 从最早时间至今的星期的数组
 */
+ (NSArray *)getWeekDateArrayWithformatterString:(NSString *)formatStr minDate:(NSDate *)minDate separateStr:(NSString *)separateStr;



/**
 判断当前时间是否在两个时间之间
 @param fromdate 开始时间
 @param toDatel  结束时间
 @return 结果
 */
+ (BOOL)inTimeQuantumFromDate:(NSString *)fromdate toDate:(NSString *)toDatel;

/** 根据传入的date，返回是否本年 */
+ (BOOL)isThisYear:(NSString *)timeStampString;

/**
 获取历史行程时间格式
 @param timeStampString 时间戳
 @param orderType  订单类型
 @return 结果
 */
+ (NSString *)myJourneyOrderDateString:(NSString *)timeStampString type:(NSInteger)orderType;

/**
 获取时间间隔
 @param beginTime 开始时间字符串
 @param nowTime  当前时间字符串
 @return 结果
 */
+ (double)calculateTimeIntervalWithBeginTime:(NSString *)beginTime nowTime:(NSString *)nowTime;

/**
 获取时间间隔
 @param beginTime 开始时间戳
 @param nowTime  当前时间戳
 @return 结果
 */
+ (double)timeIntervalWithBeginTime:(double)beginTime nowTime:(double)nowTime;

/**
 获取当前天数
 */
+(NSString *)getCurrentDayD;

/**
 @brief 时间戳转化为时间
 
 @param timeString 时间戳
 */
+ (NSString *)achieveDayFormatByTimeString:(NSString *)timeString;

+ (NSString *)dateToYearMonth:(NSString *)inputDateString;

@end
