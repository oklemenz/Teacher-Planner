//
//  StudentTabBarViewController.m
//  TeacherPlanner
//
//  Created by Oliver on 17.05.14.
//
//

#import "StudentTabBarViewController.h"
#import "StudentGeneralViewController.h"
#import "StudentTeachingViewController.h"
#import "StudentGradeViewController.h"
#import "StudentAnnotationViewController.h"

@interface StudentTabBarViewController ()

@end

@implementation StudentTabBarViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        StudentGeneralViewController *studentGeneralViewController = [StudentGeneralViewController new];
        StudentTeachingViewController *studentTeachingViewController = [StudentTeachingViewController new];
        StudentGradeViewController *studentGradeViewController = [StudentGradeViewController new];
        StudentAnnotationViewController *studentAnnotationViewController = [StudentAnnotationViewController new];
        
        [self setViewControllers:@[[studentGeneralViewController embedInNavigationController],
                                   [studentTeachingViewController embedInNavigationController],
                                   [studentGradeViewController embedInNavigationController],
                                   [studentAnnotationViewController embedInNavigationController]]];
    }
    return self;
}

@end
