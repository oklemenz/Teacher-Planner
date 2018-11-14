//
//  LockScreenViewController.m
//  TeacherPlanner
//
//  Created by Oliver on 04.01.14.
//
//

#import "LockScreenViewController.h"
#import <LocalAuthentication/LocalAuthentication.h>

#import "Configuration.h"
#import "UIImage+Extension.h"
#import "Codes.h"
#import "Model.h"
#import "Configuration.h"
#import "ApplicationTableViewController.h"
#import "AppDelegate.h"
#import "RootViewController.h"
#import "UIViewController+Extension.h"
#import "Common.h"
#import "UILabel+Extension.h"
#import "Utilities.h"

@interface LockScreenViewController ()

@property(nonatomic, strong) UILabel *unlockLabel;
@property(nonatomic, strong) UIImage *buttonImage;
@property(nonatomic, strong) UIImage *buttonPressedImage;
@property(nonatomic) CGFloat textWidth;
@property(nonatomic, strong) UIButton *touchIDButton;
@property(nonatomic, strong) UINavigationController *applicationController;
@property(nonatomic) CGFloat page;

@end

@implementation LockScreenViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.mode = kLockScreenModeCreatePasscode;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    self.passcodeField.text = @"";
    [self.cancelDeleteButton setTitle:NSLocalizedString(@"Cancel", @"") forState:UIControlStateNormal];
    [self setCoverAlpha:self.scrollView.contentOffset.x];
    [self setWelcomeTitle];
    
    self.touchIDButton.hidden = ![[[NSUserDefaults standardUserDefaults] valueForKeyPath:kTeacherPlannerTouchID] boolValue];
}

- (void)setWelcomeTitle {
    NSDateComponents *components = [[Utilities calendar] components:NSCalendarUnitHour fromDate:[NSDate date]];
    NSInteger hour = [components hour];
    if (hour >= 5 && hour < 11) {
        self.greetingLabel.text = NSLocalizedString(@"Good Morning", @"");
    } else if (hour >= 11 && hour < 14) {
        self.greetingLabel.text = NSLocalizedString(@"Good Day", @"");
    } else if (hour >= 14 && hour < 16) {
        self.greetingLabel.text = NSLocalizedString(@"Good Afternoon", @"");
    } else if (hour >= 16 && hour < 20) {
        self.greetingLabel.text = NSLocalizedString(@"Good Evening", @"");
    } else if (hour >= 20 || hour < 5) {
        self.greetingLabel.text = NSLocalizedString(@"Good Night", @"");
    } else {
        self.greetingLabel.text = NSLocalizedString(@"Good Day", @"");
    }
    NSString *name = [[NSUserDefaults standardUserDefaults] valueForKeyPath:kTeacherPlannerWelcomeName];
    if (!name) {
        name = @"";
    }
    self.nameLabel.text = name;
}

- (void)pauseLayer:(CALayer*)layer {
    CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
    layer.speed = 0.0;
    layer.timeOffset = pausedTime;
}

- (void)resumeLayer:(CALayer*)layer {
    CFTimeInterval pausedTime = [layer timeOffset];
    layer.speed = 1.0;
    layer.timeOffset = 0.0;
    layer.beginTime = 0.0;
    CFTimeInterval timeSincePause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    layer.beginTime = timeSincePause;
}

- (void)show {
    [[AppDelegate instance] dismiss:self.applicationController animated:NO completion:nil];
    self.scrollView.contentSize = CGSizeMake(2 * self.view.frame.size.width, self.view.frame.size.height);
    self.scrollView.contentOffset = CGPointMake(self.view.frame.size.width, 0);
    self.blurredView.frame = self.view.bounds;
    self.page = 1;
    [self resume];
}

