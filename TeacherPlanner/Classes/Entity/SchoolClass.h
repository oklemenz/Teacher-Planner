//
//  SchoolClass.h
//  TeacherPlanner
//
//  Created by Oliver on 29.12.13.
//
//

#import "JSONChildEntity.h"
#import "Lesson.h"
#import "Student.h"
#import "Annotation.h"
#import "AnnotationContainer.h"

#define kSchoolClassDefaultColor [UIColor colorWithRed:255.0/255.0f green:255.0/255.0f blue:255.0/255.0f alpha:1.0f]

@class Photo;
@class Student;

@protocol SchoolClass
@end

@interface SchoolClass : JSONChildEntity <AnnotationReminderLesson>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *subject;
@property (nonatomic, strong) NSString *photoUUID;
@property (nonatomic, strong) NSMutableArray<Lesson> *lesson;
@property (nonatomic, strong) NSMutableArray<Student> *student;
@property (nonatomic, strong) AnnotationContainer *annotation;
@property (nonatomic, strong) NSString *classroom;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) NSString *comment;

- (Photo *)getPhoto;

- (NSInteger)numberOfLesson;
- (NSInteger)lessonIndexByUUID:(NSString *)uuid;
- (Lesson *)lessonByIndex:(NSInteger)index;
- (Lesson *)lessonByUUID:(NSString *)uuid;
- (Lesson *)addLesson;
- (void)insertLesson:(Lesson *)lesson;
- (void)removeLessonByUUID:(NSString *)uuid;
- (void)removeLesson:(Lesson *)lesson;
- (void)sortLesson;

- (NSInteger)numberOfStudent;
- (NSInteger)numberOfStudentGroup;
- (NSInteger)numberOfStudentByGroup:(NSInteger)group;
- (NSInteger)numberOfStudentByGroupName:(NSString *)groupName;
- (NSString *)studentGroupName:(NSInteger)group;
- (NSIndexPath *)studentGroupIndexByUUID:(NSString *)uuid;
- (Student *)studentByGroup:(NSInteger)group index:(NSInteger)index;
- (Student *)studentByUUID:(NSString *)uuid;
- (Student *)addStudent:(NSDictionary *)parameters;
- (void)insertStudent:(Student *)student;
- (void)removeStudentByUUID:(NSString *)uuid;
- (void)removeStudent:(Student *)student;
- (void)sortStudent;

- (AnnotationContainer *)annotationByUUID:(NSString *)uuid;

- (void)clearStudentPositions;
- (NSString *)exportCSVString;
- (NSData *)exportCSVData;
- (NSDictionary *)exportXLSData;
- (BOOL)importCSVString:(NSString *)csvString;
- (BOOL)importCSVData:(NSData *)csvData;
- (void)importXLSData:(NSURL *)xlsData;

+ (NSString *)exportSchoolClass:(SchoolClass *)schoolClass password:(NSString *)password temp:(BOOL)temp;
+ (SchoolClass *)importSchoolClass:(NSString *)path password:(NSString *)password;

@end