//
//  SCDateUtil.m
//  SaicCarPlatform
//
//  Created by hext on 2018/8/23.
//  Copyright © 2018年 Saic. All rights reserved.
//

#import "SCDateUtil.h"

@implementation SCDateUtil

+ (NSDateFormatter *)dateFormatter{
    static NSDateFormatter *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[NSDateFormatter alloc] init];
        //为当前地区
        [sharedInstance setLocale:[NSLocale currentLocale]];
        //获取当前时区
        NSTimeZone *toTimeZone = [NSTimeZone localTimeZone];
        //获取当前时区的时间与GMT0时区相差的毫秒数
        NSInteger toGMTOffset = [toTimeZone secondsFromGMTForDate:[NSDate date]];
        //设置时区 (注: 要用相差的时间来设置, 不能直接设置上海或北京时区, 虽然都是+8时区; 不然会有夏令时的问题, 如1989-04-16转换会失败为nil, 因为这一天没有0时到1时)
        [sharedInstance setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:toGMTOffset]];
    });
    return sharedInstance;
}

+ (NSString *)sc_stringWithDate:(NSDate *)date format:(NSString *)format{
    NSDateFormatter *df = [self dateFormatter];
    [df setDateFormat:format];
    NSString *dateStr = [df stringFromDate:date];
    return dateStr;
}

+ (NSDate *)sc_dateWithString:(NSString *)string format:(NSString *)format{
    NSDateFormatter *df = [self dateFormatter];
    [df setDateFormat:format];
    NSDate *date = [df dateFromString:string];
    return date;
}

+ (NSDate *)sc_dateWithString:(NSString *)string{
    return [self sc_dateWithString:string format:@"yyyy-MM-dd HH:mm:ss"];
}

+ (NSString *)sc_stringWithFromString:(NSString *)fromString toFormat:(NSString *)toFormat{
    NSDateFormatter *df = [self dateFormatter];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [df dateFromString:fromString];
    if (!date) {
        return @"";
    }
    [df setDateFormat:toFormat];
    NSString *dateStr = [df stringFromDate:date];
    return dateStr;
}

+ (NSString *)sc_friendlyDisplayWithFromString:(NSString *)fromString{
    NSDate *date = [self sc_dateWithString:fromString format:@"yyyy-MM-dd HH:mm:ss"];
    if (!date) {
        return @"";
    }
    return [self sc_friendlyDisplayWithDate:date];
}

+ (NSString *)sc_friendlyDisplayWithDate:(NSDate *)date{
    return [self sc_friendlyDisplayWithDate:date yearFormat:@"yyyy.MM.dd HH:mm"];
}

+ (NSString *)sc_friendlyDisplayWithDate:(NSDate *)date yearFormat:(NSString *)yearFormat{
    return [self sc_friendlyDisplayWithDate:date inYearFormat:yearFormat outYearFormat:yearFormat];
}

+ (NSString *)sc_friendlyDisplayWithDate:(NSDate *)date inYearFormat:(NSString *)inYearFormat outYearFormat:(NSString *)outYearFormat {
    //获取用户的当前日历
    NSCalendar *calendar = [NSCalendar currentCalendar];
    //如果给定日期是今天
    if ([calendar isDateInToday:date]) {
        return [self sc_stringWithDate:date format:@"今天 HH:mm"];
    }
    //如果给定日期是昨天
    if ([calendar isDateInYesterday:date]) {
        return [self sc_stringWithDate:date format:@"昨天 HH:mm"];
    }
    //如果给定日期是明天
    if ([calendar isDateInTomorrow:date]) {
        return [self sc_stringWithDate:date format:@"明天 HH:mm"];
    }
    //如果给定日期跟当前日期是同一年
    NSInteger fromYear = [calendar component:NSCalendarUnitYear fromDate:date];
    NSInteger toYear = [calendar component:NSCalendarUnitYear fromDate:NSDate.date];
    if (fromYear - toYear == 0) {
        return [self sc_stringWithDate:date format:inYearFormat];
    }
    //非同一年的情况
    return [self sc_stringWithDate:date format:outYearFormat];
}

/** 获取当前时间 yyyy-MM-dd HH:mm:ss */
+ (NSString *)sc_currentTime {
    NSDateFormatter *dateFormatter = [self dateFormatter];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    return dateString;
}

