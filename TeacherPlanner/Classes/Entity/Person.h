//
//  Person.h
//  TeacherPlanner
//
//  Created by Oliver on 29.12.13.
//
//

#import "JSONRootEntity.h"
#import "AnnotationContainer.h"

@class PersonRef;
@class Photo;

@protocol Person
@end

@interface Person : JSONRootEntity

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *photoUUID;

@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *email;

@property (nonatomic, strong) NSString *comment;

@property (nonatomic) NSInteger useCount;

@property (nonatomic, strong) AnnotationContainer *annotation;
- (AnnotationContainer *)annotationByUUID:(NSString *)uuid;

- (PersonRef *)ref;
- (Photo *)photo;
- (NSString *)nameInitials;

@end