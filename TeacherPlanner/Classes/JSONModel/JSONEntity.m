//
//  JSONEntity.m
//  JSONModelTest
//
//  Created by Oliver on 26.09.13.
//
//

#import "JSONEntity.h"
#import "PropertyBinding.h"
#import "ContextBinding.h"
#import "Utilities.h"
#import "Model.h"
#import "Application.h"
#import "objc/message.h"
#import "NSString+Extension.h"
#import "JSONTransientEntity.h"

@interface JSONEntity () {
    __weak JSONEntity *_parent;
    BOOL _dirty;
    NSMutableSet *_bindings;
}

@end

@implementation JSONEntity

- (instancetype)init {
    // New entity instance
    self = [super init];
    if (self) {
        self.uuid = [JSONEntity createUUID];
        [self _setup_];
        [self setup:YES];
        [self markDirty];
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary*)dict error:(NSError**)err {
    // Loaded entity instance
    self = [super initWithDictionary:dict error:err];
    if (self) {
        [self _setup_];
        [self setup:NO];
    }
    return self;
}

- (void)_setup_ {
    _bindings = [NSMutableSet new];
}

- (void)setup:(BOOL)isNew {
    // Overwrite in entity class
}

+ (id)load:(NSString *)uuid {
    return [Utilities readEntity:uuid folder:[[Model instance].application applicationFolder] class:self.class];
}

- (BOOL)store {
    if ([self isDirty]) {
        [self markDirty:NO];
        return [Utilities writeEntity:self.uuid folder:[[Model instance].application applicationFolder] entity:self];
    }
    return YES;
}

- (BOOL)exportData {
    return [Utilities exportEntity:self.uuid folder:[[Model instance].application applicationFolder] entity:self];
}

- (NSString *)name {
    return @"";
}

- (NSString *)shortName {
    return self.name;
}

- (NSString *)photoUUID {
    return nil;
}

- (JSONEntity *)parent {
    return _parent;
}

- (void)setParent:(JSONEntity *)parent {
    _parent = parent;
}

- (id)getProperty:(NSString *)name {
    return [self valueForKeyPath:name];
}

- (void)setProperty:(NSString *)name value:(id)value {
    [self setProperty:name value:value trigger:nil force:NO];
}

- (void)setProperty:(NSString *)name value:(id)value trigger:(PropertyBinding *)trigger {
    [self setProperty:name value:value trigger:trigger force:NO];
}

- (void)setProperty:(NSString *)name value:(id)value force:(BOOL)force {
    [self setProperty:name value:value trigger:nil force:force];
}

- (void)setProperty:(NSString *)name value:(id)value trigger:(PropertyBinding *)trigger force:(BOOL)force {
    id currentValue = [self getProperty:name];
    if (!force && currentValue == nil && value == nil) {
        return;
    }
    if (force || currentValue == nil || ![currentValue isEqual:value]) {
        [self setValue:value forKeyPath:name];
        [self markDirty];
        [self refreshPropertyBindings:name trigger:trigger userInfo:@{ @"property" : name,
                                                                       @"value" : value ? value : [NSNull null] }];
    }
}

- (void)invalidateProperty:(NSString *)name {
    [self invalidateProperty:name trigger:nil userInfo:@{ @"property" : name }];
}

- (void)invalidateProperty:(NSString *)name userInfo:(NSDictionary *)userInfo {
    [self invalidateProperty:name trigger:nil userInfo:userInfo];
}

- (void)invalidateProperty:(NSString *)name trigger:(PropertyBinding *)trigger {
    [self invalidateProperty:name trigger:trigger userInfo:@{ @"property" : name }];
}

- (void)invalidateProperty:(NSString *)name trigger:(PropertyBinding *)trigger userInfo:(NSDictionary *)userInfo {
    [self refreshPropertyBindings:name trigger:trigger userInfo:userInfo];
}

- (CFTypeRef)callMethod:(SEL)selector returnValue:(BOOL)returnValue argument:(id)arg, ... {
    NSMethodSignature *signature = [[self class] instanceMethodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setTarget:self];
    [invocation setSelector:selector];
    
    va_list argumentList;
    if (arg) {
        if ([arg isKindOfClass:NSValue.class]) {
            void *value;
            [(NSValue *)arg getValue:&value];
            [invocation setArgument:&value atIndex:2];
        } else {
            [invocation setArgument:&arg atIndex:2];
        }
        va_start(argumentList, arg);
        id eachArg;
        NSInteger index = 3;
        while ((eachArg = va_arg(argumentList, id))) {
            if ([eachArg isKindOfClass:NSValue.class]) {
                void *value;
                [(NSValue *)eachArg getValue:&value];
                [invocation setArgument:&value atIndex:index++];
            } else {
                [invocation setArgument:&eachArg atIndex:index++];
            }
        }
        va_end(argumentList);
    }

    [invocation invoke];
    if (returnValue) {
        CFTypeRef inocationReturnValue;
        [invocation getReturnValue:&inocationReturnValue];
        return inocationReturnValue;
    }
    return nil;
}

- (NSInteger)numberOfAggregation:(NSString *)name {
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"numberOf%@", [name capitalize]]);
    NSAssert([self respondsToSelector:selector],
             ([NSString stringWithFormat:@"Message '%@' is not implemented", NSStringFromSelector(selector)]));
    return (NSInteger)[self callMethod:selector returnValue:YES argument:nil];
}

