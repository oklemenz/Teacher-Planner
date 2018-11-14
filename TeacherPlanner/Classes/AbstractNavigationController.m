//
//  AbstractNavigationController.m
//  TeacherPlanner
//
//  Created by Oliver on 20.06.14.
//
//

#import "AbstractNavigationController.h"
#import "Utilities.h"
#import "AppDelegate.h"

@interface AbstractNavigationController ()

@end

@implementation AbstractNavigationController

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        self.delegate = self;
        self.interactivePopGestureRecognizer.delegate = self;
    }
    return self;
}

- (BOOL)shouldAutorotate {
    if (self.topViewController) {
        return [self.topViewController shouldAutorotate];
    } else {
        return [super shouldAutorotate];
    }
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if (self.topViewController) {
        return [self.topViewController supportedInterfaceOrientations];
    } else {
        return [super supportedInterfaceOrientations];
    }
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    if (self.topViewController) {
        return [self.topViewController preferredInterfaceOrientationForPresentation];
    } else {
        return [super preferredInterfaceOrientationForPresentation];
    }
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [super pushViewController:viewController animated:animated];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    return [super popViewControllerAnimated:animated];
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    return [super popToViewController:viewController animated:animated];
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated {
    return [super popToRootViewControllerAnimated:animated];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isEqual:self.interactivePopGestureRecognizer]) {
        return NO;
    } else {
        return YES;
    }
}

@end