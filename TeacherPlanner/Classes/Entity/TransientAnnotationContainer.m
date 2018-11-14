//
//  TransientAnnotationContainer.m
//  TeacherPlanner
//
//  Created by Oliver Klemenz on 25.05.15.
//
//

#import "TransientAnnotationContainer.h"
#import "Model.h"
#import "Application.h"

@interface TransientAnnotationContainer ()
@end

@implementation TransientAnnotationContainer {
    NSMutableDictionary *_annotationsByEntityUUID;
    NSMutableArray *_entityUUID;
    NSMutableDictionary *_entityByUUID;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        if (!self.annotation) {
            self.annotation = [@[] mutableCopy];
        }
        _annotationsByEntityUUID = [@{} mutableCopy];
        _entityUUID = [@[] mutableCopy];
        _entityByUUID = [@{} mutableCopy];
    }
    return self;
}

- (void)setAnnotation:(NSMutableArray<Annotation> *)annotation {
    _annotation = annotation;
    for (Annotation *annotation in self.annotation) {
        [self setupAnnotation:annotation];
    }
    [self sortAnnotation];
}

- (void)setupAnnotation:(Annotation *)annotation {
    JSONEntity *entity = annotation.entity;
    NSMutableArray *entityAnnotations = _annotationsByEntityUUID[entity.uuid];
    if (!entityAnnotations) {
        entityAnnotations = [@[] mutableCopy];
        _annotationsByEntityUUID[entity.uuid] = entityAnnotations;
        [_entityUUID addObject:entity.uuid];
        _entityByUUID[entity.uuid] = entity;
    }
    [entityAnnotations insertObject:annotation atIndex:0];
}

- (void)handleAnnotation:(Annotation *)annotation {
    [self setupAnnotation:annotation];
}

- (Annotation *)addAnnotation:(NSDictionary *)parameters {
    Annotation *annotation = [self.delegate addAnnotation:parameters];
    [annotation scheduleReminder:self.date offset:nil];
    [self insertAnnotation:annotation];
    return annotation;
}

- (void)insertAnnotation:(Annotation *)annotation {
    [self handleAnnotation:annotation];
    [self.annotation addObject:annotation];
}

- (void)updateAnnotation:(Annotation *)annotation parameters:(NSDictionary *)parameters {
    [self.delegate updateAnnotation:annotation parameters:parameters];
}

- (void)removeAnnotationByUUID:(NSString *)uuid {
    [self removeAnnotation:[self annotationByUUID:uuid]];
}

- (void)removeAnnotation:(Annotation *)annotation {
    [self.delegate removeAnnotation:annotation];
    [self.annotation removeObject:annotation];
    JSONEntity *entity = annotation.entity;
    [_annotationsByEntityUUID[entity.uuid] removeObject:annotation];
    if ([_annotationsByEntityUUID[entity.uuid] count] == 0) {
        [_annotationsByEntityUUID removeObjectForKey:entity.uuid];
        [_entityUUID removeObject:entity.uuid];
        [_entityByUUID removeObjectForKey:entity.uuid];
    }
}

#pragma mark ANNOTATION DATASOURCE

- (JSONEntity *)dictionaryEntity {
    return [Model instance].application;
}

- (NSString *)dictionaryAggregation {
    return @"word";
}

- (NSInteger)numberOfAnnotation {
    return self.annotation.count;
}

- (NSInteger)numberOfAnnotationGroup {
    return _entityUUID.count;
}

- (NSString *)annotationGroupName:(NSInteger)group {
    if (group >= 0 && group < _entityUUID.count) {
        NSString *entityUUID = _entityUUID[group];
        JSONEntity *entity = _entityByUUID[entityUUID];
        return [self groupName:entity];
    }
    return nil;
}

- (NSInteger)numberOfAnnotationByGroup:(NSInteger)group {
    if (group < _entityUUID.count) {
        NSString *entityUUID = _entityUUID[group];
        return [_annotationsByEntityUUID[entityUUID] count];
    }
    return 0;
}

- (NSInteger)numberOfAnnotationByGroupName:(NSString *)groupName {
    for (NSInteger group = 0; group < [self numberOfAnnotationGroup]; group++) {
        if ([[self annotationGroupName:group] isEqualToString:groupName]) {
            return [self numberOfAnnotationByGroup:group];
        }
    }
    return 0;
}

- (NSIndexPath *)annotationGroupIndexByUUID:(NSString *)uuid {
    NSInteger group = 0;
    for (NSString *entityUUID in _entityUUID) {
        NSInteger index = 0;
        for (Annotation *annotation in _annotationsByEntityUUID[entityUUID]) {
            if ([annotation.uuid isEqualToString:uuid]) {
                return [NSIndexPath indexPathForRow:index inSection:group];
            }
            index++;
        }
        group++;
    }
    return nil;
}

- (Annotation *)annotationByGroup:(NSInteger)group index:(NSInteger)index {
    if (group >= 0 && group < _entityUUID.count) {
        NSString *entityUUID = _entityUUID[group];
        if (index >= 0 && index < [_annotationsByEntityUUID[entityUUID] count]) {
            return _annotationsByEntityUUID[entityUUID][index];
        }
    }
    return nil;
}

- (Annotation *)annotationByUUID:(NSString *)uuid {
    for (Annotation *annotation in self.annotation) {
        if ([annotation.uuid isEqual:uuid]) {
            return annotation;
        }
    }
    return nil;
}

- (void)sortAnnotation {
    [self.annotation sortUsingComparator:^NSComparisonResult(Annotation *annotation1, Annotation *annotation2) {
        return -[annotation1.createdAt compare:annotation2.createdAt];
    }];
    [_entityUUID sortUsingComparator:^NSComparisonResult(NSString *entityUUID1, NSString *entityUUID2) {
        return [[self groupName:self->_entityByUUID[entityUUID1]] compare:[self groupName:self->_entityByUUID[entityUUID2]]];
    }];
}

- (NSString *)groupName:(JSONEntity *)entity {
    if (entity) {
        if (!entity.parent || !entity.parent.parent) {
            return [NSString stringWithFormat:@"%@: %@", NSLocalizedString(NSStringFromClass(entity.class), @""), entity.name];
        } else if (entity.parent) {
            NSString *groupName = [NSString stringWithFormat:@"%@: %@ (", NSLocalizedString(NSStringFromClass(entity.class), @""), entity.name];
            JSONEntity *currentEntity = entity.parent;
            BOOL first = YES;
            while (currentEntity && currentEntity.parent) {
                if (first) {
                    groupName = [groupName stringByAppendingFormat:@"%@", currentEntity.name];
                } else {
                    groupName = [groupName stringByAppendingFormat:@" - %@", currentEntity.name];
                }
                currentEntity = currentEntity.parent;
                first = NO;
            }
            return [groupName stringByAppendingString:@")"];
        }
    }
    return @"";
}

- (NSDate *)dateForReminderLesson:(CodeReminderLesson)reminderLesson {
    if (self.delegate) {
        return [self.delegate dateForReminderLesson:reminderLesson];
    }
    if ([self.parent conformsToProtocol:@protocol(AnnotationReminderLesson)]) {
        return [(JSONEntity<AnnotationReminderLesson> *)self.parent dateForReminderLesson:reminderLesson];
    }
    return nil;
}

- (NSString *)entityAggregation {
    return @"annotation";
}

@end
