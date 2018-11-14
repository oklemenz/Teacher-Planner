//
//  SchoolClassTabBarViewController.m
//  TeacherPlanner
//
//  Created by Oliver on 17.05.14.
//
//

#import "SchoolClassTabBarViewController.h"
#import "SchoolClassGeneralViewController.h"
#import "SchoolClassSeatingPlanViewController.h"
#import "SchoolClassTeachingViewController.h"
#import "SchoolClassExamViewController.h"
#import "SchoolClassAnnotationViewController.h"

@interface SchoolClassTabBarViewController ()

@end

@implementation SchoolClassTabBarViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        SchoolClassGeneralViewController *schoolClassGeneralViewController = [SchoolClassGeneralViewController new];
        SchoolClassSeatingPlanViewController *schoolClassSeatingPlanViewController = [SchoolClassSeatingPlanViewController new];
        SchoolClassTeachingViewController *schoolClassTeachingViewController = [SchoolClassTeachingViewController new];
        SchoolClassExamViewController *schoolClassExamViewController = [SchoolClassExamViewController new];
        SchoolClassAnnotationViewController *schoolClassAnnotationViewController = [SchoolClassAnnotationViewController new];

        [self setViewControllers:@[[schoolClassGeneralViewController embedInNavigationController],
                                   [schoolClassSeatingPlanViewController embedInNavigationController],
                                   [schoolClassTeachingViewController embedInNavigationController],
                                   [schoolClassExamViewController embedInNavigationController],
                                   [schoolClassAnnotationViewController embedInNavigationController]]];
    }
    return self;
}

@end
