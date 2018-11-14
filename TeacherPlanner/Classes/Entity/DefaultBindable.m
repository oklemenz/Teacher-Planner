//
//  DefaultBindable.m
//  TeacherPlanner
//
//  Created by Oliver on 05.10.14.
//
//

#import "DefaultBindable.h"
#import "PropertyBinding.h"
#import "ContextBinding.h"

@interface DefaultBindable () {
    NSMutableDictionary *_bindings;
}

@end

@implementation DefaultBindable

- (instancetype)initWithDelegate:(id)delegate {
    self = [super init];
    if (self) {
        _bindings = [@{} mutableCopy];
        _delegate = delegate;
    }
    return self;
}

- (BOOL)respondsToSelector:(SEL)selector {
    return [super respondsToSelector:selector] || [self.delegate respondsToSelector:selector];
}

- (PropertyBinding *)bind:(PropertyBinding *)propertyBinding bindableProperty:(NSString *)bindableProperty {
    return [propertyBinding bind:self property:(bindableProperty ? bindableProperty : @"value")];
}

- (PropertyBinding *)bind:(JSONEntity *)entity context:(NSString *)context property:(NSString *)property bindableProperty:(NSString *)bindableProperty {
    PropertyBinding *propertyBinding = [[PropertyBinding alloc] initWithEntity:entity context:context property:property];
    return [propertyBinding bind:self property:(bindableProperty ? bindableProperty : @"value")];
}

- (PropertyBinding *)bind:(ContextBinding *)contextBinding property:(NSString *)property bindableProperty:(NSString *)bindableProperty {
    return [self bind:contextBinding.entity context:contextBinding.context property:property bindableProperty:bindableProperty];
}

- (ContextBinding *)bindContext:(JSONEntity *)entity context:(NSString *)context {
    ContextBinding *contextBinding = [ContextBinding createContextBinding:entity context:context];
    return (ContextBinding *)[contextBinding bind:self property:nil];
}

- (ContextBinding *)bindContext:(ContextBinding *)contextBinding {
    return (ContextBinding *)[contextBinding bind:self property:nil];
}

- (id)getProperty:(NSString *)name {
    return [self.delegate valueForKeyPath:name];
}

- (void)setProperty:(NSString *)name value:(id)value {
    [self setProperty:name value:value suppressUpdate:NO force:NO];
}

- (void)setProperty:(NSString *)name value:(id)value force:(BOOL)force {
    [self setProperty:name value:value suppressUpdate:NO force:force];
}

- (void)setPropertySuppressUpdate:(NSString *)name value:(id)value {
    [self setProperty:name value:value suppressUpdate:YES force:NO];
}

- (void)setPropertySuppressUpdate:(NSString *)name value:(id)value force:(BOOL)force {
    [self setProperty:name value:value suppressUpdate:YES force:force];
}

- (void)setProperty:(NSString *)name value:(id)value suppressUpdate:(BOOL)suppressUpdate force:(BOOL)force {
    id currentValue = [self getProperty:name];
    if (!force && currentValue == nil && value == nil) {
        return;
    }
    if (force || currentValue == nil || ![currentValue isEqual:value]) {
        [self.delegate setValue:value forKeyPath:name];
        if (!suppressUpdate) {
            for (PropertyBinding *propertyBinding in [self bindings]) {
                if ([propertyBinding.bindableProperty isEqual:name]) {
                    [propertyBinding update];
                }
            }
        }
    }
}

- (void)refresh {
    for (PropertyBinding *propertyBinding in [self bindings]) {
        [propertyBinding refresh:NO trigger:propertyBinding];
    }
}

- (JSONEntity *)entity {
    return [[[_bindings allValues] firstObject] entity];
}

- (void)setContext:(id)contextValue source:(id)source userInfo:(NSDictionary *)userInfo {
    if ([self.delegate respondsToSelector:@selector(setContext:source:userInfo:)]) {
        [self.delegate setContext:contextValue source:source userInfo:userInfo];
    }
}

- (NSArray *)bindings {
    return [NSArray arrayWithArray:[_bindings allValues]];
}

- (NSArray *)propertyBindings {
    NSMutableArray *propertyBindings = [@[] mutableCopy];
    for (PropertyBinding *propertyBinding in [self bindings]) {
        if (![propertyBinding isKindOfClass:ContextBinding.class]) {
            [propertyBindings addObject:propertyBinding];
        }
    }
    return propertyBindings;
}

- (PropertyBinding *)propertyBinding:(NSString *)bindableName {
    return _bindings[bindableName];
}

- (NSArray *)contextBindings {
    NSMutableArray *contextBindings = [@[] mutableCopy];
    for (PropertyBinding *propertyBinding in [self bindings]) {
        if ([propertyBinding isKindOfClass:ContextBinding.class]) {
            [contextBindings addObject:propertyBinding];
        }
    }
    return contextBindings;
}

- (ContextBinding *)contextBinding {
    for (PropertyBinding *propertyBinding in [self bindings]) {
        if ([propertyBinding isKindOfClass:ContextBinding.class]) {
            return (ContextBinding *)propertyBinding;
        }
    }
    return nil;
}

- (ContextBinding *)entityContextBinding:(JSONEntity *)entity {
    for (PropertyBinding *propertyBinding in [self bindings]) {
        if ([propertyBinding isKindOfClass:ContextBinding.class] && propertyBinding.entity == entity) {
            return (ContextBinding *)propertyBinding;
        }
    }
    return nil;
}

- (ContextBinding *)contextEntityContextBinding:(JSONEntity *)contextEntity {
    for (PropertyBinding *propertyBinding in [self bindings]) {
        if ([propertyBinding isKindOfClass:ContextBinding.class] && propertyBinding.contextEntity == contextEntity) {
            return (ContextBinding *)propertyBinding;
        }
    }
    return nil;
}

- (ContextBinding *)contextValueContextBinding:(NSObject *)contextValue {
    for (PropertyBinding *propertyBinding in [self bindings]) {
        if ([propertyBinding isKindOfClass:ContextBinding.class] && propertyBinding.contextValue == contextValue) {
            return (ContextBinding *)propertyBinding;
        }
    }
    return nil;
}

- (void)bind:(PropertyBinding *)propertyBinding {
    [self validate];
    if (!propertyBinding.bindableProperty) {
        return;
    }
    _bindings[propertyBinding.bindableProperty] = propertyBinding;
}

- (void)unbind:(PropertyBinding *)propertyBinding {
    [propertyBinding invalidate];
    [_bindings removeObjectForKey:propertyBinding.bindableProperty];
}

- (void)unbindAll {
    for (PropertyBinding *propertyBinding in [self bindings]) {
        [propertyBinding invalidate];
    }
    [_bindings removeAllObjects];
}

- (void)validate {
    for (PropertyBinding *propertyBinding in [self bindings]) {
        [propertyBinding validate];
    }
}

- (id)source {
    return self.delegate;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"-> %@", NSStringFromClass([self.delegate class])];
}

- (void)dealloc {
    [self unbindAll];
    _bindings = nil;
}

@end