+ (NSString *)sc_currentTimestamp {
    double timestamp = [NSDate date].timeIntervalSince1970 *1000;
    return [NSString stringWithFormat:@"%f", timestamp];
}

//获取当天
+ (NSString * )getCurrentDay{
    
    NSDateFormatter *dateFormat = [self dateFormatter];
    
    //YYYY表示当天所在的周属于的年份，一周从周日开始，周六结束，只要本周跨年，那么这周就算入下一年。
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    
    return [dateFormat stringFromDate:[NSDate date]];
    
}

+(double)timestampFromDate:(NSDate *)date {
    return [date timeIntervalSince1970];
}

+(long long)MSTimestampFromDate:(NSDate *)date {
    return [self timestampFromDate:date] * 1000;
}

+(NSString *)formatStringWithType:(NSString *)type fromDateString:(NSString *)string {
    NSDateFormatter* dateFormat = [self dateFormatter];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    NSDate *date = [dateFormat dateFromString:string];
    [dateFormat setDateFormat:type];
    return [dateFormat stringFromDate:date];
}

+(long long)secondsSinceNowWithDateString:(NSString *)string {
    NSDateFormatter* dateFormat = [self dateFormatter];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    NSDate *date = [dateFormat dateFromString:string];
    
    return labs((long long)[date timeIntervalSinceNow]);
}


+(NSString *)formatStringFromTimeInterval:(NSTimeInterval)timeInterval dateFormat:(NSString *)dateFormat {
    NSDateFormatter* dateFormatter = [self dateFormatter];
    [dateFormatter setDateFormat:dateFormat];
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:timeInterval/1000];
    return [dateFormatter stringFromDate:date];
}

//获取当前年
+(NSString *)getCurrentYear {
    NSDateFormatter* dateFormat = [self dateFormatter];
    [dateFormat setDateFormat:@"yyyy"];
    return [dateFormat stringFromDate:[NSDate date]];
}

//获取当前月份
+(NSString *)getCurrentMonth {
    NSDateFormatter* dateFormat = [self dateFormatter];
    [dateFormat setDateFormat:@"MM"];
    return [dateFormat stringFromDate:[NSDate date]];
}

//获取当前天数
+(NSString *)getCurrentDayD {
    NSDateFormatter* dateFormat = [self dateFormatter];
    [dateFormat setDateFormat:@"dd"];
    return [dateFormat stringFromDate:[NSDate date]];
}

//根据传入的月份获取上个月
+(NSString *)getLastMonth:(NSString *)monthString {
    if (![monthString hasSuffix:@"月"]) {
        return monthString;
    }
    if ([monthString isEqualToString:@"本月"]) {
        monthString = [NSString stringWithFormat:@"%@月", [self getCurrentMonth]];
    }
    NSArray * dateArr = [monthString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"年月"]];
    if (dateArr.count < 3) {
        NSInteger month = [dateArr[0] integerValue];
        if (month == 1) {
            NSInteger year = [[self getCurrentYear] integerValue];
            NSString * lastMonth = [NSString stringWithFormat:@"%02ld年12月", (long)year-1];
            return [lastMonth substringFromIndex:2];
        } else {
            return [NSString stringWithFormat:@"%ld月", month-1];
        }
    } else {
        NSInteger month = [dateArr[1] integerValue];
        if (month == 1) {
            NSInteger year = [dateArr[0] integerValue];
            if (year == 0) {
                year = 100;
            }
            NSString * lastMonth = [NSString stringWithFormat:@"%02ld年12月", year-1];
            return lastMonth;
        } else {
            return [NSString stringWithFormat:@"%@年%ld月", dateArr[0], month-1];
        }
    }
}

//根据传入的月份获取下个月
+(NSString *)getNextMonth:(NSString *)monthString {
    if (![monthString hasSuffix:@"月"]) {
        return monthString;
    }
    if ([monthString isEqualToString:@"本月"]) {
        return monthString;
    }
    if ([[self getLastMonth:@"本月"] isEqualToString:monthString]) {
        return @"本月";
    }
    NSArray * dateArr = [monthString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"年月"]];
