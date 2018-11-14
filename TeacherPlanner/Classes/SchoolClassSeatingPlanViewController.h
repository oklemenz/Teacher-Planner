//
//  SchoolClassSeatingPlanViewController.h
//  TeacherPlanner
//
//  Created by Oliver on 17.05.14.
//
//

#import <UIKit/UIKit.h>
#import "AbstractBaseViewController.h"

@class SchoolClass;

@interface SchoolClassSeatingPlanViewController : AbstractBaseViewController

+ (NSString *)generatePDFSeatingPlan:(SchoolClass *)schoolClass folder:(NSString *)folder;
+ (NSString *)generatePDFSeatingPlan:(SchoolClass *)schoolClass path:(NSString *)path;

@end