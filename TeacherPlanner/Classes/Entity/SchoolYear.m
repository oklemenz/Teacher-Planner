//
//  SchoolYear.m
//  TeacherPlanner
//
//  Created by Oliver on 29.12.13.
//
//

#import "SchoolYear.h"
#import "SchoolYearRef.h"
#import "Model.h"
#import "Student.h"
#import "Application.h"
#import "Utilities.h"

@implementation SchoolYear {
    NSMutableArray *_schoolClassNameInitials;
    NSMutableDictionary *_schoolClassesByInitial;
    SchoolYearRef *_schoolYearRef;
    BOOL _suppressProtected;
}

@synthesize name = _name;

- (void)setup:(BOOL)isNew {
    if (!self.annotation) {
        self.annotation = [AnnotationContainer new];
    }
    self.annotation.parent = self;
    
    if (!self.schoolClass) {
        self.schoolClass = [@[] mutableCopy];
    }

    _schoolClassNameInitials = [@[ @"" ] mutableCopy];
    _schoolClassesByInitial = [@{ @"" : [@[] mutableCopy] } mutableCopy];

    if (isNew) {
        _schoolYearRef = [SchoolYearRef new];
        _schoolYearRef.uuid = self.uuid;
        NSDateComponents *components = [[Utilities calendar] components:NSCalendarUnitYear fromDate:[NSDate date]];
        int year = (int)[components year];
        _schoolYearRef.name = [NSString stringWithFormat:@"%i / %i", year, year+1];
        _schoolYearRef.isActive = @(NO);
        _schoolYearRef.isPlanned = @(YES);
        _mergeLessonCells = @(NO);
    } else {
        _schoolYearRef = [[Model instance].application schoolYearRefByUUID:self.uuid];
        _schoolYearRef.isActive = self.isActive;
        _schoolYearRef.isPlanned = self.isPlanned;
    }
    
    for (SchoolClass *schoolClass in self.schoolClass) {
        schoolClass.parent = self;
    }
    [self sortSchoolClass];
}

#pragma mark - SCHOOL YEAR REF

- (NSString *)name {
    return self.ref.name;
}

- (void)setName:(NSString *)name {
    if ([_name isEqualToString:name]) {
        return;
    }
    [self.ref setProperty:@"name" value:name];
}

- (NSNumber *)isActive {
    return self.ref.isActive;
}

- (void)setIsActive:(NSNumber *)isActive {
    if ([self.isActive boolValue] == [isActive boolValue]) {
        return;
    }
    [self.ref setProperty:@"isActive" value:isActive];
    if ([isActive boolValue]) {
        [self setProperty:@"isPlanned" value:@(NO)];
    }
}

- (NSNumber *)isPlanned {
    return self.ref.isPlanned;
}

- (void)setIsPlanned:(NSNumber *)isPlanned {
    if ([self.isPlanned boolValue] == [isPlanned boolValue]) {
        return;
    }
    [self.ref setProperty:@"isPlanned" value:isPlanned];
    if ([isPlanned boolValue]) {
        [self setProperty:@"isActive" value:@(NO)];
    }
}

- (BOOL)isProtected {
    return !self.isActive && !self.isPlanned && !_suppressProtected;
}

- (BOOL)suppressProtected {
    return _suppressProtected;
}

- (void)setSuppressProtected:(BOOL)suppressProtected {
    _suppressProtected = suppressProtected;
}

- (SchoolYearRef *)ref {
    return _schoolYearRef;
}

- (CodeSchoolYearType)type {
    return self.ref.type;
}

#pragma mark - SCHOOL CLASS

- (NSInteger)numberOfSchoolClass {
    return _schoolClass.count;
}

- (NSInteger)numberOfSchoolClassGroup {
    return _schoolClassNameInitials.count;
}

- (NSInteger)numberOfSchoolClassByGroup:(NSInteger)group {
    NSString *initial = _schoolClassNameInitials[group];
    if (_schoolClassesByInitial[initial]) {
        return [_schoolClassesByInitial[initial] count];
    }
    return 0;
}

- (NSInteger)numberOfSchoolClassByGroupName:(NSString *)groupName {
    if (_schoolClassesByInitial[groupName]) {
        return [_schoolClassesByInitial[groupName] count];
    }
    return 0;
}

- (NSString *)schoolClassGroupName:(NSInteger)group {
    if (group >= 0 && group < _schoolClassNameInitials.count) {
        return _schoolClassNameInitials[group];
    }
    return nil;
}

- (NSIndexPath *)schoolClassGroupIndexByUUID:(NSString *)uuid {
    NSInteger group = 0;
    for (NSString *initial in _schoolClassNameInitials) {
        NSInteger index = 0;
        for (SchoolYearRef *schoolClass in _schoolClassesByInitial[initial]) {
            if ([schoolClass.uuid isEqualToString:uuid]) {
                return [NSIndexPath indexPathForRow:index inSection:group];
            }
            index++;
        }
        group++;
    }
    return nil;
}

- (SchoolClass *)schoolClassByGroup:(NSInteger)group index:(NSInteger)index {
    if (group >= 0 && group < _schoolClassNameInitials.count) {
        NSString *initial = _schoolClassNameInitials[group];
        if (index >= 0 && index < [_schoolClassesByInitial[initial] count]) {
            return _schoolClassesByInitial[initial][index];
        }
    }
    return nil;
}

- (SchoolClass *)schoolClassByUUID:(NSString *)uuid {
    for (SchoolClass *schoolClass in self.schoolClass) {
        if ([schoolClass.uuid isEqualToString:uuid]) {
            return schoolClass;
        }
    }
    return nil;
}

