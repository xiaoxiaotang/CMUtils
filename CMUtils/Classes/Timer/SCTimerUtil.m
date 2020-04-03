//
//  SCTimerUtil.m
//  SaicCarPlatform
//
//  Created by Wicrenet_Jason on 2018/5/9.
//  Copyright © 2018年 Saic. All rights reserved.
//

#import "SCTimerUtil.h"

static NSMutableDictionary *gcdTimerContainer=nil;

@implementation SCTimerUtil

//timerName: 名称标识
//interval: 时间
//isDelay: 是否延时/如果不延后就直接执行
//repeats: 重复执行

+(void)sc_scheduledDispatchTimerWithName:(nonnull NSString *)timerName timeInterval:(double)interval isDelay:(BOOL)isDelay repeats:(BOOL)repeats action:(dispatch_block_t)action {
    if (!gcdTimerContainer) {
        gcdTimerContainer=[NSMutableDictionary dictionary];
    }
    if (nil == timerName) {
        return;
    }
    [self sc_cancelTimerWithName:timerName];

    // 延后
    if (!isDelay) {
        // 首先执行一次
        action();
    }


    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_resume(timer);
    [gcdTimerContainer setObject:timer forKey:timerName];
    dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, interval*NSEC_PER_SEC), interval*NSEC_PER_SEC, 0.1*NSEC_PER_SEC);
    __weak typeof (self) weakSelf = self;
    dispatch_source_set_event_handler(timer, ^{
        if (!repeats) {
            [weakSelf sc_cancelTimerWithName:timerName];
        }
        if (action) {
            action();
        }
    });
}

+ (void)sc_cancelTimerAll {
    NSArray *array = gcdTimerContainer.allKeys;
    for (NSString *str in array) {
        [SCTimerUtil sc_cancelTimerWithName:str];
    }
}

+(void)sc_cancelTimerWithName:(nonnull NSString *)timerName {
    if (nil == timerName) {
        return;
    }
    dispatch_source_t timer = [gcdTimerContainer objectForKey:timerName];
    if (!timer) {
        return;
    }
    [gcdTimerContainer removeObjectForKey:timerName];
    NSLog(@"timeoutRetry cancel timer : %@ gcdTimerContainer : %@",timerName,gcdTimerContainer);
    dispatch_source_cancel(timer);
}

+ (void)sc_startCountDown:(NSInteger)timeInterval
       intervalHandler:(void (^)(NSInteger currentInterval))intervalHandler
      completedHandler:(void (^)(void))completedHandler {
    __block NSInteger timeInterval_blcok = timeInterval;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0), 1.0*NSEC_PER_SEC, 0);  //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        if(timeInterval_blcok <=0) {
            //倒计时结束，关闭
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                // 主线程
                completedHandler();
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                // 主线程
                intervalHandler(timeInterval_blcok);
            });
            timeInterval_blcok --;
        }
    });
    dispatch_resume(_timer);
}
@end
