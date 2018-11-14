//
//  ModelBase.m
//  TeacherPlanner
//
//  Created by Oliver Klemenz on 18.01.15.
//
//

#import "ModelBase.h"
#import "Utilities.h"
#import "NSString+Extension.h"

NSString * const ModelDidLoadNotification = @"ModelDidLoadNotification";
NSString * const ModelDidStoreNotification = @"ModelDidStoreNotification";
NSString * const ModelDidChangeNotification = @"ModelDidChangeNotification";
NSString * const ModelDidRemoveEntityNotification = @"ModelDidRemoveEntityNotification";

@interface ModelBase ()

@property (nonatomic, strong) NSMutableSet *deleteEntityUUID;

@end

@implementation ModelBase

- (instancetype)init {
    self = [super init];
    if (self) {
        self.deleteEntityUUID = [NSMutableSet new];
    }
    return self;
}

- (NSString *)load:(NSString *)uuid {
    [[NSNotificationCenter defaultCenter] postNotificationName:ModelDidLoadNotification object:self];
    return uuid;
}

- (BOOL)store {
    BOOL success = YES;
    for (NSString *deleteEntityUUID in [self.deleteEntityUUID copy]) {
        if ([Utilities deleteEntity:deleteEntityUUID folder:self.root.uuid]) {
            [self.deleteEntityUUID removeObject:deleteEntityUUID];
        } else {
            success = NO;
        }
    }
    if (success) {
        [self.deleteEntityUUID removeAllObjects];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:ModelDidStoreNotification object:self];
    return success;
}

- (void)setRoot:(JSONRootEntity *)root {
    BOOL changed = [_root isEqual:root];
    _root = root;
    if (changed) {
        [self fireModelChanged];
    }
}

- (BOOL)exportData {
    return NO;
}

- (void)clear {
    if (self.root) {
        self.root = nil;
        [self fireModelChanged];
    }
}

- (void)cleanup {
}

- (JSONEntity *)entityByPath:(NSString *)entityPath {
    JSONEntity *entity = self.root;
    for (NSDictionary *entityPathPart in [Utilities deserializeJSONToObject:entityPath]) {
        NSString *aggregationName = [entityPathPart[@"entity"] uncapitalize];
        NSString *entityUUID = entityPathPart[@"uuid"];
        entity = [entity aggregation:aggregationName uuid:entityUUID];
    }
    return entity;
}

- (BOOL)isLoaded {
    return self.root != nil;
}

- (void)markEntityForDelete:(NSString *)entityName uuid:(NSString *)uuid {
    [self.deleteEntityUUID addObject:uuid];
    [[NSNotificationCenter defaultCenter] postNotificationName:ModelDidRemoveEntityNotification
                                                        object:self userInfo:@{ @"entityName" : entityName,
                                                                                @"uuid" : uuid }];
}

- (void)fireModelChanged {
    [[NSNotificationCenter defaultCenter] postNotificationName:ModelDidChangeNotification object:self];
}

@end