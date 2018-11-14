//
//  SchoolTime.h
//  TeacherPlanner
//
//  Created by Oliver on 01.06.14.
//
//

#import "JSONChildEntity.h"

@protocol SchoolTime
@end

@interface SchoolTime : JSONChildEntity

@property(nonatomic, strong) NSDate *startTime;
@property(nonatomic, strong) NSDate *endTime;

- (void)setDefaultEndTime;
- (void)setEndTimeWithDelta:(NSDateComponents *)delta;

- (NSString *)startTimeText;
- (NSString *)endTimeText;

@end