//
//  MainViewController.m
//  TeacherPlanner
//
//  Created by Oliver on 30.05.14.
//
//

#import "MainViewController.h"
#import "UIBarButtonItem+Extension.h"
#import "AppDelegate.h"

@interface MainViewController ()

@property(nonatomic, strong) UIPanGestureRecognizer *gesture;
@property(nonatomic) BOOL slidedOut;
@property(nonatomic) BOOL slide;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (UIBarButtonItem *)createMenuButton {
    UIBarButtonItem *menuButton = [UIBarButtonItem createCustomTintedTopBarButtonItem:@"menu"];
    [(UIButton *)menuButton.customView addTarget:self action:@selector(didPressMenu:)                                                               forControlEvents:UIControlEventTouchUpInside];
    return menuButton;
}

- (void)setMenuButton:(UIBarButtonItem *)menuButton {
}

- (void)attachSlideGesture {
    self.gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveMenu:)];
    self.gesture.delegate = self;
	self.gesture.minimumNumberOfTouches = 1;
	self.gesture.maximumNumberOfTouches = 1;
	[self.view addGestureRecognizer:self.gesture];
}

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gesture {
    CGPoint velocity = [gesture velocityInView:gesture.view];
    CGPoint translation = [gesture translationInView:gesture.view];
    if (([gesture locationInView:self.view].x < SLIDE_BEVEL || self.slidedOut) &&
        fabs(translation.x) > fabs(translation.y)) {
        if ((velocity.x > 0 && !self.slidedOut) || (velocity.x < 0 && self.slidedOut)) {
            return YES;
        }
    }
    return NO;
}

- (void)didPressMenu:(id)sender {
    [self slideMenuToggle:YES];
}

- (void)slideMenuToggle:(BOOL)animated {
    if (!self.slidedOut) {
        [self slideMenuShow:animated];
    } else {
        [self slideMenuHide:animated];
    }
}

- (void)slideMenuReturn:(BOOL)animated {
    self.slidedOut = !self.slidedOut;
    if (self.slidedOut) {
        [self slideMenuHide:animated];
    } else {
        [self slideMenuShow:animated];
    }
}

- (void)slideMenuShow:(BOOL)animated {
    if (self.slidedOut) {
        return;
    }
    self.slidedOut = YES;
    [self.delegate didShowMenu];
    UIView *slideView = self.view;
    [self showShadow];
    void (^show)(void) = ^(void) {
        slideView.frame = CGRectMake(SLIDE_OUT, 0, slideView.frame.size.width, slideView.frame.size.height);
    };
    if (animated) {
        [UIView animateWithDuration:SLIDE_TIME delay:0 usingSpringWithDamping:SLIDE_SPRING_DAMP initialSpringVelocity:SLIDE_SPRING_VELO options:0 animations:^{
            show();
        } completion:nil];
    } else {
        show();
    }
}

- (void)showShadow {
    UIView *slideView = self.view;
    [slideView.layer setShadowColor:[UIColor blackColor].CGColor];
    [slideView.layer setShadowOpacity:0.5];
    [slideView.layer setShadowOffset:CGSizeMake(-1, -1)];
}

- (void)slideMenuHide:(BOOL)animated {
    if (!self.slidedOut) {
        return;
    }
    self.slidedOut = NO;
    [self.delegate didHideMenu];
    UIView *slideView = self.view;
    void (^hide)(void) = ^(void) {
        slideView.frame = CGRectMake(0, 0, slideView.frame.size.width, slideView.frame.size.height);
    };
    if (animated) {
        [UIView animateWithDuration:SLIDE_TIME delay:0 usingSpringWithDamping:SLIDE_SPRING_DAMP initialSpringVelocity:SLIDE_SPRING_VELO options:0 animations:^{
            hide();
        } completion:nil];
    } else {
        hide();
    }
}

- (void)hideShadow {
    UIView *slideView = self.view;
    [slideView.layer setCornerRadius:0.0f];
    [slideView.layer setShadowOffset:CGSizeMake(0, 0)];
}

- (void)moveMenu:(UIPanGestureRecognizer *)gesture {
	[gesture.view.layer removeAllAnimations];
	CGPoint translatedPoint = [gesture translationInView:self.view];
	if (gesture.state == UIGestureRecognizerStateBegan) {
        [self showShadow];
	} else if (gesture.state == UIGestureRecognizerStateEnded) {
        if (self.slide) {
            [self slideMenuToggle:YES];
        } else {
            [self slideMenuReturn:YES];
        }
	} else if (gesture.state == UIGestureRecognizerStateChanged) {
        CGFloat newX = MIN(translatedPoint.x + gesture.view.center.x, gesture.view.frame.size.width / 2.0 + SLIDE_OUT);
        newX = MAX(newX, gesture.view.frame.size.width / 2.0);
        
        gesture.view.center = CGPointMake(newX, gesture.view.center.y);
        [gesture setTranslation:CGPointMake(0,0) inView:self.view];
        
        self.slide = (gesture.view.frame.origin.x > SLIDE_BIAS && !self.slidedOut) ||
        (gesture.view.frame.origin.x < SLIDE_OUT - SLIDE_BIAS && self.slidedOut);
	}
}

- (void)enableMenuSwipe:(BOOL)enabled {
    self.gesture.enabled = enabled;
}

@end