- (SchoolClass *)addSchoolClass {
    SchoolClass *schoolClass = [SchoolClass new];
    [self insertSchoolClass:schoolClass];
    return schoolClass;
}

- (void)insertSchoolClass:(SchoolClass *)schoolClass {
    [_schoolClassesByInitial[@""] insertObject:schoolClass atIndex:0];
    [self.schoolClass addObject:schoolClass];
    schoolClass.parent = self;
}

- (SchoolClass *)copySchoolClass:(SchoolClass *)schoolClass {
    SchoolClass *schoolClassCopy = [schoolClass copy];
    [self insertSchoolClass:schoolClassCopy];
    return schoolClassCopy;
}

- (void)removeSchoolClassByUUID:(NSString *)uuid {
    [self removeSchoolClass:[self schoolClassByUUID:uuid]];
}

- (void)removeSchoolClass:(SchoolClass *)schoolClass {
    [schoolClass willBeRemoved];
    for (NSString *initial in _schoolClassNameInitials) {
        if ([_schoolClassesByInitial[initial] containsObject:schoolClass]) {
            [_schoolClassesByInitial[initial] removeObject:schoolClass];
            if ([_schoolClassesByInitial[initial] count] == 0 && ![initial isEqualToString:@""]) {
                [_schoolClassesByInitial removeObjectForKey:initial];
                [_schoolClassNameInitials removeObject:initial];
            }
            break;
        }
    }
    [self.schoolClass removeObject:schoolClass];
}

- (void)sortSchoolClass {
    _schoolClassNameInitials = [@[ @"" ] mutableCopy];
    _schoolClassesByInitial = [@{ @"" : [@[] mutableCopy] } mutableCopy];
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    self.schoolClass = [[self.schoolClass sortedArrayUsingDescriptors:@[sort]] mutableCopy];
    
    for (SchoolClass *schoolClass in self.schoolClass) {
        NSString *initial = @"";
        int num;
        BOOL numFound = [[NSScanner scannerWithString:schoolClass.name] scanInt:&num];
        if (numFound) {
            initial = [NSString stringWithFormat:@"%i", num];
        } else {
            if ([[NSScanner scannerWithString:schoolClass.name] scanUpToCharactersFromSet:
                 [NSCharacterSet characterSetWithCharactersInString:@"1234567890,.;:-/\\()[] "] intoString:&initial]) {
            }
        }
        NSMutableArray *schoolClassesByInitial = _schoolClassesByInitial[initial];
        if (!schoolClassesByInitial) {
            schoolClassesByInitial = [@[] mutableCopy];
            _schoolClassesByInitial[initial] = schoolClassesByInitial;
            [_schoolClassNameInitials addObject:initial];
        }
        [schoolClassesByInitial addObject:schoolClass];
    }
    
    _schoolClassNameInitials = [[_schoolClassNameInitials sortedArrayUsingSelector:
                                 @selector(localizedCaseInsensitiveCompare:)] mutableCopy];
}

#pragma mark - ANNOTATION

- (AnnotationContainer *)annotationByUUID:(NSString *)uuid {
    if ([self.annotation.uuid isEqual:uuid]) {
        return self.annotation;
    }
    return nil;
}

- (void)willBeRemoved {
    [super willBeRemoved];
    for (SchoolClass *schoolClass in self.schoolClass) {
        [schoolClass willBeRemoved];
    }
}

- (id)copyWithZone:(NSZone *)zone {
    SchoolYear *schoolYearCopy = [SchoolYear new];
    for (SchoolClass *schoolClass in self.schoolClass) {
        SchoolClass *schoolClassCopy = [schoolClass copy];
        if ([schoolClassCopy.name hasSuffix:@"*"]) {
            schoolClassCopy.name = [schoolClassCopy.name substringToIndex:schoolClassCopy.name.length - 1];
        }
        [schoolYearCopy insertSchoolClass:schoolClassCopy];
    }
    [schoolYearCopy setup:YES];
    schoolYearCopy.name = [NSString stringWithFormat:@"%@*", self.name];
    schoolYearCopy.isActive = @(NO);
    schoolYearCopy.isPlanned = @(YES);
    schoolYearCopy.mergeLessonCells = self.mergeLessonCells;
    return schoolYearCopy;
}

- (NSDate *)dateForReminderLesson:(CodeReminderLesson)reminderLesson {
    NSMutableArray *dates = [@[] mutableCopy];
    
    for (SchoolClass *schoolClass in self.schoolClass) {
        NSDate *date = [schoolClass dateForReminderLesson:reminderLesson];
        if (date) {
            [dates addObject:date];
        }
    }
    
    NSArray *sortedDates = [dates sortedArrayUsingComparator:^(NSDate *d1, NSDate *d2) {
        return [d1 compare:d2];
    }];
    
    NSDate *nextDate = nil;
    if (sortedDates.count > 0) {
        switch (reminderLesson) {
            case CodeReminderLessonNext:
            case CodeReminderLessonAfterNext:
            case CodeReminderLessonFirstNextWeek:
            case CodeReminderLessonFirstWeekAfterNext:
                nextDate = sortedDates[0];
                break;
            case CodeReminderLessonLastThisWeek:
            case CodeReminderLessonLastNextWeek:
            case CodeReminderLessonLastWeekAfterNext:
                nextDate = sortedDates[sortedDates.count - 1];
                break;
        }
    }
    return nextDate;
}

@end