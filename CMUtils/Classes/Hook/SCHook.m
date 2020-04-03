//
//  SCHook.m
//  SCHook
//
//  Created by sdg on 2018/4/15.
//  Copyright © 2018年 sdg. All rights reserved.
//

#import "SCHook.h"
#import <libkern/OSAtomic.h>
#import <objc/runtime.h>
#import <objc/message.h>

typedef NS_OPTIONS(int, SCHookBlockFlags) {
    SCHookBlockFlagsHasCopyDisposeHelpers = (1 << 25),
    SCHookBlockFlagsHasSignature          = (1 << 30)
};
typedef struct _SCHookBlock {
    __unused Class isa;
    SCHookBlockFlags flags;
    __unused int reserved;
    void (__unused *invoke)(struct _SCHookBlock *block, ...);
    struct {
        unsigned long int reserved;
        unsigned long int size;
        void (*copy)(void *dst, const void *src);
        void (*dispose)(const void *);
        const char *signature;
        const char *layout;
    } *descriptor;
} *SCHookBlockRef;

@interface SCHookInfo : NSObject <SCHookInfo>
- (id)initWithInstance:(__unsafe_unretained id)instance invocation:(NSInvocation *)invocation;
@property (nonatomic, unsafe_unretained, readonly) id instance;
@property (nonatomic, strong, readonly) NSArray *arguments;
@property (nonatomic, strong, readonly) NSInvocation *originalInvocation;
@end

@interface SCHookIdentifier : NSObject<SCHookToken>
+ (instancetype)identifierWithSelector:(SEL)selector object:(id)object options:(SCHookOptions)options block:(SCHookBlock)block error:(NSError **)error;
- (BOOL)invokeWithInfo:(id<SCHookInfo>)info;
@property (nonatomic, assign) SEL selector;
@property (nonatomic, strong) SCHookBlock block;
@property (nonatomic, strong) NSMethodSignature *blockSignature;
@property (nonatomic, weak) id object;
@property (nonatomic, assign) SCHookOptions options;
@end

@interface SCHookContainer : NSObject
- (void)addHook:(SCHookIdentifier *)hook withOptions:(SCHookOptions)options;
- (BOOL)removeHook:(SCHookIdentifier *)hook;
- (BOOL)hasHooks;
@property (atomic, copy) NSArray<SCHookIdentifier *> *beforeHooks;
@property (atomic, copy) NSArray<SCHookIdentifier *> *insteadHooks;
@property (atomic, copy) NSArray<SCHookIdentifier *> *afterHooks;
@end

@interface SCHookTracker : NSObject
- (id)initWithTrackedClass:(Class)trackedClass;
@property (nonatomic, strong) Class trackedClass;
@property (nonatomic, readonly) NSString *trackedClassName;
@property (nonatomic, strong) NSMutableSet *selectorNames;
@property (nonatomic, strong) NSMutableDictionary *selectorNamesToSubclassTrackers;
- (void)addSubclassTracker:(SCHookTracker *)subclassTracker hookingSelectorName:(NSString *)selectorName;
- (void)removeSubclassTracker:(SCHookTracker *)subclassTracker hookingSelectorName:(NSString *)selectorName;
- (BOOL)subclassHasHookedSelectorName:(NSString *)selectorName;
- (NSSet *)subclassTrackersHookingSelectorName:(NSString *)selectorName;
@end

@interface NSInvocation (SCHook)
- (NSArray *)SCHook_arguments;
@end

#define SCHookPositionFilter 0x07

NSString *const SCHookErrorDomain = @"SCHookErrorDomain";
static NSString *const SCHookSubclassSuffix = @"_SCHook_";
static NSString *const SCHookMessagePrefix = @"SCHook_";

@interface SCHookHelper: NSObject

@end

@implementation SCHookHelper

+ (SCHookIdentifier *)addWithObject:(id)object selector:(SEL)selector options:(SCHookOptions)options block:(SCHookBlock)block error:(NSError * __autoreleasing *)error {
    NSCParameterAssert(object);
    NSCParameterAssert(selector);
    NSCParameterAssert(block);
    
    __block SCHookIdentifier *identifier = nil;
    [self performLockedWithBlock:^{
        if ([self isSelectorAllowedAndTrackWithObject:object selector:selector options:options error:error]) {
            SCHookContainer *container = [self getContainerForObject:object selector:selector];
            identifier = [SCHookIdentifier identifierWithSelector:selector object:object options:options block:block error:error];
            if (identifier) {
                [container addHook:identifier withOptions:options];
                
                [self prepareClassAndHookSelectorWithObject:object selector:selector error:error];
            }
        }
    }];
    return identifier;
}

