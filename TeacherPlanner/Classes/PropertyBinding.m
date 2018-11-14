//
//  PropertyBinding.m
//  TeacherPlanner
//
//  Created by Oliver on 18.05.14.
//
//

#import "PropertyBinding.h"
#import "Application.h"
#import "Model.h"
#import "JSONEntity.h"
#import "NSString+Extension.h"

@interface PropertyBinding()

@end

@implementation PropertyBinding

- (instancetype)initWithEntity:(JSONEntity *)entity context:(NSString *)context property:(NSString *)property {
    self = [self init];
    if (self) {
        _entity = entity;
        _context = context;
        _property = property;
    }
    return self;
}

- (id)value {
    NSObject *contextObject = [self applyContext];
    if (contextObject && self.property) {
        if ([contextObject respondsToSelector:NSSelectorFromString(self.property)]) {
            if ([contextObject isKindOfClass:JSONEntity.class]) {
                return [(JSONEntity *)contextObject getProperty:self.property];
            } else {
                return [contextObject valueForKeyPath:self.property];
            }
        }
    }
    return nil;
}

- (void)setValue:(id)value {
    NSObject *contextObject = [self applyContext];
    if (contextObject && self.property) {
        if ([contextObject respondsToSelector:NSSelectorFromString(self.property)]) {
            if ([contextObject isKindOfClass:JSONEntity.class]) {
                [(JSONEntity *)contextObject setProperty:self.property value:value trigger:self];
            } else {
                [contextObject setValue:value forKeyPath:self.property];
                [[self contextEntity] refresh];
            }
            [self.delegate entityPropertyDidChange:self];
        }
    }
}

- (id)contextValue {
    return [self applyContext];
}

- (JSONEntity *)contextEntity {
    return (JSONEntity *)[self applyContext:YES];
}

- (NSArray *)contextEntities {
    NSString *contextEntityBinding = @"";
    NSMutableArray *contextEntities = [@[] mutableCopy];
    for (NSDictionary *entityBinding in [self applyContexts:YES contextEntityBinding:&contextEntityBinding]) {
        [contextEntities addObject:entityBinding[@"entity"]];
    }
    return contextEntities;
}

- (NSArray *)contextEntitiyBindings {
    NSString *contextEntityBinding = @"";
    return [self applyContexts:YES contextEntityBinding:&contextEntityBinding];
}

- (NSArray *)contextObjects {
    NSString *contextEntityBinding = @"";
    NSMutableArray *contextObjects = [@[] mutableCopy];
    for (NSDictionary *objectBinding in [self applyContexts:NO contextEntityBinding:&contextEntityBinding]) {
        [contextObjects addObject:objectBinding[@"object"]];
    }
    return contextObjects;
}

- (NSArray *)contextObjectsBindings {
    NSString *contextEntityBinding = @"";
    return [self applyContexts:NO contextEntityBinding:&contextEntityBinding];
}

- (NSString *)contextEntityBinding {
    NSString *contextEntityBinding = self.property;
    if (!self.property) {
        [self applyContext:NO contextEntityBinding:&contextEntityBinding];
    }
    return contextEntityBinding;
}

- (NSObject *)applyContext {
    return [self applyContext:NO];
}

- (NSObject *)applyContext:(BOOL)filterEntity {
    NSString *contextEntityBinding = @"";
    return [self applyContext:filterEntity contextEntityBinding:&contextEntityBinding];
}

- (NSObject *)applyContext:(BOOL)filterEntity contextEntityBinding:(NSString **)contextEntityBinding {
    NSArray *contexts = [self applyContexts:filterEntity contextEntityBinding:contextEntityBinding];
    if (contexts.count > 0) {
        NSDictionary *context = contexts[contexts.count - 1];
        return filterEntity ? context[@"entity"] : context[@"object"];
    }
    return nil;
}

- (NSArray *)applyContexts:(BOOL)filterEntity contextEntityBinding:(NSString **)contextEntityBinding {
    *contextEntityBinding = @"";
    NSMutableArray *contextObjects = [@[] mutableCopy];
    NSMutableArray *contextEntities = [@[] mutableCopy];
    if (self.entity) {
        NSObject *context = self.entity;
        [contextObjects addObject:@{ @"object" : self.entity,
                                     @"context" : (self.context ? self.context : @"") }];
        [contextEntities addObject:@{ @"entity" : self.entity,
                                      @"context" : (self.context ? self.context : @"") }];
        if (self.context.length > 0) {
            NSArray *contextParts = [self.context componentsSeparatedByString:@"/"];
            NSInteger partIndex = 0;
            for (NSString *contextPart in contextParts) {
                if (!context) {
                    break;
                }
                NSScanner *scan = [NSScanner scannerWithString:contextPart];
                NSInteger index = -1;
                [scan scanInteger:&index];
                if ([scan isAtEnd] && index >= 0) {
                    if ([context isKindOfClass:NSArray.class]) {
                        NSArray *contextArray = (NSArray *)context;
                        if (index < contextArray.count) {
                            context = [contextArray objectAtIndex:index];
                        }
                    }
                } else {
                    @try {
                        context = [context valueForKeyPath:contextPart];
                    } @catch (NSException *exception) {
                        NSAssert(false, ([[NSString alloc] initWithFormat:@"Context path '%@' is not defined", contextPart]));
                    }
                    if ((*contextEntityBinding).length > 0) {
                        *contextEntityBinding = [(*contextEntityBinding) stringByAppendingFormat:@"/%@", contextPart];
                    } else {
                        *contextEntityBinding = contextPart;
                    }
                }
                if (context) {
                    NSString *restBindingContext = @"";
                    for (NSInteger i = partIndex + 1; i < contextParts.count; i++) {
                        if (restBindingContext.length > 0) {
                            restBindingContext = [restBindingContext stringByAppendingFormat:@"/%@", contextParts[i]];
                        } else {
                            restBindingContext = contextParts[i];
                        }
                    }
                    [contextObjects addObject:@{ @"object" : context,
                                                 @"context" : restBindingContext }];
                    if ([context isKindOfClass:JSONEntity.class]) {
                        [contextEntities addObject:@{ @"entity" : (JSONEntity *)context,
                                                      @"context" : restBindingContext }];
                        *contextEntityBinding = @"";
                    }
                }
                partIndex++;
            }
        }
    }
    return filterEntity ? contextEntities : contextObjects;
}