- (NSInteger)numberOfAggregationGroup:(NSString *)name {
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"numberOf%@Group", [name capitalize]]);
    NSAssert([self respondsToSelector:selector],
             ([NSString stringWithFormat:@"Message '%@' is not implemented", NSStringFromSelector(selector)]));
    return (NSInteger)[self callMethod:selector returnValue:YES argument:nil];
}

- (NSInteger)numberOfAggregation:(NSString *)name group:(NSInteger)group {
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"numberOf%@ByGroup:", [name capitalize]]);
    NSAssert([self respondsToSelector:selector],
             ([NSString stringWithFormat:@"Message '%@' is not implemented", NSStringFromSelector(selector)]));
    NSValue *groupValue = [NSValue value:&group withObjCType:@encode(NSInteger)];
    return (NSInteger)[self callMethod:selector returnValue:YES argument:groupValue, nil];
}

- (NSInteger)numberOfAggregation:(NSString *)name groupName:(NSString *)groupName {
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"numberOf%@ByGroupName:", [name capitalize]]);
    NSAssert([self respondsToSelector:selector],
             ([NSString stringWithFormat:@"Message '%@' is not implemented", NSStringFromSelector(selector)]));
    return (NSInteger)[self callMethod:selector returnValue:YES argument:groupName, nil];
}

- (NSString *)aggregationGroupName:(NSString *)name group:(NSInteger)group {
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"%@GroupName:", name]);
    NSAssert([self respondsToSelector:selector],
             ([NSString stringWithFormat:@"Message '%@' is not implemented", NSStringFromSelector(selector)]));
    NSValue *groupValue = [NSValue value:&group withObjCType:@encode(NSInteger)];
    return (NSString *)[self callMethod:selector returnValue:YES argument:groupValue, nil];
}

- (NSIndexPath *)aggregationGroupIndex:(NSString *)name uuid:(NSString *)uuid {
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"%@GroupIndexByUUID:", name]);
    NSAssert([self respondsToSelector:selector],
             ([NSString stringWithFormat:@"Message '%@' is not implemented", NSStringFromSelector(selector)]));
    return (NSIndexPath *)[self callMethod:selector returnValue:YES argument:uuid, nil];
}

- (NSInteger)aggregationIndex:(NSString *)name uuid:(NSString *)uuid {
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"%@IndexByUUID:", name]);
    NSAssert([self respondsToSelector:selector],
             ([NSString stringWithFormat:@"Message '%@' is not implemented", NSStringFromSelector(selector)]));
    return (NSInteger)[self callMethod:selector returnValue:YES argument:uuid, nil];
}

