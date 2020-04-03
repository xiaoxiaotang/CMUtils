//
//  GHook.h
//  GHook
//
//  Created by sdg on 2018/4/15.
//  Copyright © 2018年 sdg. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_OPTIONS(NSUInteger, SCHookOptions) {
    SCHookPositionAfter   = 0,
    SCHookPositionInstead = 1,
    SCHookPositionBefore  = 2,
    SCHookOptionAutomaticRemoval = 1 << 3
};

@protocol SCHookToken <NSObject>
- (BOOL)remove;
@end

@protocol SCHookInfo <NSObject>
- (id)instance;
- (NSInvocation *)originalInvocation;
- (NSArray *)arguments;
@end

typedef void(^SCHookBlock)(id<SCHookInfo>);

@interface NSObject (SCHook)
+ (id<SCHookToken>)SCHook_selector:(SEL)selector
                           withOptions:(SCHookOptions)options
                            usingBlock:(SCHookBlock)block
                                 error:(NSError **)error;
- (id<SCHookToken>)SCHook_selector:(SEL)selector
                           withOptions:(SCHookOptions)options
                            usingBlock:(SCHookBlock)block
                                 error:(NSError **)error;

@end

typedef NS_ENUM(NSUInteger, SCHookErrorCode) {
    SCHookErrorSelectorBlacklisted,
    SCHookErrorDoesNotRespondToSelector,
    SCHookErrorSelectorDeallocPosition,
    SCHookErrorSelectorAlreadyHookedInClassHierarchy,
    SCHookErrorFailedToAllocateClassPair,
    SCHookErrorMissingBlockSignature,
    SCHookErrorIncompatibleBlockSignature,
    SCHookErrorRemoveObjectAlreadyDeallocated = 100
};

extern NSString *const SCHookErrorDomain;
