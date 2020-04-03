//
//  UIResponder+RouterEvent.h
//  SaicCarPlatform
//
//  Created by 杨艳东 on 2018/4/29.
//  Copyright © 2018年 Saic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIResponder (RouterEvent)
/**
 @brief 借用responder chain传递事件
 @param eventName  事件名称
 @param userInfo   参数信息
 */
- (void)sc_routerEventWithName:(NSString *)eventName userInfo:(NSDictionary *)userInfo;

@end
