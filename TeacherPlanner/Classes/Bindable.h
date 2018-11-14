//
//  Bindable.h
//  TeacherPlanner
//
//  Created by Oliver on 28.06.14.
//
//

@class JSONEntity;
@class PropertyBinding;
@class ContextBinding;

@protocol Bindable <NSObject>

- (id)delegate;

- (PropertyBinding *)bind:(PropertyBinding *)propertyBinding bindableProperty:(NSString *)bindableProperty;
- (PropertyBinding *)bind:(JSONEntity *)entity context:(NSString *)context property:(NSString *)property bindableProperty:(NSString *)bindableProperty;
- (PropertyBinding *)bind:(ContextBinding *)contextBinding property:(NSString *)property bindableProperty:(NSString *)bindableProperty;
- (ContextBinding *)bindContext:(JSONEntity *)entity context:(NSString *)context;
- (ContextBinding *)bindContext:(ContextBinding *)contextBinding;

- (id)getProperty:(NSString *)name;
- (void)setProperty:(NSString *)name value:(id)value;
- (void)setProperty:(NSString *)name value:(id)value force:(BOOL)force;
- (void)setPropertySuppressUpdate:(NSString *)name value:(id)value;
- (void)setPropertySuppressUpdate:(NSString *)name value:(id)value force:(BOOL)force;
- (void)setProperty:(NSString *)name value:(id)value suppressUpdate:(BOOL)suppressUpdate force:(BOOL)force;

- (void)refresh;

- (JSONEntity *)entity;

- (void)setContext:(id)contextValue source:(id)source userInfo:(NSDictionary *)userInfo;

- (NSArray *)bindings;
- (NSArray *)propertyBindings;
- (PropertyBinding *)propertyBinding:(NSString *)bindableName;

- (NSArray *)contextBindings;
- (ContextBinding *)contextBinding;
- (ContextBinding *)entityContextBinding:(JSONEntity *)entity;
- (ContextBinding *)contextEntityContextBinding:(JSONEntity *)contextEntity;
- (ContextBinding *)contextValueContextBinding:(NSObject *)contextValue;

- (void)bind:(PropertyBinding *)propertyBinding;
- (void)unbind:(PropertyBinding *)propertyBinding;
- (void)unbindAll;

- (void)validate;

- (id)source;

@end

@interface Bindable : NSObject

+ (void)setOptions:(id)bindable options:(NSDictionary *)options;

@end