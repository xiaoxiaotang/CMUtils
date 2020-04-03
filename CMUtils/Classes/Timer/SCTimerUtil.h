//
//  SCTimerUtil.h
//  SaicCarPlatform
//
//  Created by Wicrenet_Jason on 2018/5/9.
//  Copyright © 2018年 Saic. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SCTimerUtil : NSObject

/**
 开启定时器

 @param timerName 定时器唯一标示名称
 @param interval 定时器时间间隔
 @param isDelay 是否延迟执行
 @param repeats 是否重复
 @param action 定时器定时回调
 */
+(void)sc_scheduledDispatchTimerWithName:(nonnull NSString *)timerName
                            timeInterval:(double)interval
                                 isDelay:(BOOL)isDelay
                                 repeats:(BOOL)repeats
                                  action:(dispatch_block_t)action;

+ (void)sc_cancelTimerAll;
/**
 取消定时器

 @param timerName 定时器唯一标示名称
 */
+(void)sc_cancelTimerWithName:(nonnull NSString *)timerName;


/**
 开始倒计时

 @param timeInterval 倒计时时长 默认间隔1s
 @param intervalHandler 倒计时定时回调
 @param completedHandler 倒计时完成回调

 @note 倒计时默认间隔1s
 */
+ (void)sc_startCountDown:(NSInteger)timeInterval
          intervalHandler:(void (^)(NSInteger currentInterval))intervalHandler
         completedHandler:(void (^)(void))completedHandler;

@end

NS_ASSUME_NONNULL_END