- (void)resume {
    [self setWelcomeTitle];
    [self.unlockLabel addSlideAnimation:SlideDirectionLeftToRight duration:2.0];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    self.greetingLabel.text = @"";
    self.nameLabel.text = @"";
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    self.blurredView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    self.blurredView.frame = self.view.bounds;
    self.blurredView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view insertSubview:self.blurredView atIndex:0];
    
    self.unlockPage.frame = CGRectMake(0, 0, self.view.frame.size.width, self .view.frame.size.height);
    [self.scrollView addSubview:self.unlockPage];
    
    self.startPage.frame = CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, self .view.frame.size.height);
    [self.scrollView addSubview:self.startPage];
    [self addSlideToUnlock];
    
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.scrollView.contentSize = CGSizeMake(2 * self.view.frame.size.width, self.view.frame.size.height);
    self.scrollView.contentOffset = CGPointMake(self.view.frame.size.width, 0);

    LAContext *context = [[LAContext alloc] init];
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil]) {
        self.touchIDButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50.0f, 50.0f)];
        self.touchIDButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin |
        UIViewAutoresizingFlexibleBottomMargin;
        [self.touchIDButton setImage:[UIImage imageNamed:@"touch_id"] forState:UIControlStateNormal];
        [self.touchIDButton addTarget:self action:@selector(didPressTouchID:) forControlEvents:UIControlEventTouchUpInside];
        self.touchIDButton.center = self.view.center;
        [self.startPage addSubview:self.touchIDButton];
        
        UILabel *touchIDLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.touchIDButton.frame.origin.y + 60.0f, self.view.frame.size.width, 30)];
        touchIDLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        touchIDLabel.textColor = [UIColor whiteColor];
        touchIDLabel.textAlignment = NSTextAlignmentCenter;
        touchIDLabel.text = NSLocalizedString(@"Unlock with TouchID", @"");
        [self.startPage addSubview:touchIDLabel];
    }
    
    self.buttonImage = [[UIImage imageNamed:@"pin_circle_ipad"] tintImage:[Configuration instance].tintColor];
    self.buttonPressedImage = [[UIImage imageNamed:@"pin_circle_pressed_ipad"] tintImage:[Configuration instance].tintColor];
    
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
            [self addButtonToKeyPad:1 + i + (3 * j) x:i * 100 y:j * 100];
        }
    }
    [self addButtonToKeyPad:0 x:100 y:3 * 100];
}

- (void)didPressTouchID:(id)sender {
    LAContext *context = [[LAContext alloc] init];
    
    NSError *error = nil;
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                localizedReason:NSLocalizedString(@"Touch to Unlock!", @"")
                          reply:^(BOOL success, NSError *error) {
                              dispatch_async(dispatch_get_main_queue(), ^{
                                  if (error) {
                                      [Common showMessage:self
                                                    title:NSLocalizedString(@"TouchID Error", @"")
                                                  message:NSLocalizedString(@"There was a problem verifying your identity.", @"")
                                                okHandler:nil];
                                      return;
                                  }
                                  if (success) {
                                      [self.delegate didUnlockWithTouchID];
                                  } else {
                                      [Common showMessage:self
                                                    title:NSLocalizedString(@"TouchID Error", @"")
                                                  message:NSLocalizedString(@"You are not authorized to unlock the application!", @"")
                                                okHandler:nil];

                                  }
                              });
                          }];
        
    } else {
        [Common showMessage:self
                      title:NSLocalizedString(@"TouchID Error", @"")
                    message:NSLocalizedString(@"You cannot authenticate using TouchID.", @"")
                  okHandler:nil];
    }
}

- (void)addSlideToUnlock {
    self.unlockLabel = [UILabel createSlideLabel:NSLocalizedString(@"> Slide To Unlock", @"")
                                           frame:CGRectMake(0.0f, 0.0f, 350.0f, 50.0f)
                                       direction:SlideDirectionLeftToRight];
    self.unlockLabel.textAlignment = NSTextAlignmentCenter;
    [self.startPage addSubview:self.unlockLabel];
}

