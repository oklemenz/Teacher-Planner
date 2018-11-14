//
//  Settings.h
//  TeacherPlanner
//
//  Created by Oliver on 17.05.14.
//
//

#import "JSONChildEntity.h"
#import "Teacher.h"
#import "School.h"

@interface Settings : JSONChildEntity

@property (nonatomic, strong) Teacher *teacher;
@property (nonatomic, strong) School *school;

@property (nonatomic, strong) NSNumber *isPrivate;
@property (nonatomic, strong) NSNumber *promptTouchID;

@end
