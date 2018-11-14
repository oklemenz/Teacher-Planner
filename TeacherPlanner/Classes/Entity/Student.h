//
//  Student.h
//  TeacherPlanner
//
//  Created by Oliver on 29.12.13.
//
//

#import "JSONChildEntity.h"
#import "TileViewControllerDataSource.h"
#import "AnnotationContainer.h"

@class Person;
@class Photo;

@protocol Student
@end

@interface Student : JSONChildEntity <TileViewControllerDataSource, AnnotationReminderLesson>

@property (nonatomic, strong) NSString *personUUID;

@property (nonatomic, strong) NSNumber *positioned;
@property (nonatomic, strong) NSNumber *row;
@property (nonatomic, strong) NSNumber *column;

@property (nonatomic, strong) NSNumber *rating;
@property (nonatomic, strong) NSString *comment;

@property (nonatomic, strong) AnnotationContainer *annotation;

- (Person *)person;
- (Photo *)photo;

- (NSString *)exportCSVString;
- (NSData *)exportCSVData;
- (NSDictionary *)exportXLSData;
- (BOOL)importCSVString:(NSString *)csvString;
- (BOOL)importCSVData:(NSData *)csvData;

+ (NSString *)exportCSVHeaderString;

- (AnnotationContainer *)annotationByUUID:(NSString *)uuid;

@end