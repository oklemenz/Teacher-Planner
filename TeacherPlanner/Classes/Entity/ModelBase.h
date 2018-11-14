//
//  ModelBase.h
//  TeacherPlanner
//
//  Created by Oliver Klemenz on 18.01.15.
//
//

#import "JSONRootEntity.h"

extern NSString * const ModelDidLoadNotification;
extern NSString * const ModelDidStoreNotification;
extern NSString * const ModelDidChangeNotification;
extern NSString * const ModelDidRemoveEntityNotification;

@interface ModelBase : NSObject

@property(nonatomic, strong) JSONRootEntity *root;

- (NSString *)load:(NSString *)uuid;
- (BOOL)store;
- (BOOL)exportData;
- (void)clear;
- (void)cleanup;

- (JSONEntity *)entityByPath:(NSString *)entityPath;

- (BOOL)isLoaded;

- (void)markEntityForDelete:(NSString *)entityName uuid:(NSString *)uuid;

- (void)fireModelChanged;

@end