//
//  Lesson.m
//  TeacherPlanner
//
//  Created by Oliver Klemenz on 14.03.15.
//
//

#import "Lesson.h"
#import "Codes.h"
#import "Model.h"
#import "Application.h"
#import "Settings.h"
#import "School.h"
#import "SchoolTime.h"

@implementation Lesson

- (void)setup:(BOOL)isNew {
    if (isNew) {
    }
}

- (void)setWeekDay:(NSNumber *)weekDay {
    _weekDay = weekDay;
    [self invalidateProperty:@"name"];
    [self invalidateProperty:@"shortName"];
}

- (void)setTimeStart:(NSNumber *)timeStart {
    if ([_timeStart isEqual:timeStart]) {
        return;
    }
    _timeStart = timeStart;
    if (!self.timeEnd || [self.timeStart compare:self.timeEnd] == NSOrderedDescending) {
        [self setProperty:@"timeEnd" value:timeStart];
    }
    [self invalidateProperty:@"name"];
    [self invalidateProperty:@"shortName"];
}

- (void)setTimeEnd:(NSNumber *)timeEnd {
    if ([_timeEnd isEqual:timeEnd]) {
        return;
    }
    _timeEnd = timeEnd;
    if (!self.timeStart || [self.timeStart compare:self.timeEnd] == NSOrderedDescending) {
        [self setProperty:@"timeStart" value:timeEnd];
    }
    [self invalidateProperty:@"name"];
}

- (NSString *)name {
    NSString *name = @"";
    NSArray *schoolTimes = [Model instance].application.settings.school.schoolTime;
    if (self.weekDay && self.weekDay.integerValue > 0) {
        NSString *weekDay = [Codes shortTextForCode:kCodeWeekDay value:[self.weekDay integerValue]];
        name = [name stringByAppendingFormat:@"%@ ", weekDay];
    }
    if (self.timeStart) {
        name = [name stringByAppendingFormat:@"(%@.", @(self.timeStart.integerValue + 1)];
    }
    if (self.timeEnd && self.timeEnd != self.timeStart) {
        name = [name stringByAppendingFormat:@"-%@.)", @(self.timeEnd.integerValue + 1)];
    } else if (self.timeStart) {
        name = [name stringByAppendingFormat:@")"];
    }
    if (self.timeStart && self.timeStart.integerValue < schoolTimes.count) {
        NSString *startTimeText = [schoolTimes[self.timeStart.integerValue] startTimeText];
        name = [name stringByAppendingFormat:@" %@", startTimeText];
    }
    if (self.timeEnd && self.timeEnd.integerValue < schoolTimes.count) {
        NSString *endTimeText = [schoolTimes[self.timeEnd.integerValue] endTimeText];
        name = [name stringByAppendingFormat:@"-%@", endTimeText];
    }
    name = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return name.length > 0 ? name : NSLocalizedString(@"New Lesson", @"");
}

- (NSString *)shortName {
    NSString *name = @"";
    NSArray *schoolTimes = [Model instance].application.settings.school.schoolTime;
    if (self.weekDay && self.weekDay.integerValue > 0) {
        NSString *weekDay = [Codes shortTextForCode:kCodeWeekDay value:[self.weekDay integerValue]];
        name = [name stringByAppendingFormat:@"%@: ", weekDay];
    }
    if (self.timeStart && self.timeStart.integerValue < schoolTimes.count) {
        NSString *startTime = [schoolTimes[self.timeStart.integerValue] shortName];
        name = [name stringByAppendingFormat:@"%@", startTime];
    }
    name = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return name.length > 0 ? name : NSLocalizedString(@"New Lesson", @"");
}

- (id)copyWithZone:(NSZone *)zone {
    Lesson *lessonCopy = [Lesson new];
    [lessonCopy setup:YES];
    lessonCopy.weekDay = self.weekDay;
    lessonCopy.timeStart = self.timeStart;
    lessonCopy.timeEnd = self.timeEnd;
    lessonCopy.room = self.room;
    return lessonCopy;
}

@end