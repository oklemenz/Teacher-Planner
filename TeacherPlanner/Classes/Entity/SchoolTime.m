//
//  SchoolTime.m
//  TeacherPlanner
//
//  Created by Oliver on 01.06.14.
//
//

#import "SchoolTime.h"
#import "School.h"
#import "Utilities.h"

@implementation SchoolTime

- (void)setup:(BOOL)isNew {
    if (isNew) {
        NSDateComponents *components = [NSDateComponents new];
        components.hour = 8;
        components.minute = 0;
        components.second = 0;
        self.startTime = [[Utilities calendar] dateFromComponents:components];
        self.endTime = self.startTime;
    }
}

- (NSString *)name {
    if ([self.startTime compare:self.endTime] == NSOrderedSame) {
        return self.startTimeText;
    } else {
        return [NSString stringWithFormat:@"%@ %@ %@", self.startTimeText,
                NSLocalizedString(@"to", @""), self.endTimeText];
    }
}

- (NSString *)shortName {
    return [[Utilities timeFormatter] stringFromDate:(NSDate *)self.startTime];
}

- (void)setStartTime:(NSDate *)startTime {
    if (startTime && _startTime) {
        NSDateComponents *delta = [[Utilities calendar] components:NSCalendarUnitHour | NSCalendarUnitMinute fromDate:_startTime toDate:startTime options:0];
        _startTime = startTime;
        [self setProperty:@"endTime" value:[[Utilities calendar] dateByAddingComponents:delta toDate:self.endTime options:0]];
    } else {
        _startTime = startTime;
    }
}

- (NSString *)startTimeText {
    return [[Utilities timeFormatter] stringFromDate:(NSDate *)self.startTime];
}

- (void)setEndTime:(NSDate *)endTime {
    if (endTime && _endTime) {
        NSDateComponents *delta = [[Utilities calendar] components:NSCalendarUnitHour | NSCalendarUnitMinute
                                                          fromDate:_endTime
                                                            toDate:endTime
                                                           options:0];
        _endTime = endTime;
        [(School *)self.parent adjustSchoolTimesAfter:self delta:delta];
    } else {
        _endTime = endTime;
    }
}

- (NSString *)endTimeText {
    return [[Utilities timeFormatter] stringFromDate:(NSDate *)self.endTime];
}

- (void)setDefaultEndTime {
    self.endTime = [[Utilities calendar] dateByAddingComponents:((^{
        NSDateComponents *components = [NSDateComponents new];
        components.minute = 45;
        return components;
    })()) toDate:self.startTime options:0];
}

- (void)setEndTimeWithDelta:(NSDateComponents *)delta {
    self.endTime = [[Utilities calendar] dateByAddingComponents:delta toDate:self.startTime options:0];
}

@end