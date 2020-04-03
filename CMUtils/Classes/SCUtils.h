//
//  SCUtils.h
//  SaicUtilsDemo
//
//  Created by saic on 2018/9/6.
//  Copyright © 2018年 saic. All rights reserved.
//

#ifndef SCUtils_h
#define SCUtils_h

#import "SCConstant.h"

// 方法拦截
#import "SCHook.h"

// 日期处理
#import "SCDateUtil.h"

// 系统/App信息获取
#import "SCSystemInfoUtil.h"

// json处理
#import "SCJsonHelper.h"

// 异常解析
#import "NSException+Trace.h"

// 数值处理
#import "NSDecimalNumber+Arithmetic.h"

// 字符串处理
#import "NSString+Emoji.h"
#import "NSString+SCExt.h"


// 事件传递
#import "UIResponder+RouterEvent.h"

// 数据加密(字符串和data)
#import "NSData+Encrypt.h"
#import "SCEncryption.h"

// 文件处理
#import "SCFileUtil.h"
#import "SCKeyChainStore.h"
#import "SCUserDefaultsTool.h"

// 定时器timer处理
#import "SCTimerUtil.h"

// 隐私权限设置
#import "SCPrivacyUtil.h"

#endif /* SCUtils_h */