+ (BOOL)removeIdentifier:(SCHookIdentifier *)identifier error:(NSError * __autoreleasing *)error {
    NSCAssert([identifier isKindOfClass:SCHookIdentifier.class], @"Must have correct type.");
    
    __block BOOL success = NO;
    [self performLockedWithBlock:^{
        id object = identifier.object;
        if (object) {
            SCHookContainer *container = [self getContainerForObject:object selector:identifier.selector];
            success = [container removeHook:identifier];
            
            [self cleanupHookedClassAndSelectorWithObject:object selector:identifier.selector];
            identifier.object = nil;
            identifier.block = nil;
            identifier.selector = NULL;
        }else {
            NSString *errrorDesc = [NSString stringWithFormat:@"Unable to deregister hook. Object already deallocated: %@", identifier];
            *error = [NSError errorWithDomain:SCHookErrorDomain code:SCHookErrorRemoveObjectAlreadyDeallocated userInfo:@{NSLocalizedDescriptionKey:errrorDesc}];
        }
    }];
    return success;
}

+ (void)performLockedWithBlock:(dispatch_block_t)block {
    static NSLock *hook_lock;
    if (!hook_lock) hook_lock = [NSLock new];
    [hook_lock lock];
    block();
    [hook_lock unlock];
}

+ (SEL)aliasForSelector:(SEL)selector {
    NSCParameterAssert(selector);
    return NSSelectorFromString([SCHookMessagePrefix stringByAppendingFormat:@"_%@", NSStringFromSelector(selector)]);
}

+ (NSMethodSignature *)blockMethodSignatureWithBlock:(SCHookBlock)block error:(NSError **)error {
    SCHookBlockRef layout = (__bridge void *)block;
    if (!(layout->flags & SCHookBlockFlagsHasSignature)) {
        NSString *description = [NSString stringWithFormat:@"The block %@ doesn't contain a type signature.", block];
        *error = [NSError errorWithDomain:SCHookErrorDomain code:SCHookErrorMissingBlockSignature userInfo:@{NSLocalizedDescriptionKey:description}];
        return nil;
    }
    void *desc = layout->descriptor;
    desc += 2 * sizeof(unsigned long int);
    if (layout->flags & SCHookBlockFlagsHasCopyDisposeHelpers) {
        desc += 2 * sizeof(void *);
    }
    if (!desc) {
        NSString *description = [NSString stringWithFormat:@"The block %@ doesn't has a type signature.", block];
        *error = [NSError errorWithDomain:SCHookErrorDomain code:SCHookErrorMissingBlockSignature userInfo:@{NSLocalizedDescriptionKey:description}];
        return nil;
    }
    const char *signature = (*(const char **)desc);
    return [NSMethodSignature signatureWithObjCTypes:signature];
}

+ (BOOL)isCompatibleBlockSignature:(NSMethodSignature *)blockSignature object:(id)object selector:(SEL)selector error:(NSError **)error {
    NSCParameterAssert(blockSignature);
    NSCParameterAssert(object);
    NSCParameterAssert(selector);
    
    BOOL signaturesMatch = YES;
    NSMethodSignature *methodSignature = [[object class] instanceMethodSignatureForSelector:selector];
    if (blockSignature.numberOfArguments > methodSignature.numberOfArguments) {
        signaturesMatch = NO;
    }else {
        if (blockSignature.numberOfArguments > 1) {
            const char *blockType = [blockSignature getArgumentTypeAtIndex:1];
            if (blockType[0] != '@') {
                signaturesMatch = NO;
            }
        }
        if (signaturesMatch) {
            for (NSUInteger idx = 2; idx < blockSignature.numberOfArguments; idx++) {
                const char *methodType = [methodSignature getArgumentTypeAtIndex:idx];
                const char *blockType = [blockSignature getArgumentTypeAtIndex:idx];
                if (!methodType || !blockType || methodType[0] != blockType[0]) {
                    signaturesMatch = NO; break;
                }
            }
        }
    }
    
    if (!signaturesMatch) {
        NSString *description = [NSString stringWithFormat:@"Block signature %@ doesn't match %@.", blockSignature, methodSignature];
        *error = [NSError errorWithDomain:SCHookErrorDomain code:SCHookErrorIncompatibleBlockSignature userInfo:@{NSLocalizedDescriptionKey:description}];
        return NO;
    }
    return YES;
}

+ (BOOL)isMsgForwardIMP:(IMP)impl {
    return impl == _objc_msgForward
#if !defined(__arm64__)
    || impl == (IMP)_objc_msgForward_stret
#endif
    ;
}