- (id)aggregation:(NSString *)name group:(NSInteger)group index:(NSInteger)index {
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"%@ByGroup:index:", name]);
    NSAssert([self respondsToSelector:selector],
             ([NSString stringWithFormat:@"Message '%@' is not implemented", NSStringFromSelector(selector)]));
    NSValue *groupValue = [NSValue value:&group withObjCType:@encode(NSInteger)];
    NSValue *indexValue = [NSValue value:&index withObjCType:@encode(NSInteger)];
    return (id)[self callMethod:selector returnValue:YES argument:groupValue, indexValue, nil];
}

- (id)aggregation:(NSString *)name index:(NSInteger)index {
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"%@ByIndex:", name]);
    NSAssert([self respondsToSelector:selector],
             ([NSString stringWithFormat:@"Message '%@' is not implemented", NSStringFromSelector(selector)]));
    NSValue *indexValue = [NSValue value:&index withObjCType:@encode(NSInteger)];
    return (id)[self callMethod:selector returnValue:YES argument:indexValue, nil];
}

- (id)aggregation:(NSString *)name uuid:(NSString *)uuid {
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"%@ByUUID:", name]);
    NSAssert([self respondsToSelector:selector],
             ([NSString stringWithFormat:@"Message '%@' is not implemented", NSStringFromSelector(selector)]));
    return (id)[self callMethod:selector returnValue:YES argument:uuid, nil];
}

- (id)addAggregation:(NSString *)name {
    return [self addAggregation:name parameters:nil trigger:nil];
}

- (id)addAggregation:(NSString *)name parameters:(NSDictionary *)parameters {
    return [self addAggregation:name parameters:parameters trigger:nil];
}

- (id)addAggregation:(NSString *)name trigger:(PropertyBinding *)trigger {
    return [self addAggregation:name parameters:nil trigger:trigger];
}

- (id)addAggregation:(NSString *)name parameters:(NSDictionary *)parameters trigger:(PropertyBinding *)trigger {
    SEL selector = nil;
    if (parameters) {
        selector = NSSelectorFromString([NSString stringWithFormat:@"add%@:", [name capitalize]]);
    } else {
        selector = NSSelectorFromString([NSString stringWithFormat:@"add%@", [name capitalize]]);
    }
    NSAssert([self respondsToSelector:selector],
             ([NSString stringWithFormat:@"Message '%@' is not implemented", NSStringFromSelector(selector)]));
    id object = nil;
    if (parameters) {
        object = (id)[self callMethod:selector returnValue:YES argument:parameters, nil];
    } else {
        object = (id)[self callMethod:selector returnValue:YES argument:nil];
    }
    if ([object isKindOfClass:JSONEntity.class]) {
        JSONEntity *entity = (JSONEntity *)object;
        [entity markDirty:NO];
        if ((!entity.parent || entity.parent != self) && ![self isKindOfClass:JSONTransientEntity.class]) {
            entity.parent = self;
        }
        [entity markDirty];
    }
    [self markDirty];
    [self invalidateContext:name trigger:trigger];
    return object;
}

- (void)insertAggregation:(NSString *)name object:(id)object {
    [self insertAggregation:name object:object trigger:nil];
}

- (void)insertAggregation:(NSString *)name object:(id)object trigger:(PropertyBinding *)trigger {
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"insert%@:", [name capitalize]]);
    NSAssert([self respondsToSelector:selector],
             ([NSString stringWithFormat:@"Message '%@' is not implemented", NSStringFromSelector(selector)]));
    [self callMethod:selector returnValue:NO argument:object, nil];
    if ([object isKindOfClass:JSONEntity.class]) {
        JSONEntity *entity = (JSONEntity *)object;
        [entity markDirty:NO];
        if ((!entity.parent || entity.parent != self) && ![self isKindOfClass:JSONTransientEntity.class]) {
            entity.parent = self;
        }
        [entity markDirty];
    }
    [self markDirty];
    [self invalidateContext:name trigger:trigger];
}

- (void)removeAggregation:(NSString *)name object:(id)object {
    [self removeAggregation:name object:object trigger:nil];
}

