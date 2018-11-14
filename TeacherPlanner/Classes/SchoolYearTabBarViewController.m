//
//  SchoolYearTabBarViewController.m
//  TeacherPlanner
//
//  Created by Oliver on 04.05.14.
//
//

#import "SchoolYearTabBarViewController.h"
#import "SchoolYearGeneralViewController.h"
#import "SchoolYearTimeTableViewController.h"
#import "SchoolYearVacationPlanViewController.h"
#import "SchoolYearAnnotationViewController.h"

@interface SchoolYearTabBarViewController ()

@end

@implementation SchoolYearTabBarViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        SchoolYearGeneralViewController *schoolYearGeneralViewController = [SchoolYearGeneralViewController new];
        SchoolYearTimeTableViewController *schoolYearTimeTableViewController = [SchoolYearTimeTableViewController new];
        SchoolYearVacationPlanViewController *schoolYearVacationPlanViewController = [SchoolYearVacationPlanViewController new];
        SchoolYearAnnotationViewController *schoolYearAnnotationViewController = [SchoolYearAnnotationViewController new];
        
        [self setViewControllers:@[[schoolYearGeneralViewController embedInNavigationController],
                                   [schoolYearTimeTableViewController embedInNavigationController],
                                   [schoolYearVacationPlanViewController embedInNavigationController],
                                   [schoolYearAnnotationViewController embedInNavigationController]]];
    }
    return self;
}

@end