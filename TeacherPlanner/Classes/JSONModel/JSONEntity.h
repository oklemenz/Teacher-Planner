//
//  JSONEntity.h
//  JSONModelTest
//
//  Created by Oliver on 26.09.13.
//
//

#import "JSONModel.h"

@class PropertyBinding;

@interface JSONEntity : JSONModel<NSCopying>

@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, strong) NSDate *changedAt;

- (void)setup:(BOOL)isNew;

+ (id)load:(NSString *)uuid;
- (BOOL)store;
- (BOOL)exportData;

- (NSString *)name;
- (NSString *)shortName;
- (NSString *)photoUUID;

- (JSONEntity *)parent;
- (void)setParent:(JSONEntity *)parent;

- (id)getProperty:(NSString *)name;
- (void)setProperty:(NSString *)name value:(id)value;
- (void)setProperty:(NSString *)name value:(id)value trigger:(PropertyBinding *)trigger;
- (void)setProperty:(NSString *)name value:(id)value force:(BOOL)force;
- (void)setProperty:(NSString *)name value:(id)value trigger:(PropertyBinding *)trigger force:(BOOL)force;

- (void)invalidateProperty:(NSString *)name;
- (void)invalidateProperty:(NSString *)context userInfo:(NSDictionary *)userInfo;
- (void)invalidateProperty:(NSString *)context trigger:(PropertyBinding *)trigger;
- (void)invalidateProperty:(NSString *)context trigger:(PropertyBinding *)trigger userInfo:(NSDictionary *)userInfo;

- (NSInteger)numberOfAggregation:(NSString *)name;
- (NSInteger)numberOfAggregationGroup:(NSString *)name;
- (NSInteger)numberOfAggregation:(NSString *)name group:(NSInteger)group;
- (NSInteger)numberOfAggregation:(NSString *)name groupName:(NSString *)groupName;
- (NSString *)aggregationGroupName:(NSString *)name group:(NSInteger)group;
- (NSIndexPath *)aggregationGroupIndex:(NSString *)name uuid:(NSString *)uuid;
- (NSInteger)aggregationIndex:(NSString *)name uuid:(NSString *)uuid;
- (id)aggregation:(NSString *)name group:(NSInteger)group index:(NSInteger)index;
- (id)aggregation:(NSString *)name index:(NSInteger)index;
- (id)aggregation:(NSString *)name uuid:(NSString *)uuid;
- (id)addAggregation:(NSString *)name;
- (id)addAggregation:(NSString *)name parameters:(NSDictionary *)parameters;
- (id)addAggregation:(NSString *)name trigger:(PropertyBinding *)trigger;
- (id)addAggregation:(NSString *)name parameters:(NSDictionary *)parameters trigger:(PropertyBinding *)trigger;
- (void)insertAggregation:(NSString *)name object:(id)object;
- (void)insertAggregation:(NSString *)name object:(id)object trigger:(PropertyBinding *)trigger;
- (void)removeAggregation:(NSString *)name object:(id)object;
- (void)removeAggregation:(NSString *)name object:(id)object trigger:(PropertyBinding *)trigger;
- (void)removeAggregation:(NSString *)name uuid:(NSString *)uuid;
- (void)removeAggregation:(NSString *)name uuid:(NSString *)uuid trigger:(PropertyBinding *)trigger;
- (void)clearAggregation:(NSString *)name;
- (void)clearAggregation:(NSString *)name trigger:(PropertyBinding *)trigger;
- (void)updateAggregation:(NSString *)name object:(id)object action:(NSString *)action;
- (void)updateAggregation:(NSString *)name object:(id)object action:(NSString *)action parameters:(NSDictionary *)parameters;
- (void)updateAggregation:(NSString *)name object:(id)object action:(NSString *)action trigger:(PropertyBinding *)trigger;
- (void)updateAggregation:(NSString *)name object:(id)object action:(NSString *)action parameters:(NSDictionary *)parameters trigger:(PropertyBinding *)trigger;
- (id)callAggregation:(NSString *)name object:(id)object action:(NSString *)action;
- (id)callAggregation:(NSString *)name object:(id)object action:(NSString *)action parameters:(NSDictionary *)parameters;
- (id)callAggregation:(NSString *)name object:(id)object action:(NSString *)action trigger:(PropertyBinding *)trigger;
- (id)callAggregation:(NSString *)name object:(id)object action:(NSString *)action parameters:(NSDictionary *)parameters trigger:(PropertyBinding *)trigger;
- (void)filterAggregation:(NSString *)name bySearchText:(NSString *)searchText;
- (void)resetFilterAggregation:(NSString *)name;
- (NSArray *)aggregationIndex:(NSString *)name;

- (void)invalidateContext:(NSString *)context;
- (void)invalidateContext:(NSString *)context userInfo:(NSDictionary *)userInfo;
- (void)invalidateContext:(NSString *)context trigger:(PropertyBinding *)trigger;
- (void)invalidateContext:(NSString *)context trigger:(PropertyBinding *)trigger userInfo:(NSDictionary *)userInfo;

- (void)refresh;

- (BOOL)isDirty;
- (void)markDirty;
- (void)markDirty:(BOOL)dirty;
- (BOOL)isProtected;
- (BOOL)suppressProtected;
- (void)setSuppressProtected:(BOOL)suppressProtected;
- (void)willBeRemoved;

- (NSSet *)bindings;
- (NSSet *)propertyBindings;
- (NSSet *)contextBindings;
- (void)bind:(PropertyBinding *)propertyBinding;
- (void)unbind:(PropertyBinding *)propertyBinding;
- (void)unbindAll;

- (void)validate;
- (NSString *)entityAggregation;
- (NSString *)entityPath;
- (JSONEntity *)entityByEntityPath:(NSString *)entityPath;

+ (NSString *)createUUID;

@end