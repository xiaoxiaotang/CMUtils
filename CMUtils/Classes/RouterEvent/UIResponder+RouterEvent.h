//
//  UIResponder+RouterEvent.h
//  CMUtils
//
//  Created by 小站 on 2020/4/8.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIResponder (RouterEvent)

/**
 @brief 借用responder chain传递事件
 @param eventName  事件名称
 @param userInfo   参数信息
 */
- (void)zx_routerEventWithName:(NSString *)eventName userInfo:(NSDictionary *)userInfo;

@end

NS_ASSUME_NONNULL_END
