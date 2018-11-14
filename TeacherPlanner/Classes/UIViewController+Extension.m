//
//  UIViewController+Extension.m
//  TeacherPlanner
//
//  Created by Oliver on 22.06.14.
//
//

#import "UIViewController+Extension.h"
#import "AbstractNavigationController.h"

@implementation UIViewController (Extension)

- (UINavigationController *)embedInNavigationController {
    return [[AbstractNavigationController alloc] initWithRootViewController:self];
}

@end