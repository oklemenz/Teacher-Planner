//
//  SchoolYearRef.h
//  TeacherPlanner
//
//  Created by Oliver on 29.12.13.
//
//

#import "JSONChildEntity.h"
#import "Codes.h"

@class SchoolYear;
@protocol SchoolYearRef
@end

@interface SchoolYearRef : JSONChildEntity

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *isActive;
@property (nonatomic, strong) NSNumber *isPlanned;

- (SchoolYear *)schoolYear;
- (CodeSchoolYearType)type;
   
@end
