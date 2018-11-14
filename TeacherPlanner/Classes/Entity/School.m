    //
//  School.m
//  TeacherPlanner
//
//  Created by Oliver on 17.05.14.
//
//

#import "School.h"
#import "Model.h"
#import "Codes.h"
#import "Utilities.h"

@implementation School

- (void)setup:(BOOL)isNew {
    if (isNew) {
        self.schoolWeekdays = CodeSchoolWeekDayMonFri;
    }
    
    if (!self.schoolTime) {
        self.schoolTime = (NSMutableArray<SchoolTime> *)[@[] mutableCopy];
    }

    for (SchoolTime *schoolTime in self.schoolTime) {
        schoolTime.parent = self;
    }
    
    [self sortSchoolTime];
}

#pragma mark - SCHOOL TIME

- (NSInteger)numberOfSchoolTime {
    return self.schoolTime.count;
}

- (NSInteger)schoolTimeIndexByUUID:(NSString *)uuid {
    NSInteger index = 0;
    for (SchoolTime *schooTime in self.schoolTime) {
        if ([schooTime.uuid isEqualToString:uuid]) {
            return index;
        }
        index++;
    }
    return index;
}

- (SchoolTime *)schoolTimeByIndex:(NSInteger)index {
    if (index >= 0 && index < self.schoolTime.count) {
        return [self.schoolTime objectAtIndex:index];
    }
    return nil;
}

- (SchoolTime *)schoolTimeByUUID:(NSString *)uuid {
    for (SchoolTime *schoolTime in self.schoolTime) {
        if ([schoolTime.uuid isEqualToString:uuid]) {
            return schoolTime;
        }
    }
    return nil;
}

- (SchoolTime *)addSchoolTime {
    SchoolTime *schoolTime = [SchoolTime new];
    [self insertSchoolTime:schoolTime];
    return schoolTime;
}

- (void)insertSchoolTime:(SchoolTime *)schoolTime {
    if (self.schoolTime.count != 0) {
        SchoolTime *previousSchoolTime = (SchoolTime *)self.schoolTime[self.schoolTime.count-1];
        schoolTime.startTime = previousSchoolTime.endTime;
        NSDateComponents *delta = [[Utilities calendar] components:NSCalendarUnitHour | NSCalendarUnitMinute
                                                          fromDate:previousSchoolTime.startTime
                                                            toDate:previousSchoolTime.endTime
                                                                options:0];
        [schoolTime setEndTimeWithDelta:delta];
    } else {
        [schoolTime setDefaultEndTime];
    }
    [self.schoolTime addObject:schoolTime];
    schoolTime.parent = self;
}

- (void)removeSchoolTimeByUUID:(NSString *)uuid {
    [self removeSchoolTime:[self schoolTimeByUUID:uuid]];
}

- (void)removeSchoolTime:(SchoolTime *)schoolTime {
    [self.schoolTime removeObject:schoolTime];
}

- (void)sortSchoolTime {
    self.schoolTime = [[self.schoolTime sortedArrayUsingComparator:^NSComparisonResult(id st1, id st2) {
        NSDate *start1 = [(SchoolTime *)st1 startTime];
        NSDate *start2 = [(SchoolTime *)st2 startTime];
        return [start1 compare:start2];
    }] mutableCopy];
}

- (void)adjustSchoolTimesAfter:(SchoolTime *)refSchoolTime delta:(NSDateComponents *)delta {
    BOOL adjust = NO;
    for (SchoolTime *schoolTime in self.schoolTime) {
        if (adjust) {
            [schoolTime setProperty:@"startTime" value:
             [[Utilities calendar] dateByAddingComponents:delta toDate:schoolTime.startTime options:0]];
            break;
        }
        if (schoolTime == refSchoolTime) {
            adjust = YES;
        }
    }
}

@end