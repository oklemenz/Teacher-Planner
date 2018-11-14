//
//  Model.h
//  TeacherPlanner
//
//  Created by Oliver on 30.12.13.
//
//

#import "ModelBase.h"

#define kTeacherPlannerActiveSchoolYear @"TeacherPlannerActiveSchoolYear"
#define kTeacherPlannerWelcomeName      @"TeacherPlannerWelcomeName"
#define kTeacherPlannerTouchID          @"TeacherPlannerTouchID"

@class Application;
@class TransientCustomData;

@interface Model : ModelBase

+ (Model *)instance;
- (Application *)application;

- (TransientCustomData *)transientCustomData;

@end