+ (IMP)getMsgForwardIMPWithObject:(id)object selector:(SEL)selector {
    IMP msgForwardIMP = _objc_msgForward;
#if !defined(__arm64__)
    Method method = class_getInstanceMethod([object class], selector);
    const char *encoding = method_getTypeEncoding(method);
    BOOL methodReturnsStructValue = encoding[0] == _C_STRUCT_B;
    if (methodReturnsStructValue) {
        @try {
            NSUInteger valueSize = 0;
            NSGetSizeAndAlignment(encoding, &valueSize, NULL);
            
            if (valueSize == 1 || valueSize == 2 || valueSize == 4 || valueSize == 8) {
                methodReturnsStructValue = NO;
            }
        } @catch (__unused NSException *e) {}
    }
    if (methodReturnsStructValue) {
        msgForwardIMP = (IMP)_objc_msgForward_stret;
    }
#endif
    return msgForwardIMP;
}

+ (void)prepareClassAndHookSelectorWithObject:(id)object selector:(SEL)selector error:(NSError **)error {
    NSCParameterAssert(selector);
    Class klass = [self hookClassWithObject:object error:error];
    Method targetMethod = class_getInstanceMethod(klass, selector);
    IMP targetMethodIMP = method_getImplementation(targetMethod);
    if (![self isMsgForwardIMP:targetMethodIMP]) {
        const char *typeEncoding = method_getTypeEncoding(targetMethod);
        SEL aliasSelector = [self aliasForSelector:selector];
        if (![klass instancesRespondToSelector:aliasSelector]) {
            __unused BOOL addedAlias = class_addMethod(klass, aliasSelector, method_getImplementation(targetMethod), typeEncoding);
            NSCAssert(addedAlias, @"Original implementation for %@ is already copied to %@ on %@", NSStringFromSelector(selector), NSStringFromSelector(aliasSelector), klass);
        }
        
        class_replaceMethod(klass, selector, [self getMsgForwardIMPWithObject:object selector:selector], typeEncoding);
        NSLog(@"SCHook: Installed hook for -[%@ %@].", klass, NSStringFromSelector(selector));
    }
}

+ (void)cleanupHookedClassAndSelectorWithObject:(id)object selector:(SEL)selector {
    NSCParameterAssert(object);
    NSCParameterAssert(selector);
    
    Class klass = object_getClass(object);
    BOOL isMetaClass = class_isMetaClass(klass);
    if (isMetaClass) {
        klass = (Class)object;
    }
    
    Method targetMethod = class_getInstanceMethod(klass, selector);
    IMP targetMethodIMP = method_getImplementation(targetMethod);
    if ([self isMsgForwardIMP:targetMethodIMP]) {
        const char *typeEncoding = method_getTypeEncoding(targetMethod);
        SEL aliasSelector = [self aliasForSelector:selector];
        Method originalMethod = class_getInstanceMethod(klass, aliasSelector);
        IMP originalIMP = method_getImplementation(originalMethod);
        NSCAssert(originalMethod, @"Original implementation for %@ not found %@ on %@", NSStringFromSelector(selector), NSStringFromSelector(aliasSelector), klass);
        
        class_replaceMethod(klass, selector, originalIMP, typeEncoding);
        NSLog(@"SCHook: Removed hook for -[%@ %@].", klass, NSStringFromSelector(selector));
    }
    
    [self deregisterTrackedSelectorWithObject:object selector:selector];
    
    SCHookContainer *container = [self getContainerForObject:object selector:selector];
    if (!container.hasHooks) {
        [self destroyContainerForObject:object selector:selector];
        
        NSString *className = NSStringFromClass(klass);
        if ([className hasSuffix:SCHookSubclassSuffix]) {
            Class originalClass = NSClassFromString([className stringByReplacingOccurrencesOfString:SCHookSubclassSuffix withString:@""]);
            NSCAssert(originalClass != nil, @"Original class must exist");
            object_setClass(object, originalClass);
            NSLog(@"SCHook: %@ has been restored.", NSStringFromClass(originalClass));
            
        }else {
            if (isMetaClass) {
                [self undoSwizzleClassInPlaceWithClass:(Class)object];
            }else if ([object class] != klass) {
                [self undoSwizzleClassInPlaceWithClass:klass];
            }
        }
    }
}

+ (Class)hookClassWithObject:(id)object error:(NSError **)error {
    NSCParameterAssert(object);
    Class statedClass = [object class];
    Class baseClass = object_getClass(object);
    NSString *className = NSStringFromClass(baseClass);
    
    if ([className hasSuffix:SCHookSubclassSuffix]) {
        return baseClass;
        
    }else if (class_isMetaClass(baseClass)) {
        return [self swizzleClassInPlaceWithClass:(Class)object];
    }else if (statedClass != baseClass) {
        return [self swizzleClassInPlaceWithClass:baseClass];
    }
    
    const char *subclassName = [className stringByAppendingString:SCHookSubclassSuffix].UTF8String;
    Class subclass = objc_getClass(subclassName);
    
    if (subclass == nil) {
        subclass = objc_allocateClassPair(baseClass, subclassName, 0);
        if (subclass == nil) {
            NSString *errrorDesc = [NSString stringWithFormat:@"objc_allocateClassPair failed to allocate class %s.", subclassName];
            *error = [NSError errorWithDomain:SCHookErrorDomain code:SCHookErrorFailedToAllocateClassPair userInfo:@{NSLocalizedDescriptionKey:errrorDesc}];
            return nil;
        }
        
        [self swizzleForwardInvocationWithClass:subclass];
        [self hookedGetClass:subclass statedClass:statedClass];
        [self hookedGetClass:object_getClass(subclass) statedClass:statedClass];
        objc_registerClassPair(subclass);
    }
    
    object_setClass(object, subclass);
    return subclass;
}

