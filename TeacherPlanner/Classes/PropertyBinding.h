//
//  PropertyBinding.h
//  TeacherPlanner
//
//  Created by Oliver on 18.05.14.
//
//

#import "JSONEntity.h"
#import "Binding.h"
#import "Bindable.h"

@class PropertyBinding;
@class ContextBinding;

@protocol PropertyBindingDelegate <NSObject>
- (void)entityPropertyDidChange:(PropertyBinding *)propertyBinding;
- (void)controlPropertyDidChange:(PropertyBinding *)propertyBinding;
@end

@interface PropertyBinding : Binding <NSCopying>

@property (nonatomic, readonly, weak) JSONEntity *entity;
@property (nonatomic, readonly) NSString *context;
@property (nonatomic, readonly) NSString *property;

@property (nonatomic, readonly, weak) id<Bindable> bindable;
@property (nonatomic, readonly) NSString *bindableProperty;
@property (nonatomic, readonly, weak) NSObject *control;

@property (nonatomic, weak) id<PropertyBindingDelegate> delegate;

- (instancetype)initWithEntity:(JSONEntity *)entity context:(NSString *)context property:(NSString *)property;

- (PropertyBinding *)bind:(id<Bindable>)bindable property:(NSString *)property;
- (PropertyBinding *)attachControl:(NSObject *)control;

- (id)value;
- (void)setValue:(id)value;

- (id)contextValue;
- (JSONEntity *)contextEntity;
- (NSString *)contextEntityBinding;

- (NSArray *)contextEntities;
- (NSArray *)contextEntitiyBindings;
- (NSArray *)contextObjects;
- (NSArray *)contextObjectsBindings;

- (void)update;
- (void)refresh;
- (void)refresh:(BOOL)force;
- (void)refresh:(BOOL)force trigger:(PropertyBinding *)trigger;
- (void)refresh:(BOOL)force trigger:(PropertyBinding *)trigger userInfo:(NSDictionary *)userInfo;
- (void)invalidate;
- (void)validate;

- (BOOL)isContextBinding;

- (id)source;

@end