//    今年之前
    if (dateArr.count < 3) {
        NSInteger month = [dateArr[0] integerValue];
        if (month > [[self getCurrentMonth] integerValue]) {
            return monthString;
        }
        return [NSString stringWithFormat:@"%ld月", month+1];
//        今年
    } else {
        NSInteger month = [dateArr[1] integerValue];
        if (month == 12) {
            NSInteger year = [dateArr[0] integerValue];
            if (year == 99) {
                return @"00年01月";
            }
            if (year + 2001 == [[self getCurrentYear] integerValue]) {
                return @"01月";
            }
            NSString * lastMonth = [NSString stringWithFormat:@"%02ld年1月", year + 1];
            return lastMonth;
        } else {
            return [NSString stringWithFormat:@"%@年%ld月", dateArr[0], month+1];
        }
    }
}

//今天
+ (NSString *)getCurrentDay1 {
    NSDateFormatter* dateFormat = [self dateFormatter];
    [dateFormat setDateFormat:@"yyyy年MM月dd日"];
    return [dateFormat stringFromDate:[NSDate date]];
}

//昨天
+(NSString *)getYestoday {
    NSDateFormatter* dateFormat = [self dateFormatter];
    [dateFormat setDateFormat:@"yyyy年MM月dd日"];
    NSTimeInterval yestodayTime = [[NSDate date] timeIntervalSince1970] - 60*60*24;
    return [dateFormat stringFromDate:[[NSDate alloc]initWithTimeIntervalSince1970:yestodayTime]];
}