static NSString *const SCHookForwardInvocationSelectorName = @"__SCHook_forwardInvocation:";
+ (void)swizzleForwardInvocationWithClass:(Class)klass {
    NSCParameterAssert(klass);
    IMP originalImplementation = class_replaceMethod(klass, @selector(forwardInvocation:), (IMP)__HOOK_ARE_BEING_CALLED__, "v@:@");
    if (originalImplementation) {
        class_addMethod(klass, NSSelectorFromString(SCHookForwardInvocationSelectorName), originalImplementation, "v@:@");
    }
    NSLog(@"SCHook: %@ is now hook aware.", NSStringFromClass(klass));
}

+ (void)undoSwizzleForwardInvocationWithClass:(Class)klass {
    NSCParameterAssert(klass);
    Method originalMethod = class_getInstanceMethod(klass, NSSelectorFromString(SCHookForwardInvocationSelectorName));
    Method objectMethod = class_getInstanceMethod(NSObject.class, @selector(forwardInvocation:));
    IMP originalImplementation = method_getImplementation(originalMethod ?: objectMethod);
    class_replaceMethod(klass, @selector(forwardInvocation:), originalImplementation, "v@:@");
    
    NSLog(@"SCHook: %@ has been restored.", NSStringFromClass(klass));
}

+ (void)hookedGetClass:(Class)klass statedClass:(Class)statedClass {
    NSCParameterAssert(klass);
    NSCParameterAssert(statedClass);
    Method method = class_getInstanceMethod(klass, @selector(class));
    IMP newIMP = imp_implementationWithBlock(^(id self) {
        return statedClass;
    });
    class_replaceMethod(klass, @selector(class), newIMP, method_getTypeEncoding(method));
}

+ (void)modifySwizzledClassesWithBlock:(void (^)(NSMutableSet *swizzledClasses))block {
    static NSMutableSet *swizzledClasses;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        swizzledClasses = [NSMutableSet new];
    });
    @synchronized(swizzledClasses) {
        block(swizzledClasses);
    }
}

+ (Class)swizzleClassInPlaceWithClass:(Class)klass {
    NSCParameterAssert(klass);
    NSString *className = NSStringFromClass(klass);
    
    [self modifySwizzledClassesWithBlock:^(NSMutableSet *swizzledClasses) {
        if (![swizzledClasses containsObject:className]) {
            [self swizzleForwardInvocationWithClass:klass];
            [swizzledClasses addObject:className];
        }
    }];
    return klass;
}

+ (void)undoSwizzleClassInPlaceWithClass:(Class)klass {
    NSCParameterAssert(klass);
    NSString *className = NSStringFromClass(klass);
    
    [self modifySwizzledClassesWithBlock:^(NSMutableSet *swizzledClasses) {
        if ([swizzledClasses containsObject:className]) {
            [self undoSwizzleForwardInvocationWithClass:klass];
            [swizzledClasses removeObject:className];
        }
    }];
}

+ (SCHookContainer *)getContainerForObject:(id)object selector:(SEL)selector {
    NSCParameterAssert(object);
    SEL aliasSelector = [self aliasForSelector:selector];
    SCHookContainer *container = objc_getAssociatedObject(object, aliasSelector);
    if (!container) {
        container = [SCHookContainer new];
        objc_setAssociatedObject(object, aliasSelector, container, OBJC_ASSOCIATION_RETAIN);
    }
    return container;
}

+ (SCHookContainer *)getContainerForClass:(Class)klass selector:(SEL)selector {
    NSCParameterAssert(klass);
    SCHookContainer *container = nil;
    do {
        container = objc_getAssociatedObject(klass, selector);
        if (container.hasHooks) break;
    }while ((klass = class_getSuperclass(klass)));
    
    return container;
}

+ (void)destroyContainerForObject:(id)object selector:(SEL)selector {
    NSCParameterAssert(self);
    SEL aliasSelector = [self aliasForSelector:selector];
    objc_setAssociatedObject(object, aliasSelector, nil, OBJC_ASSOCIATION_RETAIN);
}

