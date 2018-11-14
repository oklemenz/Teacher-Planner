//
//  PersonTabBarViewController.m
//  TeacherPlanner
//
//  Created by Oliver Klemenz on 27.12.14.
//
//

#import "PersonTabBarViewController.h"
#import "PersonGeneralViewController.h"
#import "PersonAnnotationViewController.h"

@interface PersonTabBarViewController ()

@end

@implementation PersonTabBarViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        PersonGeneralViewController *personGeneralViewController = [PersonGeneralViewController new];
        PersonAnnotationViewController *personAnnotationViewController = [PersonAnnotationViewController new];
        
        [self setViewControllers:@[[personGeneralViewController embedInNavigationController],
                                   [personAnnotationViewController embedInNavigationController]]];
    }
    return self;
}

@end
