//
//  Data.h
//  TeacherPlanner
//
//  Created by Oliver on 17.05.14.
//
//

#import <Foundation/Foundation.h>
#import "JSONTransientEntity.h"
#import "RSDayFlow.h"

extern NSInteger const DataCalendarDatePublicHoliday;
extern NSInteger const DataCalendarDateVacation;

@interface TransientCustomData : JSONTransientEntity

- (NSArray *)infoForDate:(NSDate *)refDate inDatePickerView:(RSDFDatePickerView *)datePickerView;

@end