+ (NSMutableDictionary *)getSwizzledClassesDict {
    static NSMutableDictionary *swizzledClassesDict;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        swizzledClassesDict = [NSMutableDictionary new];
    });
    return swizzledClassesDict;
}

+ (BOOL)isSelectorAllowedAndTrackWithObject:(id)object selector:(SEL)selector options:(SCHookOptions)options error:(NSError **)error {
    static NSSet *disallowedSelectorList;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        disallowedSelectorList = [NSSet setWithObjects:@"retain", @"release", @"autorelease", @"forwardInvocation:", nil];
    });
    
    NSString *selectorName = NSStringFromSelector(selector);
    if ([disallowedSelectorList containsObject:selectorName]) {
        NSString *errorDescription = [NSString stringWithFormat:@"Selector %@ is blacklisted.", selectorName];
        *error = [NSError errorWithDomain:SCHookErrorDomain code:SCHookErrorSelectorBlacklisted userInfo:@{NSLocalizedDescriptionKey:errorDescription}];
        return NO;
    }
    
    SCHookOptions position = options&SCHookPositionFilter;
    if ([selectorName isEqualToString:@"dealloc"] && position != SCHookPositionBefore) {
        NSString *errorDesc = @"SCHookPositionBefore is the only valid position when hooking dealloc.";
        *error = [NSError errorWithDomain:SCHookErrorDomain code:SCHookErrorSelectorDeallocPosition userInfo:@{NSLocalizedDescriptionKey:errorDesc}];
        return NO;
    }
    
    if (![object respondsToSelector:selector] && ![[object class] instancesRespondToSelector:selector]) {
        NSString *errorDesc = [NSString stringWithFormat:@"Unable to find selector -[%@ %@].", NSStringFromClass([object class]), selectorName];
        *error = [NSError errorWithDomain:SCHookErrorDomain code:SCHookErrorDoesNotRespondToSelector userInfo:@{NSLocalizedDescriptionKey:errorDesc}];
        return NO;
    }
    
    if (class_isMetaClass(object_getClass(object))) {
        Class klass = [object class];
        NSMutableDictionary *swizzledClassesDict = [self getSwizzledClassesDict];
        Class currentClass = [object class];
        
        SCHookTracker *tracker = swizzledClassesDict[currentClass];
        if ([tracker subclassHasHookedSelectorName:selectorName]) {
            NSSet *subclassTracker = [tracker subclassTrackersHookingSelectorName:selectorName];
            NSSet *subclassNames = [subclassTracker valueForKey:@"trackedClassName"];
            NSString *errorDescription = [NSString stringWithFormat:@"Error: %@ already hooked subclasses: %@. A method can only be hooked once per class hierarchy.", selectorName, subclassNames];
            *error = [NSError errorWithDomain:SCHookErrorDomain code:SCHookErrorSelectorAlreadyHookedInClassHierarchy userInfo:@{NSLocalizedDescriptionKey:errorDescription}];
            return NO;
        }
        
        do {
            tracker = swizzledClassesDict[currentClass];
            if ([tracker.selectorNames containsObject:selectorName]) {
                if (klass == currentClass) {
                    return YES;
                }
                NSString *errorDescription = [NSString stringWithFormat:@"Error: %@ already hooked in %@. A method can only be hooked once per class hierarchy.", selectorName, NSStringFromClass(currentClass)];
                *error = [NSError errorWithDomain:SCHookErrorDomain code:SCHookErrorSelectorAlreadyHookedInClassHierarchy userInfo:@{NSLocalizedDescriptionKey:errorDescription}];
                return NO;
            }
        } while ((currentClass = class_getSuperclass(currentClass)));
        
        currentClass = klass;
        SCHookTracker *subclassTracker = nil;
        do {
            tracker = swizzledClassesDict[currentClass];
            if (!tracker) {
                tracker = [[SCHookTracker alloc] initWithTrackedClass:currentClass];
                swizzledClassesDict[(id<NSCopying>)currentClass] = tracker;
            }
            if (subclassTracker) {
                [tracker addSubclassTracker:subclassTracker hookingSelectorName:selectorName];
            } else {
                [tracker.selectorNames addObject:selectorName];
            }
            
            subclassTracker = tracker;
        }while ((currentClass = class_getSuperclass(currentClass)));
    } else {
        return YES;
    }
    
    return YES;
}

+ (void)deregisterTrackedSelectorWithObject:(id)object selector:(SEL)selector {
    if (!class_isMetaClass(object_getClass(object))) return;
    
    NSMutableDictionary *swizzledClassesDict = [self getSwizzledClassesDict];
    NSString *selectorName = NSStringFromSelector(selector);
    Class currentClass = [object class];
    SCHookTracker *subclassTracker = nil;
    do {
        SCHookTracker *tracker = swizzledClassesDict[currentClass];
        if (subclassTracker) {
            [tracker removeSubclassTracker:subclassTracker hookingSelectorName:selectorName];
        } else {
            [tracker.selectorNames removeObject:selectorName];
        }
        if (tracker.selectorNames.count == 0 && tracker.selectorNamesToSubclassTrackers) {
            [swizzledClassesDict removeObjectForKey:currentClass];
        }
        subclassTracker = tracker;
    }while ((currentClass = class_getSuperclass(currentClass)));
}