- (void)removeAggregation:(NSString *)name object:(id)object trigger:(PropertyBinding *)trigger {
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"remove%@:", [name capitalize]]);
    NSAssert([self respondsToSelector:selector],
             ([NSString stringWithFormat:@"Message '%@' is not implemented", NSStringFromSelector(selector)]));
    [self callMethod:selector returnValue:NO argument:object, nil];
    if ([object isKindOfClass:JSONEntity.class]) {
        JSONEntity *entity = (JSONEntity *)object;
        [[Model instance] markEntityForDelete:name uuid:entity.uuid];
    }
    [self markDirty];
    [self invalidateContext:name trigger:trigger];
}

- (void)removeAggregation:(NSString *)name uuid:(NSString *)uuid {
    [self removeAggregation:name uuid:uuid trigger:nil];
}

- (void)removeAggregation:(NSString *)name uuid:(NSString *)uuid trigger:(PropertyBinding *)trigger {
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"remove%@ByUUID:", [name capitalize]]);
    NSAssert([self respondsToSelector:selector],
             ([NSString stringWithFormat:@"Message '%@' is not implemented", NSStringFromSelector(selector)]));
    [self callMethod:selector returnValue:NO argument:uuid, nil];
    [[Model instance] markEntityForDelete:name uuid:uuid];
    [self markDirty];
    [self invalidateContext:name trigger:trigger];
}

- (void)clearAggregation:(NSString *)name {
    [self clearAggregation:name trigger:nil];
}

- (void)clearAggregation:(NSString *)name trigger:(PropertyBinding *)trigger  {
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"clear%@", [name capitalize]]);
    NSAssert([self respondsToSelector:selector],
             ([NSString stringWithFormat:@"Message '%@' is not implemented", NSStringFromSelector(selector)]));
    [self callMethod:selector returnValue:NO argument:nil];
    if ([self respondsToSelector:NSSelectorFromString(name)]) {
        for (NSObject *object in [self valueForKey:name]) {
            if ([object isKindOfClass:JSONEntity.class]) {
                JSONEntity *entity = (JSONEntity *)object;
                [[Model instance] markEntityForDelete:name uuid: entity.uuid];
            }
        }
    }
    [self markDirty];
    [self invalidateContext:name trigger:trigger];
}

- (void)updateAggregation:(NSString *)name object:(id)object action:(NSString *)action {
    [self aggregation:name object:object action:action parameters:nil trigger:nil returnObject:NO];
}

- (void)updateAggregation:(NSString *)name object:(id)object action:(NSString *)action parameters:(NSDictionary *)parameters {
    [self aggregation:name object:object action:action parameters:parameters trigger:nil returnObject:NO];
}

- (void)updateAggregation:(NSString *)name object:(id)object action:(NSString *)action trigger:(PropertyBinding *)trigger{
    [self aggregation:name object:object action:action parameters:nil trigger:trigger returnObject:NO];
}

- (void)updateAggregation:(NSString *)name object:(id)object action:(NSString *)action parameters:(NSDictionary *)parameters trigger:(PropertyBinding *)trigger {
    [self aggregation:name object:object action:action parameters:parameters trigger:trigger returnObject:YES];
}

- (id)callAggregation:(NSString *)name object:(id)object action:(NSString *)action {
    return [self aggregation:name object:object action:action parameters:nil trigger:nil returnObject:YES];
}

- (id)callAggregation:(NSString *)name object:(id)object action:(NSString *)action parameters:(NSDictionary *)parameters{
    return [self aggregation:name object:object action:action parameters:parameters trigger:nil returnObject:YES];
}

- (id)callAggregation:(NSString *)name object:(id)object action:(NSString *)action trigger:(PropertyBinding *)trigger {
    return [self aggregation:name object:object action:action parameters:nil trigger:trigger returnObject:YES];
}

- (id)callAggregation:(NSString *)name object:(id)object action:(NSString *)action parameters:(NSDictionary *)parameters trigger:(PropertyBinding *)trigger {
    return [self aggregation:name object:object action:action parameters:parameters trigger:trigger returnObject:YES];
}