//string转时间戳
+ (NSTimeInterval)timeIntervalFormDateString:(NSString *)dateString {
    NSDateFormatter *format = [self dateFormatter];
    [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [format setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Shanghai"]];
    return [[format dateFromString:dateString] timeIntervalSince1970] * 1000;
}

//根据后台的时间格式返回钱包页面所需的时间格式
+ (NSString *)formatWalletDateStringWithDateString:(NSString *)dateStr {
    NSTimeInterval timeInterval = [self timeIntervalFormDateString:dateStr];
    NSString * dateString = [self formatStringFromTimeInterval:timeInterval dateFormat:@"yyyy年MM月dd日 HH:mm"];
//    今天
    if ([dateString containsString:[self getCurrentDay1]]) {
        return [dateString stringByReplacingOccurrencesOfString:[self getCurrentDay1] withString:@"今天"];
    }
//    昨天
    if ([dateString containsString:[self getYestoday]]) {
        return [dateString stringByReplacingOccurrencesOfString:[self getYestoday] withString:@"昨天"];
    }
//    今年
    if ([dateString containsString:[[self getCurrentYear] stringByAppendingString:@"年"]]) {
        dateString = [dateString stringByReplacingOccurrencesOfString:[[self getCurrentYear] stringByAppendingString:@"年"] withString:@""];
        return dateString;
    }
//    今年之前
    if (dateString.length > 3) {
        return [dateString substringFromIndex:2];
    } else {
        return dateString;
    }
}

//根据传入的钱包月份返回该月第一天的时间
+(NSString *)getDateStringWithWalletMonthString:(NSString *)monthString {
    if ([monthString isEqualToString:@"本月"]) {
        monthString = [NSString stringWithFormat:@"%@月", [self getCurrentMonth]];
    }
    if ([monthString containsString:@"月"]) {
//        monthString包含年
        if ([monthString containsString:@"年"]) {
            NSDateFormatter* walletDateFormat = [self dateFormatter];
            [walletDateFormat setDateFormat:@"yy年MM月"];
            NSDate *walletDate = [walletDateFormat dateFromString:monthString];
            
            NSDateFormatter* finalDateFormat = [self dateFormatter];
            [finalDateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            return [finalDateFormat stringFromDate:walletDate];
//            今年
        } else {
            if (monthString.length == 2) {
                monthString =[@"0" stringByAppendingString:monthString];
            }
            monthString = [[[self getCurrentYear] stringByAppendingString:@"年"] stringByAppendingString:monthString];
            
            NSDateFormatter* walletDateFormat = [self dateFormatter];
            [walletDateFormat setDateFormat:@"yyyy年MM月"];
            NSDate *walletDate = [walletDateFormat dateFromString:monthString];
            
            NSDateFormatter* finalDateFormat = [self dateFormatter];
            [finalDateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            return [finalDateFormat stringFromDate:walletDate];
        }
    } else {
        return monthString;
    }
}

/** 获取本周周一的日期 */
+ (NSDate *)getCurrentMondayDate {
    NSDate *nowDate = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comp = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday  fromDate:nowDate];
    // 获取今天是周几
    NSInteger weekDay = [comp weekday];
    //1为周日
    if (weekDay == 1) {
        weekDay = 7;
    } else {
        weekDay = weekDay-1;
    }
    NSDate *monday = [NSDate dateWithTimeIntervalSinceNow:-(weekDay-1)*24*60*60];
    NSString *mondayString = [self sc_stringWithDate:monday format:@"yyyy.MM.dd"];
    return [self sc_dateWithString:mondayString format:@"yyyy.MM.dd"];
}

/** 获取本周周一的日期 */
+ (NSString *)getCurrentMondayString {
    NSDate *monday = [self getCurrentMondayDate];
    NSString *mondayString = [self sc_stringWithDate:monday format:@"yyyy.MM.dd"];
    return mondayString;
}

/** 获取本周的起止日期 */
+ (NSString *)getCurrentWeekDateString {
    NSString *mondayString = [self getCurrentMondayString];
    NSString *endString = [self sc_stringWithDate:[NSDate date] format:@"yyyy.MM.dd"];
    return [NSString stringWithFormat:@"%@-%@", mondayString, endString];
}

/** 获取下周的起止日期 */
+ (NSString *)getNextWeekDateStringWithSting:(NSString *)string {
    NSArray *array = [string componentsSeparatedByString:@"-"];
    if (array.count < 2) {
        return string;
    }
    NSDate *weenday = [self sc_dateWithString:array[1] format:@"yyyy.MM.dd"];
    NSDate *nextMonday = [weenday dateByAddingTimeInterval:24*60*60];
    if ([[self sc_stringWithDate:nextMonday format:@"yyyy.MM.dd"] isEqual:[self getCurrentMondayString]]) {
        return [self getCurrentWeekDateString];
    }
    NSDate *nextWeenday = [nextMonday dateByAddingTimeInterval:24*60*60*6];
    NSString *nextMondayStr = [self sc_stringWithDate:nextMonday format:@"yyyy.MM.dd"];
    NSString *nextWeendayStr = [self sc_stringWithDate:nextWeenday format:@"yyyy.MM.dd"];
    return [NSString stringWithFormat:@"%@-%@", nextMondayStr, nextWeendayStr];
}

/** 获取上周的起止日期 */
+(NSString *)getLastWeekDateStringWithSting:(NSString *)string {
    NSArray *array = [string componentsSeparatedByString:@"-"];
    if (array.count < 2) {
        return string;
    }
    NSDate *monday = [self sc_dateWithString:array[0] format:@"yyyy.MM.dd"];
    NSDate *finalMonday = [monday dateByAddingTimeInterval:-24*60*60*7];
    NSDate *finalWeenday = [finalMonday dateByAddingTimeInterval:24*60*60*6];
    NSString *finalMondayStr = [self sc_stringWithDate:finalMonday format:@"yyyy.MM.dd"];
    NSString *finalWeendayStr = [self sc_stringWithDate:finalWeenday format:@"yyyy.MM.dd"];
    if ([finalMonday timeIntervalSinceDate:[self sc_dateWithString:@"2018.11.18" format:@"yyyy.MM.dd"]] < 0) {
        finalMondayStr = @"2018.11.18";
    }
    return [NSString stringWithFormat:@"%@-%@", finalMondayStr, finalWeendayStr];
}

/** 根据传入的date，返回星期 */
+(NSString *)getWeekDayWithDate:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comp = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday  fromDate:date];
    // 获取今天是周几
    NSInteger weekDay = [comp weekday];
    if (weekDay == 1) {
        return @"星期日";
    } else if (weekDay == 2) {
        return @"星期一";
    } else if (weekDay == 3) {
        return @"星期二";
    } else if (weekDay == 4) {
        return @"星期三";
    } else if (weekDay == 5) {
        return @"星期四";
    } else if (weekDay == 6) {
        return @"星期五";
    } else if (weekDay == 7) {
        return @"星期六";
    } else {
        return @"星期一";
    }
}

/**
 @brief 根据传入的最早时间，返回至今为止的星期的数组
 
 @param formatStr 时间格式
 @param minDate 最早时间
 @param separateStr 周一和周末之间的连接符
 @return 从最早时间至今的星期的数组
 */
+ (NSArray *)getWeekDateArrayWithformatterString:(NSString *)formatStr minDate:(NSDate *)minDate separateStr:(NSString *)separateStr {
    NSTimeInterval timeInterval = [[self getCurrentMondayDate] timeIntervalSinceDate:minDate];
    NSInteger weekCount;
    if (timeInterval < 0) {
        weekCount = 1;
    } else {
        weekCount = (timeInterval-24*60*60)/(7*24*60*60) + 1 + 1;
    }
    NSMutableArray *weekArray = [NSMutableArray arrayWithCapacity:3];
    NSDate *monday = [self getCurrentMondayDate];
    for (NSInteger i = 0; i < weekCount; i++) {
        NSDate *finalMonday = [monday dateByAddingTimeInterval:-24*60*60*7*i];
        NSDate *finalWeenday = [finalMonday dateByAddingTimeInterval:24*60*60*6];
        if (i == 0) {
            finalWeenday = [NSDate date];
        }
        if (i == weekCount-1) {
            finalMonday = minDate;
        }
        NSString *finalMondayStr = [self sc_stringWithDate:finalMonday format:formatStr];
        NSString *finalWeendayStr = [self sc_stringWithDate:finalWeenday format:formatStr];
        [weekArray addObject:[NSString stringWithFormat:@"%@%@%@", finalMondayStr, separateStr, finalWeendayStr]];
    }
    return [weekArray  copy];
}
///判断是否在两个时间之间
+ (BOOL)inTimeQuantumFromDate:(NSString *)fromdate toDate:(NSString *)toDate {
    //获取当前时间
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormat = [self dateFormatter];
    //设置地区为当前地区
    [dateFormat setLocale:[NSLocale currentLocale]];
    //获取当前时区
    NSTimeZone *toTimeZone = [NSTimeZone localTimeZone];
    //获取当前时区的时间与GMT0时区相差的毫秒数
    NSInteger toGMTOffset = [toTimeZone secondsFromGMTForDate:[NSDate date]];
    //设置时区 (注: 要用相差的时间来设置, 不能直接设置上海或北京时区, 虽然都是+8时区; 不然会有夏令时的问题, 如1989-04-16转换会失败为nil, 因为这一天没有0时到1时)
    [dateFormat setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:toGMTOffset]];
    // 时间格式,建议大写    HH 使用 24 小时制；hh 12小时制
    [dateFormat setDateFormat:@"HH:mm:ss"];
    
    NSString * todayStr=[dateFormat stringFromDate:today];//将日期转换成字符串
    today=[ dateFormat dateFromString:todayStr];//转换成NSDate类型。日期置为方法默认日期
    // strar 格式 "5:30:00"  end: "19:13:14"
    NSDate *start = [dateFormat dateFromString:fromdate];
    NSDate *expire = [dateFormat dateFromString:toDate];
    
    if ([today compare:start] == NSOrderedDescending && [today compare:expire] == NSOrderedAscending) {
        return YES;
    }
    return NO;
}