static void __HOOK_ARE_BEING_CALLED__(__unsafe_unretained id object, SEL selector, NSInvocation *invocation) {
    NSCParameterAssert(object);
    NSCParameterAssert(invocation);
    SEL originalSelector = invocation.selector;
    SEL aliasSelector = [SCHookHelper aliasForSelector:invocation.selector];
    invocation.selector = aliasSelector;
    SCHookContainer *objectContainer = objc_getAssociatedObject(object, aliasSelector);
    SCHookContainer *classContainer = [SCHookHelper getContainerForClass:object_getClass(object) selector:aliasSelector];
    SCHookInfo *info = [[SCHookInfo alloc] initWithInstance:object invocation:invocation];
    __block NSArray *identifiersToRemove = nil;
    
    void (^hookInvoke)(NSArray<SCHookIdentifier *> *, SCHookInfo *) = ^(NSArray<SCHookIdentifier *> *ideitifiers, SCHookInfo *info){
        for (SCHookIdentifier *identifier in ideitifiers) {
            [identifier invokeWithInfo:info];
            if (identifier.options & SCHookOptionAutomaticRemoval) {
                identifiersToRemove = [identifiersToRemove?:@[] arrayByAddingObject:identifier];
            }
        }
    };
    
    hookInvoke(classContainer.beforeHooks, info);
    hookInvoke(objectContainer.beforeHooks, info);
    
    BOOL respondsToAlias = YES;
    if (objectContainer.insteadHooks.count || classContainer.insteadHooks.count) {
        hookInvoke(classContainer.insteadHooks, info);
        hookInvoke(objectContainer.insteadHooks, info);
    }else {
        Class klass = object_getClass(invocation.target);
        do {
            if ((respondsToAlias = [klass instancesRespondToSelector:aliasSelector])) {
                [invocation invoke];
                break;
            }
        }while (!respondsToAlias && (klass = class_getSuperclass(klass)));
    }
    
    hookInvoke(classContainer.afterHooks, info);
    hookInvoke(objectContainer.afterHooks, info);
    
    if (!respondsToAlias) {
        invocation.selector = originalSelector;
        SEL originalForwardInvocationSEL = NSSelectorFromString(SCHookForwardInvocationSelectorName);
        if ([object respondsToSelector:originalForwardInvocationSEL]) {
            ((void( *)(id, SEL, NSInvocation *))objc_msgSend)(object, originalForwardInvocationSEL, invocation);
        }else {
            [object doesNotRecognizeSelector:invocation.selector];
        }
    }
    
    [identifiersToRemove makeObjectsPerformSelector:@selector(remove)];
}

@end

@implementation NSObject(SCHook)

+ (id<SCHookToken>)SCHook_selector:(SEL)selector
                     withOptions:(SCHookOptions)options
                      usingBlock:(SCHookBlock)block
                           error:(NSError **)error {
    return [SCHookHelper addWithObject:self selector:selector options:options block:block error:error];
}
- (id<SCHookToken>)SCHook_selector:(SEL)selector
                     withOptions:(SCHookOptions)options
                      usingBlock:(SCHookBlock)block
                           error:(NSError **)error {
    return [SCHookHelper addWithObject:self selector:selector options:options block:block error:error];
}

@end

@implementation SCHookTracker

- (id)initWithTrackedClass:(Class)trackedClass {
    if (self = [super init]) {
        _trackedClass = trackedClass;
        _selectorNames = [NSMutableSet new];
        _selectorNamesToSubclassTrackers = [NSMutableDictionary new];
    }
    return self;
}

- (BOOL)subclassHasHookedSelectorName:(NSString *)selectorName {
    return self.selectorNamesToSubclassTrackers[selectorName] != nil;
}

