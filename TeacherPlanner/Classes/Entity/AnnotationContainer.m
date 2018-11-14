//
//  AnnotationContainer.m
//  TeacherPlanner
//
//  Created by Oliver Klemenz on 21.12.14.
//
//

#import "AnnotationContainer.h"
#import "Utilities.h"
#import "Model.h"
#import "Application.h"

@interface AnnotationContainer ()
@end

@implementation AnnotationContainer {    
    NSMutableDictionary *_annotationsByCreateDay;
    NSMutableArray *_createDay;
}

#pragma mark - ANNOTATION

- (void)setup:(BOOL)isNew {
    if (!self.annotation) {
        self.annotation = [@[] mutableCopy];
    }
    
    _annotationsByCreateDay = [@{} mutableCopy];
    _createDay = [@[] mutableCopy];
    
    for (Annotation *annotation in self.annotation) {
        annotation.parent = self;
        [self setupAnnotation:annotation];
    }
    
    [self sortAnnotation];
}

- (void)setupAnnotation:(Annotation *)annotation {
    NSDate *dayDate = [Utilities dayDateForDate:annotation.createdAt];

    NSMutableArray *createDayAnnotations = _annotationsByCreateDay[dayDate];
    if (!createDayAnnotations) {
        createDayAnnotations = [@[] mutableCopy];
        _annotationsByCreateDay[dayDate] = createDayAnnotations;
        [_createDay addObject:dayDate];
    }
    [createDayAnnotations insertObject:annotation atIndex:0];
}

- (void)handleAnnotation:(Annotation *)annotation {
    [self setupAnnotation:annotation];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:NO];
    [_createDay sortUsingDescriptors:@[sort]];
}

- (Annotation *)addAnnotation:(NSDictionary *)parameters {
    CodeAnnotationType type = [parameters[@"type"] integerValue];
    NSData *data = parameters[@"data"];
    NSData *thumbnail = parameters[@"thumbnail"];
    NSInteger length = [parameters[@"length"] integerValue];
    Annotation *annotation = [[Annotation alloc] initWithType:type data:data thumbnail:thumbnail length:length];
    [self insertAnnotation:annotation];
    return annotation;
}

- (void)insertAnnotation:(Annotation *)annotation {
    [self handleAnnotation:annotation];
    [self.annotation addObject:annotation];
    annotation.parent = self;
}

- (void)updateAnnotation:(Annotation *)annotation parameters:(NSDictionary *)parameters {
    NSData *data = parameters[@"data"];
    NSData *thumbnail = parameters[@"thumbnail"];
    NSInteger length = [parameters[@"length"] integerValue];
    [annotation update:data thumbnail:thumbnail length:length];
}

- (void)removeAnnotationByUUID:(NSString *)uuid {
    [self removeAnnotation:[self annotationByUUID:uuid]];
}

- (void)removeAnnotation:(Annotation *)annotation {
    [self.annotation removeObject:annotation];
    NSDate *dayDate = [Utilities dayDateForDate:annotation.changedAt];
    [_annotationsByCreateDay[dayDate] removeObject:annotation];
    if ([_annotationsByCreateDay[dayDate] count] == 0) {
        [_annotationsByCreateDay removeObjectForKey:dayDate];
        [_createDay removeObject:dayDate];
    }
    [annotation cleanup];
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
    return _createDay.count;
}

- (NSString *)annotationGroupName:(NSInteger)group {
    if (group >= 0 && group < _createDay.count) {
        NSDate *date = (NSDate *)_createDay[group];
        if (date) {
            return [[Utilities relativeDateFormatter] stringFromDate:date];
        }
    }
    return nil;
}

- (NSInteger)numberOfAnnotationByGroup:(NSInteger)group {
    if (group < _createDay.count) {
        NSDate *date = _createDay[group];
        return [_annotationsByCreateDay[date] count];
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
    for (NSDate *createDay in _createDay) {
        NSInteger index = 0;
        for (Annotation *annotation in _annotationsByCreateDay[createDay]) {
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
    if (group >= 0 && group < _createDay.count) {
        NSDate *date = _createDay[group];
        if (index >= 0 && index < [_annotationsByCreateDay[date] count]) {
            return _annotationsByCreateDay[date][index];
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
        return [annotation1.createdAt compare:annotation2.createdAt];
    }];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:NO];
    [_createDay sortUsingDescriptors:@[sort]];
}

- (NSDate *)dateForReminderLesson:(CodeReminderLesson)reminderLesson {
    if ([self.parent conformsToProtocol:@protocol(AnnotationReminderLesson)]) {
        return [(JSONEntity<AnnotationReminderLesson> *)self.parent dateForReminderLesson:reminderLesson];
    }
    return nil;
}

- (NSString *)entityAggregation {
    return @"annotation";
}

@end