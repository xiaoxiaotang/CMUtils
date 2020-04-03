//
//  UIResponder+RouterEvent.m
//  SaicCarPlatform
//
//  Created by 杨艳东 on 2018/4/29.
//  Copyright © 2018年 Saic. All rights reserved.
//

#import "UIResponder+RouterEvent.h"

@implementation UIResponder (RouterEvent)

-(void)sc_routerEventWithName:(NSString *)eventName userInfo:(NSDictionary *)userInfo {
    [[self nextResponder] sc_routerEventWithName:eventName userInfo:userInfo];
}

@end