- (void)addSubclassTracker:(SCHookTracker *)subclassTracker hookingSelectorName:(NSString *)selectorName {
    NSMutableSet *trackerSet = self.selectorNamesToSubclassTrackers[selectorName];
    if (!trackerSet) {
        trackerSet = [NSMutableSet new];
        self.selectorNamesToSubclassTrackers[selectorName] = trackerSet;
    }
    [trackerSet addObject:subclassTracker];
}
- (void)removeSubclassTracker:(SCHookTracker *)subclassTracker hookingSelectorName:(NSString *)selectorName {
    NSMutableSet *trackerSet = self.selectorNamesToSubclassTrackers[selectorName];
    [trackerSet removeObject:subclassTracker];
    if (trackerSet.count == 0) {
        [self.selectorNamesToSubclassTrackers removeObjectForKey:selectorName];
    }
}
- (NSSet *)subclassTrackersHookingSelectorName:(NSString *)selectorName {
    NSMutableSet *hookingSubclassTrackers = [NSMutableSet new];
    for (SCHookTracker *tracker in self.selectorNamesToSubclassTrackers[selectorName]) {
        if ([tracker.selectorNames containsObject:selectorName]) {
            [hookingSubclassTrackers addObject:tracker];
        }
        [hookingSubclassTrackers unionSet:[tracker subclassTrackersHookingSelectorName:selectorName]];
    }
    return hookingSubclassTrackers;
}
- (NSString *)trackedClassName {
    return NSStringFromClass(self.trackedClass);
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %@, trackedClass: %@, selectorNames:%@, subclass selector names: %@>", self.class, self, NSStringFromClass(self.trackedClass), self.selectorNames, self.selectorNamesToSubclassTrackers.allKeys];
}

@end

@implementation NSInvocation (SCHook)

- (id)SCHook_argumentAtIndex:(NSUInteger)index {
    const char *argType = [self.methodSignature getArgumentTypeAtIndex:index];
    if (argType[0] == _C_CONST) argType++;
    
#define WRAP_AND_RETURN(type) do { type val = 0; [self getArgument:&val atIndex:(NSInteger)index]; return @(val); } while (0)
    if (strcmp(argType, @encode(id)) == 0 || strcmp(argType, @encode(Class)) == 0) {
        __autoreleasing id returnObj;
        [self getArgument:&returnObj atIndex:(NSInteger)index];
        return returnObj;
    } else if (strcmp(argType, @encode(SEL)) == 0) {
        SEL selector = 0;
        [self getArgument:&selector atIndex:(NSInteger)index];
        return NSStringFromSelector(selector);
    } else if (strcmp(argType, @encode(Class)) == 0) {
        __autoreleasing Class theClass = Nil;
        [self getArgument:&theClass atIndex:(NSInteger)index];
        return theClass;
    } else if (strcmp(argType, @encode(char)) == 0) {
        WRAP_AND_RETURN(char);
    } else if (strcmp(argType, @encode(int)) == 0) {
        WRAP_AND_RETURN(int);
    } else if (strcmp(argType, @encode(short)) == 0) {
        WRAP_AND_RETURN(short);
    } else if (strcmp(argType, @encode(long)) == 0) {
        WRAP_AND_RETURN(long);
    } else if (strcmp(argType, @encode(long long)) == 0) {
        WRAP_AND_RETURN(long long);
    } else if (strcmp(argType, @encode(unsigned char)) == 0) {
        WRAP_AND_RETURN(unsigned char);
    } else if (strcmp(argType, @encode(unsigned int)) == 0) {
        WRAP_AND_RETURN(unsigned int);
    } else if (strcmp(argType, @encode(unsigned short)) == 0) {
        WRAP_AND_RETURN(unsigned short);
    } else if (strcmp(argType, @encode(unsigned long)) == 0) {
        WRAP_AND_RETURN(unsigned long);
    } else if (strcmp(argType, @encode(unsigned long long)) == 0) {
        WRAP_AND_RETURN(unsigned long long);
    } else if (strcmp(argType, @encode(float)) == 0) {
        WRAP_AND_RETURN(float);
    } else if (strcmp(argType, @encode(double)) == 0) {
        WRAP_AND_RETURN(double);
    } else if (strcmp(argType, @encode(BOOL)) == 0) {
        WRAP_AND_RETURN(BOOL);
    } else if (strcmp(argType, @encode(bool)) == 0) {
        WRAP_AND_RETURN(BOOL);
    } else if (strcmp(argType, @encode(char *)) == 0) {
        WRAP_AND_RETURN(const char *);
    } else if (strcmp(argType, @encode(void (^)(void))) == 0) {
        __unsafe_unretained id block = nil;
        [self getArgument:&block atIndex:(NSInteger)index];
        return [block copy];
    } else {
        NSUInteger valueSize = 0;
        NSGetSizeAndAlignment(argType, &valueSize, NULL);
        
        unsigned char valueBytes[valueSize];
        [self getArgument:valueBytes atIndex:(NSInteger)index];
        
        return [NSValue valueWithBytes:valueBytes objCType:argType];
    }
    return nil;
#undef WRAP_AND_RETURN
}

- (NSArray *)SCHook_arguments {
    NSMutableArray *argumentsArray = [NSMutableArray array];
    for (NSUInteger idx = 2; idx < self.methodSignature.numberOfArguments; idx++) {
        [argumentsArray addObject:[self SCHook_argumentAtIndex:idx] ?: NSNull.null];
    }
    return [argumentsArray copy];
}

