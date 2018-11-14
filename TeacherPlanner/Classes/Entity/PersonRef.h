//
//  PersonRef.h
//  TeacherPlanner
//
//  Created by Oliver on 29.12.13.
//
//

#import "JSONChildEntity.h"

@class Person;
@class Photo;

@protocol PersonRef
@end

@interface PersonRef : JSONChildEntity

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *photoUUID;

- (Person *)person;

- (Photo *)photo;
- (NSString *)nameInitials;

@end