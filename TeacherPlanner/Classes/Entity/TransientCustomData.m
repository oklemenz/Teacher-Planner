//
//  Data.m
//  TeacherPlanner
//
//  Created by Oliver on 17.05.14.
//
//

#import "TransientCustomData.h"
#import "Model.h"
#import "Application.h"
#import "Settings.h"
#import "School.h"
#import "RSDFDatePickerView.h"
#import "Codes.h"

NSInteger const DataCalendarDatePublicHoliday = 1;
NSInteger const DataCalendarDateVacation = 2;

@implementation TransientCustomData {
    NSMutableDictionary *_calendarForYear;
}

- (instancetype)init {
    // New entity instance
    self = [super init];
    if (self) {
        _calendarForYear = [@{} mutableCopy];
    }
    return self;
}

- (NSArray *)infoForDate:(NSDate *)refDate inDatePickerView:(RSDFDatePickerView *)datePickerView {
    RSDFDatePickerDate date = [datePickerView pickerDateFromDate:refDate];
    NSDictionary *calendarData = _calendarForYear[@(date.year)];
    if (!calendarData) {
        NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
        NSString *path = [resourcePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%tu.json", date.year]];
        NSError *error = nil;
        NSData *jsonData = [NSData dataWithContentsOfFile:path options:kNilOptions error:&error];
        if (!error) {
            calendarData = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
            if (!error) {
                _calendarForYear[@(date.year)] = calendarData;
            }
        }
    }
    NSMutableArray *info = [@[] mutableCopy];
    if (calendarData) {
        NSInteger state = [Model instance].application.settings.school.state;
        // TODO: Does not work if states are translated: Use codes instead in data format
        NSString *stateName = [Codes textForCode:@"CodeGermanyState" value:state];
        if (stateName) {
            NSArray *entries = calendarData[stateName];
            for (NSDictionary *entry in entries) {
                
                NSInteger type = [entry[@"type"] integerValue];
                NSString *name = NSLocalizedString(entry[@"name"], @"");
                
                NSDate *startDate = nil;
                NSDate *endDate = nil;

                NSInteger startYear = [entry[@"start"][@"year"] integerValue];
                NSInteger startMonth = [entry[@"start"][@"month"] integerValue];
                NSInteger startDay = [entry[@"start"][@"day"] integerValue];

                NSInteger endYear = [entry[@"end"][@"year"] integerValue];
                NSInteger endMonth = [entry[@"end"][@"month"] integerValue];
                NSInteger endDay = [entry[@"end"][@"day"] integerValue];
                
                if (type == DataCalendarDatePublicHoliday) {
                    RSDFDatePickerDate start = (RSDFDatePickerDate) {
                        startYear,
                        startMonth,
                        startDay
                    };
                    startDate = [datePickerView dateFromPickerDate:start];
                } else if (type == DataCalendarDateVacation) {
                    RSDFDatePickerDate start = (RSDFDatePickerDate) {
                        startYear,
                        startMonth,
                        startDay
                    };
                    RSDFDatePickerDate end = (RSDFDatePickerDate) {
                        endYear,
                        endMonth,
                        endDay
                    };
                    startDate = [datePickerView dateFromPickerDate:start];
                    endDate = [datePickerView dateFromPickerDate:end];
                }
                
                NSInteger resultStart = [refDate compare:startDate];
                NSInteger resultEnd = [refDate compare:endDate];
                
                if ((type == DataCalendarDateVacation && (resultStart == NSOrderedSame || resultStart == NSOrderedDescending) && resultEnd == NSOrderedAscending) || (type == DataCalendarDatePublicHoliday && resultStart == NSOrderedSame)) {
                    [info addObject:@{ @"name" : name,
                                       @"mark" : @(type == DataCalendarDatePublicHoliday) }];
                }
            }
        }
    }
    return info;
}

@end