- (id)aggregation:(NSString *)name object:(id)object action:(NSString *)action parameters:(NSDictionary *)parameters trigger:(PropertyBinding *)trigger returnObject:(BOOL)returnObject {
    SEL selector = nil;
    if (object && parameters) {
        selector = NSSelectorFromString([NSString stringWithFormat:@"%@%@:parameters:", action, [name capitalize]]);
    } else if (object) {
        selector = NSSelectorFromString([NSString stringWithFormat:@"%@%@:", action, [name capitalize]]);
    } else {
        selector = NSSelectorFromString([NSString stringWithFormat:@"%@%@", action, [name capitalize]]);
    }
    NSAssert([self respondsToSelector:selector],
             ([NSString stringWithFormat:@"Message '%@' is not implemented", NSStringFromSelector(selector)]));
    id result = nil;
    if (object && parameters) {
        if (returnObject) {
            result = (id)[self callMethod:selector returnValue:YES argument:object, parameters, nil];
        } else {
            [self callMethod:selector returnValue:NO argument:object, parameters, nil];
        }
    } else if (object) {
        if (returnObject) {
            result = (id)[self callMethod:selector returnValue:YES argument:object, nil];
        } else {
            [self callMethod:selector returnValue:NO argument:object, nil];
        }
    } else if (parameters) {
        if (returnObject) {
            result = (id)[self callMethod:selector returnValue:YES argument:parameters, nil];
        } else {
            [self callMethod:selector returnValue:NO argument:parameters, nil];
        }
    } else {
        if (returnObject) {
            result = (id)[self callMethod:selector returnValue:YES argument:nil];
        } else {
            [self callMethod:selector returnValue:NO argument:nil];
        }
    }
    [self markDirty];
    [self invalidateContext:name trigger:trigger];
    return result;
}

- (void)filterAggregation:(NSString *)name bySearchText:(NSString *)searchText {
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"filter%@By:", [name capitalize]]);
    NSAssert([self respondsToSelector:selector],
             ([NSString stringWithFormat:@"Message '%@' is not implemented", NSStringFromSelector(selector)]));
    [self callMethod:selector returnValue:NO argument:searchText, nil];
}

- (void)resetFilterAggregation:(NSString *)name {
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"resetFilter%@", [name capitalize]]);
    NSAssert([self respondsToSelector:selector],
             ([NSString stringWithFormat:@"Message '%@' is not implemented", NSStringFromSelector(selector)]));
    [self callMethod:selector returnValue:NO argument:nil];
}

- (NSArray *)aggregationIndex:(NSString *)name {
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"%@Index", name]);
    NSAssert([self respondsToSelector:selector],
             ([NSString stringWithFormat:@"Message '%@' is not implemented", NSStringFromSelector(selector)]));
    return (NSArray *)[self callMethod:selector returnValue:YES argument:nil];
}

- (void)invalidateContext:(NSString *)context {
    [self invalidateContext:context trigger:nil userInfo:nil];
}

- (void)invalidateContext:(NSString *)context userInfo:(NSDictionary *)userInfo {
    [self invalidateContext:context trigger:nil userInfo:userInfo];
}

- (void)invalidateContext:(NSString *)context trigger:(PropertyBinding *)trigger {
    [self invalidateContext:context trigger:trigger userInfo:nil];
}

- (void)invalidateContext:(NSString *)context trigger:(PropertyBinding *)trigger userInfo:(NSDictionary *)userInfo {
    for (PropertyBinding *propertyBinding in [self bindings]) {
        if (propertyBinding.context && (!trigger || ![propertyBinding isEqual:trigger])) {
            for (NSDictionary *entityBinding in [propertyBinding contextEntitiyBindings]) {
                if (self == entityBinding[@"entity"] &&
                    [entityBinding[@"context"] rangeOfString:context].location == 0) {
                    [propertyBinding refresh:NO trigger:trigger userInfo:userInfo];
                }
            }
        }
    }
}

- (void)refresh {
    [self refreshPropertyBindings:nil trigger:nil userInfo:nil];
}