//是本年
+ (BOOL)isThisYear:(NSString *)timeStampString {
    NSDateFormatter * df = [self dateFormatter];
    [df setDateFormat:@"yyyy.MM.dd HH:mm"];
    NSTimeInterval beTime    = [timeStampString doubleValue] / 1000.0;
    NSDate * beDate = [NSDate dateWithTimeIntervalSince1970:beTime];
    NSString *beStr = [df stringFromDate:beDate];
    NSString * nowStr = [df stringFromDate:[NSDate date]];
    NSString *beYear = [beStr substringToIndex:4];
    NSString *nowTear = [nowStr substringToIndex:4];
    return [beYear isEqualToString:nowTear];
}

+ (NSString *)myJourneyOrderDateString:(NSString *)timeStampString type:(NSInteger)orderType {
    // iOS 生成的时间戳是10位
    NSTimeInterval beTime    = [timeStampString doubleValue] / 1000.0;
    NSTimeInterval now = [[NSDate date]timeIntervalSince1970];
    double distanceTime = now - beTime;
    NSString * distanceStr;
    
    NSDate * beDate = [NSDate dateWithTimeIntervalSince1970:beTime];
    NSDateFormatter * df = [self dateFormatter];
    [df setDateFormat:@"HH:mm"];
    NSString * timeStr = [df stringFromDate:beDate];
    
    [df setDateFormat:@"dd"];
    NSString * nowDay = [df stringFromDate:[NSDate date]];
    NSString * lastDay = [df stringFromDate:beDate];
    
    if (distanceTime <24*60*60 && [nowDay integerValue] == [lastDay integerValue]) {//时间小于一天
        distanceStr = [NSString stringWithFormat:@"今天 %@",timeStr];
    } else if (distanceTime<24*60*60*2 && [nowDay integerValue] != [lastDay integerValue]) {
        //orderType 2 预约单 规则日期显示 今天：今天 HH:mm  非今天：YY:MM:DD HH:mm:ss
        if (orderType != 2) {
            if ([nowDay integerValue] - [lastDay integerValue] ==1 || ([lastDay integerValue] - [nowDay integerValue] > 10 && [nowDay integerValue] == 1)) {
                distanceStr = [NSString stringWithFormat:@"昨天 %@",timeStr];
            } else {
                [df setDateFormat:@"yyyy.MM.dd HH:mm"];
                distanceStr = [df stringFromDate:beDate];
            }
        } else {
            [df setDateFormat:@"yyyy.MM.dd HH:mm"];
            distanceStr = [df stringFromDate:beDate];
        }
        
    } else if ([self isThisYear:timeStampString]) {
        [df setDateFormat:@"yyyy.MM.dd HH:mm"];
        distanceStr = [df stringFromDate:beDate];
    } else {
        [df setDateFormat:@"yyyy.MM.dd HH:mm"];
        distanceStr = [df stringFromDate:beDate];
    }
    return distanceStr;
}