- (void)addButtonToKeyPad:(int)num x:(CGFloat)x y:(CGFloat)y {
    CGFloat buttonSize = 75;
    CGFloat buttonFontSize = 72;
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        buttonSize = 81;
        buttonFontSize = 77;
    }
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(x, y, buttonSize, buttonSize)];
    button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:buttonFontSize / 2.0f];
    [button setTitleColor:[Configuration instance].tintColor forState:UIControlStateNormal];
    [button setTitle:[NSString stringWithFormat:@"%i", num] forState:UIControlStateNormal];
    [button setBackgroundImage:self.buttonImage forState:UIControlStateNormal];
    [button setBackgroundImage:self.buttonPressedImage forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(buttonTouchDown:) forControlEvents:UIControlEventTouchDown];
    [button addTarget:self action:@selector(buttonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [button addTarget:self action:@selector(buttonTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
    [self.codeKeyPadView addSubview:button];
    
    [self.infoButton setTintColor:[UIColor blackColor]];
}

- (void)buttonTouchDown:(id)button {
    [button setBackgroundImage:self.buttonPressedImage forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

- (void)buttonTouchUpInside:(id)button {
    self.passcodeField.text = [NSString stringWithFormat:@"%@%@", self.passcodeField.text, [button titleLabel].text];
    [self.cancelDeleteButton setTitle:NSLocalizedString(@"Delete", @"") forState:UIControlStateNormal];
    self.okButton.enabled = true;
    [self performSelector:@selector(resetButton:) withObject:button afterDelay:0.1];
}

- (void)buttonTouchUpOutside:(id)button {
    [self performSelector:@selector(resetButton:) withObject:button afterDelay:0.1];
}

- (void)resetButton:(id)button {
    [button setBackgroundImage:self.buttonImage forState:UIControlStateNormal];
    [button setTitleColor:[Configuration instance].tintColor forState:UIControlStateNormal];
}

- (void)cancelPressed:(id)button {
    if (self.passcodeField.text.length == 0) {
        [UIView animateWithDuration:0.25f animations:^ {
            self.scrollView.contentOffset = CGPointMake(self.view.bounds.size.width, 0);
        }];
    } else {
        self.passcodeField.text = [self.passcodeField.text substringToIndex:self.passcodeField.text.length-1];
        if (self.passcodeField.text.length == 0) {
            [self.cancelDeleteButton setTitle:NSLocalizedString(@"Cancel", @"") forState:UIControlStateNormal];
            self.okButton.enabled = false;
        }
    }
}

- (IBAction)infoPressed:(id)sender {
    ApplicationTableViewController *application = [ApplicationTableViewController new];
    self.applicationController = [application embedInNavigationController];
    [[AppDelegate instance] present:self.applicationController presenter:self animated:YES completion:nil];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator {
    self.page = floor(self.scrollView.contentOffset.x / self.scrollView.frame.size.width);
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat offsetX = 0;

    self.scrollView.frame = self.view.bounds;
    self.scrollView.contentSize = CGSizeMake(2 * self.view.bounds.size.width, self.view.bounds.size.height);
    self.scrollView.contentOffset = CGPointMake(self.page * self.view.bounds.size.width, 0);
    
    self.unlockPage.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    offsetX = (self.view.bounds.size.width - self.unlockContentView.bounds.size.width) / 2.0f;
    self.unlockContentView.frame = CGRectMake(offsetX, 20, self.unlockContentView.bounds.size.width, self.unlockContentView.bounds.size.height);

    self.keyPadView.frame = CGRectMake(0, 150, self.view.bounds.size.width, self.view.bounds.size.height - 150);
    
    self.startPage.frame = CGRectMake(self.view.bounds.size.width, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    offsetX = (self.view.bounds.size.width - self.startContentView.bounds.size.width) / 2.0f;
    self.startContentView.frame = CGRectMake(offsetX, 100, self.startContentView.bounds.size.width, self.startContentView.bounds.size.height);
    
    offsetX = (self.view.bounds.size.width - self.unlockLabel.bounds.size.width) / 2.0f;
    CGFloat offsetY = self.view.frame.size.height - 100;
    self.unlockLabel.frame = CGRectMake(offsetX, offsetY, self.unlockLabel.bounds.size.width,
                                        self.unlockLabel.bounds.size.height);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self setCoverAlpha:scrollView.contentOffset.x];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.x >= self.view.bounds.size.width) {
        self.passcodeField.text = @"";
        [self.passcodeField resignFirstResponder];
    }
    [self setCoverAlpha:scrollView.contentOffset.x];
}

- (void)setCoverAlpha:(CGFloat)contentOffset {
    contentOffset = MAX(0, contentOffset);
    contentOffset = MIN(self.scrollView.frame.size.width, contentOffset);
    self.coverView.alpha = (contentOffset / self.scrollView.frame.size.width / 2);
    if (self.scrollView.contentOffset.x > self.scrollView.frame.size.width / 2) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    } else {
        [[Configuration instance] applyStatusBarColorAnimated:YES];
    }
}

- (void)setMode:(LockScreenMode)mode {
    _mode = mode;
    switch (mode) {
        case kLockScreenModeCreatePasscode:
            self.headerLabel.text = NSLocalizedString(@"Create your application passcode", @"");
            break;
        case kLockScreenModeEnterPasscode:
            self.headerLabel.text = NSLocalizedString(@"Enter your application passcode", @"");
            break;
    }
}

- (void)wrongPasscodeShake {
    self.passcodeField.text = @"";
    self.okButton.enabled = false;
    [self.cancelDeleteButton setTitle:NSLocalizedString(@"Cancel", @"") forState:UIControlStateNormal];
    [UIView animateWithDuration:0.05 animations:^{
        self.passcodeField.center = CGPointMake(self.passcodeField.center.x + 10, self.passcodeField.center.y);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            self.passcodeField.center = CGPointMake(self.passcodeField.center.x - 20, self.passcodeField.center.y);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 animations:^{
                self.passcodeField.center = CGPointMake(self.passcodeField.center.x + 20, self.passcodeField.center.y);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.05 animations:^{
                    self.passcodeField.center = CGPointMake(self.passcodeField.center.x - 10, self.passcodeField.center.y);
                } completion:nil];
            }];
        }];
    }];
}

- (IBAction)okPressed:(id)sender {
    [self.passcodeField resignFirstResponder];
    [self.delegate didUnlockWithPasscode:self.passcodeField.text];
    self.passcodeField.text = @"";
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

@end