- (PropertyBinding *)bind:(id<Bindable>)bindable property:(NSString *)property {
    _bindable = bindable;
    _bindableProperty = property ? property : @"";
    _control = nil;
    [bindable bind:self];
    for (JSONEntity *entity in [self contextEntities]) {
        [entity bind:self];
    }
    [self refresh:YES trigger:self userInfo:nil];
    return self;
}

- (PropertyBinding *)attachControl:(NSObject *)control {
    _bindable = nil;
    _bindableProperty = nil;
    _control = control;
    for (JSONEntity *entity in [self contextEntities]) {
        [entity bind:self];
    }
    return self;
}

- (void)update {
    if (self.bindable) {
        if (self.bindableProperty && [self.bindable respondsToSelector:NSSelectorFromString(self.bindableProperty)]) {
            self.value = [self.bindable getProperty:self.bindableProperty];
        }
    } else if (!self.control) {
        for (JSONEntity *entity in [self contextEntities]) {
            [entity validate];
        }
    }
}

- (void)refresh {
    [self refresh:NO trigger:nil userInfo:nil];
}

- (void)refresh:(BOOL)force {
    [self refresh:force trigger:nil userInfo:nil];
}

- (void)refresh:(BOOL)force trigger:(PropertyBinding *)trigger {
    [self refresh:force trigger:trigger userInfo:nil];
}

- (void)refresh:(BOOL)force trigger:(PropertyBinding *)trigger userInfo:(NSDictionary *)userInfo {
    if (self.bindable) {
        if (self.bindableProperty && ![self.bindableProperty isEqual:@""]) {
            if ([self.bindable respondsToSelector:NSSelectorFromString(self.bindableProperty)]) {
                [self.bindable setPropertySuppressUpdate:self.bindableProperty value:self.value force:force];
            }
        } else if (self.contextValue) {
            id source = nil;
            if (trigger) {
                source = trigger.source;
            }
            [self.bindable setContext:self.contextValue source:source userInfo:userInfo];
        }
        [self.delegate controlPropertyDidChange:self];
    } else if (!self.control) {
        for (JSONEntity *entity in [self contextEntities]) {
            [entity validate];
        }
    }
}

- (void)invalidate {
    _bindable = nil;
    _bindableProperty = nil;
    _control = nil;
    for (JSONEntity *entity in [self contextEntities]) {
        [entity validate];
    }
    [self validate];
}

- (void)validate {
    if (!self.bindable && !self.control) {
        for (JSONEntity *entity in [self contextEntities]) {
            [entity unbind:self];
        }
        _entity = nil;
        _context = nil;
        _property = nil;
    }
}

- (id)copyWithZone:(NSZone *)zone {
    PropertyBinding *propertyBinding = [[PropertyBinding alloc] initWithEntity:self.entity context:self.context property:self.property];
    return propertyBinding;
}

- (NSString *)description {
    NSString *description = [self isContextBinding] ? @"(C) " : @"(P) ";
    if (self.bindable && self.bindableProperty) {
        description = [description stringByAppendingFormat:@"%@>%@ = ", [self.bindable delegate] ? [self.bindable description] : NSStringFromClass([self.bindable class]), self.bindableProperty];
    } else if (self.control) {
        description = [description stringByAppendingFormat:@"%@ = ", NSStringFromClass(self.control.class)];
    }
    if (self.entity) {
        description = [description stringByAppendingFormat:@"%@>", NSStringFromClass(self.entity.class)];
    } else {
        description = [description stringByAppendingFormat:@"(orphaned)>"];
    }
    if (self.context) {
        description = [description stringByAppendingFormat:@"/%@", self.context];
    }
    if (self.property) {
        description = [description stringByAppendingFormat:@"/%@", self.property];
    }
    return description;
}

- (BOOL)isContextBinding {
    return NO;
}

- (id)source {
    return self.bindable.source;
}

@end