+ (double)calculateTimeIntervalWithBeginTime:(NSString *)beginTime nowTime:(NSString *)nowTime {
    NSDateFormatter *formatter = [self dateFormatter];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy-MM-dd-HH:MM:ss"];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[beginTime doubleValue]/1000];
    NSDate *date2 = [NSDate dateWithTimeIntervalSince1970:[nowTime doubleValue]/1000];
    NSTimeInterval seconds = [date2 timeIntervalSinceDate:date];
    return seconds;
}

+ (double)timeIntervalWithBeginTime:(double)beginTime nowTime:(double)nowTime {
    NSDateFormatter *formatter = [self dateFormatter];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy-MM-dd-HH:MM:ss"];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:beginTime/1000];
    NSDate *date2 = [NSDate dateWithTimeIntervalSince1970:nowTime/1000];
    NSTimeInterval seconds = [date2 timeIntervalSinceDate:date];
    return seconds;
}

+ (NSString *)achieveDayFormatByTimeString:(NSString *)timeString{
    if (!timeString || timeString.length < 10) {
        return @"";
    }
    //将时间戳转为NSDate类
    NSTimeInterval time = [[timeString substringToIndex:10] doubleValue];
    NSDate *inputDate=[NSDate dateWithTimeIntervalSince1970:time];
    //
    NSString *lastTime = [self compareDate:inputDate];
    return lastTime;
}

