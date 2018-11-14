//
//  School.h
//  TeacherPlanner
//
//  Created by Oliver on 17.05.14.
//
//

#import "JSONChildEntity.h"
#import "SchoolTime.h"

@interface School : JSONChildEntity

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *country;
@property (nonatomic) NSInteger state;
@property (nonatomic, strong) NSString *address;
@property (nonatomic) NSInteger schoolWeekdays;
@property (nonatomic, strong) NSMutableArray<SchoolTime> *schoolTime;

- (NSInteger)numberOfSchoolTime;
- (NSInteger)schoolTimeIndexByUUID:(NSString *)uuid;
- (SchoolTime *)schoolTimeByIndex:(NSInteger)index;
- (SchoolTime *)schoolTimeByUUID:(NSString *)uuid;
- (SchoolTime *)addSchoolTime;
- (void)insertSchoolTime:(SchoolTime *)schoolTime;
- (void)removeSchoolTimeByUUID:(NSString *)uuid;
- (void)removeSchoolTime:(SchoolTime *)schoolTime;
- (void)sortSchoolTime;
- (void)adjustSchoolTimesAfter:(SchoolTime *)refSchoolTime delta:(NSDateComponents *)delta;

@end