//
//  AbstractTabBarViewController.m
//  TeacherPlanner
//
//  Created by Oliver on 25.05.14.
//
//

#import "AbstractTabBarViewController.h"
#import "DefaultBindable.h"

@interface AbstractTabBarViewController () {
    DefaultBindable *_bindable;
}

@end

#pragma clang diagnostic ignored "-Wprotocol"
@implementation AbstractTabBarViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        _bindable = [[DefaultBindable alloc] initWithDelegate:self];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)setEntity:(JSONEntity *)entity {
    _entity = entity;
}

- (void)setTitle:(NSString *)title {
    [super setTitle:title];
    if ([self.selectedViewController isKindOfClass:UINavigationController.class]) {
        UINavigationController *navigationController = (UINavigationController *)self.selectedViewController;
        [(UIViewController *)navigationController.viewControllers[0] setTitle:title];
    }
}

- (BOOL)menuSwipeEnabled {
    return YES;
}

- (BOOL)shouldAutorotate {
    if (self.selectedViewController) {
        return [self.selectedViewController shouldAutorotate];
    } else {
        return [super shouldAutorotate];
    }
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if (self.selectedViewController) {
        return [self.selectedViewController supportedInterfaceOrientations];
    } else {
        return [super supportedInterfaceOrientations];
    }
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    if (self.selectedViewController) {
        return [self.selectedViewController preferredInterfaceOrientationForPresentation];
    } else {
        return [super preferredInterfaceOrientationForPresentation];
    }
}

- (void)resetViewController:(UIViewController *)viewController {
    viewController.editing = NO;
    if ([viewController.view isKindOfClass:UIScrollView.class]) {
        [(UIScrollView *)viewController.view setContentOffset:CGPointZero animated:NO];
    }
    for (UIViewController *childViewController in viewController.childViewControllers) {
        [self resetViewController:childViewController];
    }
}

#pragma mark - Method forwarding

- (void)forwardInvocation:(NSInvocation *)invocation {
    if ([_bindable respondsToSelector:[invocation selector]]) {
        [invocation invokeWithTarget:_bindable];
    } else{
        [super forwardInvocation:invocation];
    }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    NSMethodSignature *signature = [super methodSignatureForSelector:selector];
    if (!signature) {
        signature = [_bindable methodSignatureForSelector:selector];
    }
    return signature;
}

- (BOOL)conformsToProtocol:(Protocol *)protocol {
    return [super conformsToProtocol:protocol] || [_bindable conformsToProtocol:protocol];
}

@end