+ (NSString *)compareDate:(NSDate* )inputDate {
    //修正8小时的差时
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger goalInterval = [zone secondsFromGMTForDate: inputDate];
    NSDate *date = [inputDate  dateByAddingTimeInterval: goalInterval];
    
    //获取当前时间
    NSDate *currentDate = [NSDate date];
    NSInteger localInterval = [zone secondsFromGMTForDate: currentDate];
    NSDate *localeDate = [currentDate  dateByAddingTimeInterval: localInterval];
    
    //今天／昨天／明天
    NSTimeInterval secondsPerDay  = 24 * 60 * 60;
    
    NSDate *today = localeDate;
    NSDate *yesterday = [today dateByAddingTimeInterval: -secondsPerDay];
    NSDate *tomorrowday = [today dateByAddingTimeInterval: secondsPerDay];
    
    NSString *todayString = [[today description] substringToIndex:10];
    NSString *yesterdayString = [[yesterday description] substringToIndex:10];
    NSString *tomorrowdayString = [[tomorrowday description] substringToIndex:10];
    
    //今年
    NSString *toYears = [[today description] substringToIndex:4];
    
    //目标时间拆分为 年／月
    NSString *dateString = [[date description] substringToIndex:10];
    NSString *dateYears = [[date description] substringToIndex:4];
    
    NSString *dateContent;
    if ([dateYears isEqualToString:toYears]) {//同一年
        //今 昨 明天的时间
        NSString *time = [[date description] substringWithRange:(NSRange){11,5}];
        //其他时间
        NSString *time2 = [[date description] substringWithRange:(NSRange){5,11}];
        if ([dateString isEqualToString:todayString]) {
            //今天
            dateContent = [NSString stringWithFormat:@"今天 %@",time];
            return dateContent;
        }
        else if ([dateString isEqualToString:yesterdayString]) {
            //昨天
            dateContent = [NSString stringWithFormat:@"昨天 %@",time];
            return dateContent;
        } else if ([dateString isEqualToString:tomorrowdayString]) {
            //明天
            dateContent = [NSString stringWithFormat:@"明天 %@",time];
            return dateContent;
        }
        else {
//            if ([self compareDateFromeWorkTimeToNow:time2]) {
//                //一周之内，显示星期几
//                return [[self class]weekdayStringFromDate:inputDate];
//            } else {
                //一周之外，显示“月-日 时：分” ，如：05-23 06:22
                return time2;
//            }
        }
    } else {
        //不同年，显示具体日期：如，2008-11-11
        return dateString;
    }
}

//比较在一周之内还是之外
+ (BOOL)compareDateFromeWorkTimeToNow:(NSString *)timeStr
{
    //获得当前时间并转为字符串 2017-07-16 07:54:36 +0000(NSDate类)
    NSString *timeString = [self sc_stringWithDate:[NSDate date] format:@"yyyy-MM-dd HH:mm:ss"];
    timeString = [timeString substringFromIndex:5];
    
    int today = [timeString substringWithRange:(NSRange){3,2}].intValue;
    int workTime = [timeStr substringWithRange:(NSRange){3,2}].intValue;
    if ([[timeStr substringToIndex:2] isEqualToString:[timeString substringToIndex:2]]) {
        if (today - workTime <= 6) {
            return YES;
        } else {
            return NO;
        }
    } else {
        return NO;
    }
}

//返回星期几
+ (NSString*)weekdayStringFromDate:(NSDate*)inputDate {
    
    NSArray *weekdays = [NSArray arrayWithObjects: [NSNull null], @"星期日", @"星期一", @"星期二", @"星期三", @"星期四", @"星期五", @"星期六", nil];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSCalendarUnit calendarUnit = NSCalendarUnitWeekday;
    NSDateComponents *theComponents = [calendar components:calendarUnit fromDate:inputDate];
    return [weekdays objectAtIndex:theComponents.weekday];
}

//转化为年月日
+ (NSString *)dateToYearMonth:(NSString *)inputDateString{
   
    if (!inputDateString || inputDateString.length < 10) {
        return @"";
    }
    //将时间戳转为NSDate类
    NSTimeInterval time = [[inputDateString substringToIndex:10] doubleValue];
    NSDate *inputDate=[NSDate dateWithTimeIntervalSince1970:time];

    
    //修正8小时的差时
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger goalInterval = [zone secondsFromGMTForDate: inputDate];
    NSDate *date = [inputDate  dateByAddingTimeInterval: goalInterval];
    
    //获取当前时间
    NSDate *currentDate = [NSDate date];
    NSInteger localInterval = [zone secondsFromGMTForDate: currentDate];
    NSDate *localeDate = [currentDate  dateByAddingTimeInterval: localInterval];
    //今年
    NSString *toYears = [[localeDate description] substringToIndex:4];
    //目标时间拆分为 年
    NSString *dateYears = [[date description] substringToIndex:4];
    
    NSDateFormatter *outputFormatter = [self dateFormatter];
    [outputFormatter setLocale:[NSLocale currentLocale]];

    if ([dateYears isEqualToString:toYears]) {//同一年
        [outputFormatter setDateFormat:@"MM月dd日 HH:mm"];
    
    } else {
        [outputFormatter setDateFormat:@"yyyy/MM/dd HH:mm"];
    
    }
    return  [outputFormatter stringFromDate:inputDate];
}

@end
