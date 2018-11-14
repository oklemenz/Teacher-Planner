//
//  AppDelegate.h
//  TeacherPlanner
//
//  Created by Oliver on 28.12.13.
//
//

#import <UIKit/UIKit.h>
#import "LockScreenViewController.h"
#import "MainViewController.h"

#define kPeriodStoreTimerInterval 60.0

@class RootViewController;
@class MenuViewController;
@class StartViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate, LockScreenViewControllerDelegate, MainViewControllerDelegate>

+ (AppDelegate *)instance;

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) RootViewController *rootViewController;
@property (strong, nonatomic) MenuViewController *menuViewController;
@property (strong, nonatomic) UINavigationController *menuNavigationController;
@property (strong, nonatomic) MainViewController *mainViewController;
@property (strong, nonatomic) StartViewController *startViewController;
@property (strong, nonatomic) UIViewController *contentViewController;
@property (strong, nonatomic) LockScreenViewController *lockScreen;

- (NSString *)activeApplication;
- (void)switchApplication:(NSString *)uuid lock:(BOOL)lock;
- (void)lockApplication;

- (void)showContent:(UIViewController *)viewController hideMenu:(BOOL)hideMenu;
- (void)showSettings:(BOOL)animated completion:(void (^)(void))completion;
- (void)showSetup;
- (void)showHelp;
- (void)requestUserNotification;

- (void)enableMenuSwipe:(BOOL)enabled;

- (void)present:(UIViewController *)viewController presenter:(UIViewController *)presenter animated: (BOOL)animated completion:(void (^)(void))completion;
- (void)dismiss:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(void))completion;
- (void)dismissPresentedViewControllerAnimated:(BOOL)animated completion:(void (^)(void))completion;

@end