@end

@implementation SCHookIdentifier

+ (instancetype)identifierWithSelector:(SEL)selector object:(id)object options:(SCHookOptions)options block:(SCHookBlock)block error:(NSError *__autoreleasing *)error {
    NSCParameterAssert(block);
    NSCParameterAssert(selector);
    NSMethodSignature *blockSignature = [SCHookHelper blockMethodSignatureWithBlock:block error:error];
    if (![SCHookHelper isCompatibleBlockSignature:blockSignature object:object selector:selector error:error]) {
        return nil;
    }
    
    SCHookIdentifier *identifier = nil;
    if (blockSignature) {
        identifier = [SCHookIdentifier new];
        identifier.selector = selector;
        identifier.block = block;
        identifier.blockSignature = blockSignature;
        identifier.options = options;
        identifier.object = object;
    }
    return identifier;
}

- (BOOL)invokeWithInfo:(id<SCHookInfo>)info {
    NSInvocation *blockInvocation = [NSInvocation invocationWithMethodSignature:self.blockSignature];
    NSInvocation *originalInvocation = info.originalInvocation;
    NSUInteger numberOfArguments = self.blockSignature.numberOfArguments;
    
    if (numberOfArguments > originalInvocation.methodSignature.numberOfArguments) {
        NSLog(@"Block has too many arguments. Not calling %@", info);
        return NO;
    }
    
    if (numberOfArguments > 1) {
        [blockInvocation setArgument:&info atIndex:1];
    }
    
    void *argBuf = NULL;
    for (NSUInteger idx = 2; idx < numberOfArguments; idx++) {
        const char *type = [originalInvocation.methodSignature getArgumentTypeAtIndex:idx];
        NSUInteger argSize;
        NSGetSizeAndAlignment(type, &argSize, NULL);
        
        if (!(argBuf = reallocf(argBuf, argSize))) {
            NSLog(@"Failed to allocate memory for block invocation.");
            return NO;
        }
        
        [originalInvocation getArgument:argBuf atIndex:idx];
        [blockInvocation setArgument:argBuf atIndex:idx];
    }
    
    [blockInvocation invokeWithTarget:self.block];
    
    if (argBuf != NULL) {
        free(argBuf);
    }
    return YES;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p, SEL:%@ object:%@ options:%tu block:%@ (#%tu args)>", self.class, self, NSStringFromSelector(self.selector), self.object, self.options, self.block, self.blockSignature.numberOfArguments];
}

- (BOOL)remove {
    return [SCHookHelper removeIdentifier:self error:NULL];
}

@end

@implementation SCHookContainer

- (BOOL)hasHooks {
    return self.beforeHooks.count > 0 || self.insteadHooks.count > 0 || self.afterHooks.count > 0;
}

- (void)addHook:(SCHookIdentifier *)hook withOptions:(SCHookOptions)options {
    NSParameterAssert(hook);
    NSUInteger position = options&SCHookPositionFilter;
    switch (position) {
        case SCHookPositionBefore:  self.beforeHooks  = [(self.beforeHooks ?:@[]) arrayByAddingObject:hook]; break;
        case SCHookPositionInstead: self.insteadHooks = [(self.insteadHooks?:@[]) arrayByAddingObject:hook]; break;
        case SCHookPositionAfter:   self.afterHooks   = [(self.afterHooks  ?:@[]) arrayByAddingObject:hook]; break;
    }
}

- (BOOL)removeHook:(SCHookIdentifier *)hook {
    for (NSString *hookArrayName in @[NSStringFromSelector(@selector(beforeHooks)),
                                        NSStringFromSelector(@selector(insteadHooks)),
                                        NSStringFromSelector(@selector(afterHooks))]) {
        NSArray *array = [self valueForKey:hookArrayName];
        NSUInteger index = [array indexOfObjectIdenticalTo:hook];
        if (array && index != NSNotFound) {
            NSMutableArray *newArray = [NSMutableArray arrayWithArray:array];
            [newArray removeObjectAtIndex:index];
            [self setValue:newArray forKey:hookArrayName];
            return YES;
        }
    }
    return NO;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p, before:%@, instead:%@, after:%@>", self.class, self, self.beforeHooks, self.insteadHooks, self.afterHooks];
}

@end

@implementation SCHookInfo

@synthesize arguments = _arguments;

- (id)initWithInstance:(__unsafe_unretained id)instance invocation:(NSInvocation *)invocation {
    NSCParameterAssert(instance);
    NSCParameterAssert(invocation);
    if (self = [super init]) {
        _instance = instance;
        _originalInvocation = invocation;
    }
    return self;
}

- (NSArray *)arguments {
    if (!_arguments) {
        _arguments = self.originalInvocation.SCHook_arguments;
    }
    return _arguments;
}

@end
