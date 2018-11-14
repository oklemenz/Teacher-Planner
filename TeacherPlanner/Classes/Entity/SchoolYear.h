//
//  SchoolYear.h
//  TeacherPlanner
//
//  Created by Oliver on 29.12.13.
//
//

#import "JSONRootEntity.h"
#import "SchoolClass.h"
#import "AnnotationContainer.h"

@class SchoolYearRef;
@class SchoolClass;

@protocol SchoolYear
@end

@interface SchoolYear : JSONRootEntity <AnnotationReminderLesson>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *isActive;
@property (nonatomic, strong) NSNumber *isPlanned;
@property (nonatomic, strong) NSString *comment;

@property (nonatomic, strong) AnnotationContainer *annotation;
@property (nonatomic, strong) NSMutableArray<SchoolClass> *schoolClass;
@property (nonatomic, strong) NSNumber *mergeLessonCells;

- (SchoolYearRef *)ref;
- (CodeSchoolYearType)type;

- (NSInteger)numberOfSchoolClass;
- (NSInteger)numberOfSchoolClassGroup;
- (NSInteger)numberOfSchoolClassByGroup:(NSInteger)group;
- (NSInteger)numberOfSchoolClassByGroupName:(NSString *)groupName;
- (NSString *)schoolClassGroupName:(NSInteger)group;
- (NSIndexPath *)schoolClassGroupIndexByUUID:(NSString *)uuid;
- (SchoolClass *)schoolClassByGroup:(NSInteger)group index:(NSInteger)index;
- (SchoolClass *)schoolClassByUUID:(NSString *)uuid;
- (SchoolClass *)addSchoolClass;
- (void)insertSchoolClass:(SchoolClass *)schoolClass;
- (SchoolClass *)copySchoolClass:(SchoolClass *)schoolClass;
- (void)removeSchoolClassByUUID:(NSString *)uuid;
- (void)removeSchoolClass:(SchoolClass *)schoolClass;
- (void)sortSchoolClass;

- (AnnotationContainer *)annotationByUUID:(NSString *)uuid;

@end