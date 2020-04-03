//
//  NSObject+equal.h
//  SaicUtilsDemo
//
//  Created by v-zengdongmei on 2019/4/10.
//  Copyright © 2019 saic. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (equal)

- (BOOL)saic_isEqualToObject: (id)object inProperty: (NSString *)property;

@end

NS_ASSUME_NONNULL_END
