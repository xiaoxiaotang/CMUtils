//
//  UIResponder+RouterEvent.m
//  CMUtils
//
//  Created by 小站 on 2020/4/8.
//

#import "UIResponder+RouterEvent.h"

@implementation UIResponder (RouterEvent)

-(void)zx_routerEventWithName:(NSString *)eventName userInfo:(NSDictionary *)userInfo {
    [[self nextResponder] zx_routerEventWithName:eventName userInfo:userInfo];
}

@end