- (void)refreshPropertyBindings:(NSString *)name trigger:(PropertyBinding *)trigger userInfo:(NSDictionary *)userInfo {
    for (PropertyBinding *propertyBinding in [self bindings]) {
        if ((!name || [propertyBinding.property isEqual:name]) &&
            (!trigger || ![propertyBinding isEqual:trigger])) {
            [propertyBinding refresh:NO trigger:trigger userInfo:userInfo];
        }
    }
}

- (BOOL)isDirty {
    return _dirty;
}

- (void)markDirty {
    [self markDirty:YES];
}

- (void)markDirty:(BOOL)dirty {
    if (dirty) {
        if (!self.parent) {
            _dirty = dirty;
        } else {
            [self.parent markDirty:dirty];
        }
        if (dirty) {
            NSDate *date = [NSDate new];
            if (!self.createdAt) {
                self.createdAt = date;
            }
            self.changedAt = date;
        }
    } else {
        _dirty = NO;
    }
}

- (BOOL)isProtected {
    if (!self.parent) {
        return NO;
    } else {
        return [self.parent isProtected];
    }
}

- (BOOL)suppressProtected {
    if (self.parent) {
        return [self.parent suppressProtected];
    }
    return NO;
}

- (void)setSuppressProtected:(BOOL)suppressProtected {
    if (self.parent) {
        return [self.parent setSuppressProtected:suppressProtected];
    }
}

- (void)willBeRemoved {
    [[Model instance] markEntityForDelete:NSStringFromClass(self.class) uuid:self.uuid];
}

- (BOOL)isEqual:(JSONEntity *)object {
    return self == object || ([self class] == [object class] && self.uuid != nil && [self.uuid isEqualToString:object.uuid]);
}

+ (BOOL)propertyIsOptional:(NSString*)propertyName {
    return YES;
}

- (NSSet *)bindings {
    return [NSMutableSet setWithSet:_bindings];
}

- (NSSet *)propertyBindings {
    NSMutableSet *contextBindings = [[NSMutableSet alloc] init];
    for (PropertyBinding *propertyBinding in _bindings) {
        if (![propertyBinding isKindOfClass:ContextBinding.class]) {
            [contextBindings addObject:propertyBinding];
        }
    }
    return contextBindings;
}

- (NSSet *)contextBindings {
    NSMutableSet *contextBindings = [[NSMutableSet alloc] init];
    for (PropertyBinding *propertyBinding in _bindings) {
        if ([propertyBinding isKindOfClass:ContextBinding.class]) {
            [contextBindings addObject:propertyBinding];
        }
    }
    return contextBindings;
}

- (void)bind:(PropertyBinding *)propertyBinding {
    [self validate];
    [_bindings addObject:propertyBinding];
}

- (void)unbind:(PropertyBinding *)propertyBinding {
    [_bindings removeObject:propertyBinding];
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

- (NSString *)entityAggregation {
    return [NSStringFromClass(self.class) uncapitalize];
}

- (NSString *)entityPath {
    NSMutableArray *entityPathParts = [@[] mutableCopy];
    JSONEntity *entity = self;
    while (entity) {
        [entityPathParts insertObject:@{ @"aggregation" : [entity entityAggregation],
                                         @"entity" : NSStringFromClass(entity.class),
                                         @"uuid" : entity.uuid } atIndex:0];
        entity = entity.parent;
    }
    return [Utilities serializeObjectToJSON:entityPathParts];
}

- (JSONEntity *)entityByEntityPath:(NSString *)entityPath {
    JSONEntity *entity = nil;
    NSArray *entityPathParts = [Utilities deserializeJSONToObject:entityPath];
    if (entityPathParts) {
        entity = self;
        for (NSDictionary *entityPathPart in entityPathParts) {
            entity = [entity aggregation:entityPathPart[@"aggregation"] uuid:entityPathPart[@"uuid"]];
            if (!(entity && [entity isKindOfClass:NSClassFromString(entityPathPart[@"entity"])])) {
                entity = nil;
                break;
            }
        }
    }
    return entity;
}

- (void)dealloc {
    _parent = nil;
    [self unbindAll];
    _bindings = nil;
}

+ (NSString *)createUUID {
    return [Utilities createUUID];
}

- (id)copyWithZone:(NSZone *)zone {
    return nil;
}

@end