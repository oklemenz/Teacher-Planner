//
//  AppDelegate.m
//  TeacherPlanner
//
//  Created by Oliver on 28.12.13.
//
//

#import "AppDelegate.h"
#import "Configuration.h"
#import "Common.h"

#import "RootViewController.h"
#import "MenuViewController.h"
#import "MainViewController.h"
#import "StartViewController.h"

#import "AbstractTabBarViewController.h"
#import "SettingsTabBarViewController.h"
#import "PersonListDetailTableViewController.h"

#import "LockScreenViewController.h"
#import "SecureStore.h"

#import "Model.h"
#import "Application.h"
#import "Utilities.h"

#import "AnnotationHandler.h"
#import "AbstractBaseViewController.h"
#import "AbstractBaseTableViewController.h"
#import "AnnotationViewController.h"

#import "SetupWelcomeViewController.h"

@interface AppDelegate ()

@property(nonatomic, strong) NSTimer *lockTimer;
@property(nonatomic) UIBackgroundTaskIdentifier backgroundTaskIdentifier;

@property(nonatomic, strong) UILocalNotification *currentLocalNotification;

@property(nonatomic, strong) JSONEntity *activeEntity;
@property(nonatomic, strong) SettingsTabBarViewController *settingsViewController;
@property(nonatomic, strong) SetupWelcomeViewController *setupViewController;

@property(nonatomic, strong) AnnotationHandler *annotationHandler;
@property(nonatomic, getter=isLocked) BOOL locked;
@property(nonatomic) BOOL settingsVisible;
@property(nonatomic, strong) NSTimer *periodStoreTimer;

@property(nonatomic, weak) UIViewController *presentedViewController;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[Configuration instance] applyColors];
    
    self.rootViewController = [RootViewController new];
    self.rootViewController.view.backgroundColor = [UIColor whiteColor];
    
    self.menuViewController = [MenuViewController new];
    self.menuNavigationController = [self.menuViewController embedInNavigationController];
    self.menuNavigationController.view.frame = CGRectMake(0, 0, SLIDE_OUT, self.rootViewController.view.frame.size.height);
    self.menuNavigationController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.rootViewController addChildViewController:self.menuNavigationController];
    [self.rootViewController.view addSubview:self.menuNavigationController.view];
    
    self.mainViewController = [MainViewController new];
    self.mainViewController.view.frame = self.rootViewController.view.frame;
    [self.rootViewController addChildViewController:self.mainViewController];
    [self.rootViewController.view addSubview:self.mainViewController .view];
    [self.mainViewController attachSlideGesture];
    self.mainViewController.delegate = self;

    self.startViewController = [StartViewController new];
    [self showStartContent];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window addSubview:self.rootViewController.view];
    self.window.rootViewController = self.rootViewController;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    self.lockScreen = [LockScreenViewController new];
    self.lockScreen.delegate = self;
    
    SecureStore *secureStore = [SecureStore instance];

    // TODO: Check for setup mode
    //[self performSelector:@selector(showSetup) withObject:nil afterDelay:0.2];

    // TODO: Testing mode
    //[self showLockScreen];
    [self didUnlockWithPasscode:@"1234"];
    // TODO: Testing mode
    
    if (![secureStore exists]) {
        self.lockScreen.mode = kLockScreenModeCreatePasscode;
    } else {
        self.lockScreen.mode = kLockScreenModeEnterPasscode;
    }
    
    [[Configuration instance] applyBranding:self.window];
    
    UILocalNotification *localNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (localNotification) {
        [self didStartWithNotification:localNotification];
    }
        
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRemoveEntity:) name:ModelDidRemoveEntityNotification object:nil];
    
    if ([self userNotificationAllowed]) {
        [self clearBadgeCount];
    }
    
    self.periodStoreTimer = [NSTimer scheduledTimerWithTimeInterval:kPeriodStoreTimerInterval target:self selector:@selector(periodicStore) userInfo:nil repeats:YES];
    
    return YES;
}
     
- (void)periodicStore {
    if ([Model instance].isLoaded) {
        [[Model instance] store];
    }
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if (url) {
        if ([url isFileURL]) {
            NSData *importData = [NSData dataWithContentsOfURL:url];
            if ([[url pathExtension] isEqualToString:kApplicationExtension]) {
                [Common showConfirmation:self.window.rootViewController
                                   title:NSLocalizedString(@"Import Application", @"")
                                 message:NSLocalizedString(@"Application was started with application file. Do you want to import application?", @"")
                           okButtonTitle:NSLocalizedString(@"Yes", @"") destructive:NO cancelButtonTitle:NSLocalizedString(@"No", @"") okHandler:^{
                               
                               // TODO: Unzip and import application with new UUID
                               
                           } cancelHandler:nil];
            } else if ([[url pathExtension] isEqualToString:kBrandingExtension]) {
                [Common showConfirmation:self.window.rootViewController
                                   title:NSLocalizedString(@"Import Branding", @"")
                                 message:NSLocalizedString(@"Application was started with branding file. Do you want to import branding?", @"")
                           okButtonTitle:NSLocalizedString(@"Yes", @"") destructive:NO cancelButtonTitle:NSLocalizedString(@"No", @"") okHandler:^{
                               
                               NSDictionary *importConfiguration = [NSJSONSerialization JSONObjectWithData:importData options:kNilOptions error:nil];
                               NSDictionary *importBranding = (NSDictionary *)importConfiguration[kConfigKeyBrandingPrefix];
                               NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                               for (NSString *configKey in [Configuration instance].configurableKeys) {
                                   if (importBranding[configKey]) {
                                       [userDefaults setValue:importBranding[configKey] forKey:configKey];
                                   }
                               }
                               NSDictionary *importSchool = (NSDictionary *)importConfiguration[kConfigKeySchoolPrefix];
                               NSError *error;
                               School *importedSchool = [[School alloc] initWithDictionary:importSchool error:&error];
                               School *school = [Model instance].application.settings.school;
                               importedSchool.uuid = school.uuid;
                               importedSchool.parent = school.parent;
                               [Model instance].application.settings.school = importedSchool;
                               [[Configuration instance] check];
                               
                           } cancelHandler:nil];
            } else if ([[url pathExtension] isEqualToString:kClassExtension]) {
                [Common showConfirmation:self.window.rootViewController
                                   title:NSLocalizedString(@"Import School Class", @"")
                                 message:NSLocalizedString(@"Application was started with school class file. Do you want to import school class into active school year?", @"")
                           okButtonTitle:NSLocalizedString(@"Yes", @"") destructive:NO cancelButtonTitle:NSLocalizedString(@"No", @"") okHandler:^{
                               
                               // TODO: Unzip and import class with new UUID
                               
                           } cancelHandler:nil];
            }
        } else {
            // URL scheme: teacherPlanner://?TeacherPlannerBrandingActive=true
            NSString *query = [url query];
            NSArray *parameters = [query componentsSeparatedByString:@"&"];
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            for (NSString *parameter in parameters) {
                NSArray *keyValue = [parameter componentsSeparatedByString:@"="];
                if (keyValue.count == 2) {
                    NSString *configKey = keyValue[0];
                    NSString *configValue = keyValue[1];
                    if ([[Configuration instance].configurableKeys indexOfObject:configKey] != NSNotFound) {
                        NSScanner *scan = [NSScanner scannerWithString:configValue];
                        NSInteger integerValue;
                        if ([scan scanInteger:&integerValue] && [scan isAtEnd]) {
                            [userDefaults setInteger:integerValue forKey:configKey];
                        } else {
                            scan = [NSScanner scannerWithString:configValue];
                            double doubleValue;
                            if ([scan scanDouble:&doubleValue] && [scan isAtEnd]) {
                                [userDefaults setDouble:doubleValue forKey:configKey];
                            } else if ([[configValue lowercaseString] isEqualToString:@"true"]) {
                                [userDefaults setBool:YES forKey:configKey];
                            } else if ([[configValue lowercaseString] isEqualToString:@"false"]) {
                                [userDefaults setBool:NO forKey:configKey];
                            } else {
                                [userDefaults setValue:configValue forKey:configKey];
                            }
                        }
                    }
                }
            }
            [userDefaults synchronize];
        }
    }
    return YES;
}

- (void)didRemoveEntity:(id)sender {
    NSDictionary *userInfo = [sender userInfo];
    if (self.activeEntity && [self.activeEntity.uuid isEqual:userInfo[@"uuid"]]) {
        self.activeEntity = nil;
        [self showStartContent];
    }
}

- (void)application:(UIApplication *)app didReceiveLocalNotification:(UILocalNotification *)localNotification {
    [self increaseBadgeCountBy:1];
    [self showNotification:localNotification];
}

- (void)didStartWithNotification:(UILocalNotification *)localNotification {
    [self showNotification:localNotification];
}

- (AnnotationHandler *)annotationHandler {
    if (!_annotationHandler) {
        _annotationHandler = [AnnotationHandler new];
    }
    return _annotationHandler;
}

- (void)showNotification:(UILocalNotification *)localNotification {
    UIViewController *presenter = self.window.rootViewController;
    if (self.settingsViewController) {
        presenter = self.settingsViewController;
    }
    [Common showNotificationConfirmation:presenter showHandler:^{
        NSString *entityPath = localNotification.userInfo[@"entityPath"];
        Annotation *annotation = (Annotation *)[[Model instance].application entityByEntityPath:entityPath];
        if (annotation && [annotation isKindOfClass:Annotation.class]) {
            [self.annotationHandler present:annotation presenter:presenter];
            [annotation unscheduleReminder];
        }
    } openHandler:^{
        NSString *entityPath = localNotification.userInfo[@"entityPath"];
        Annotation *annotation = (Annotation *)[[Model instance].application entityByEntityPath:entityPath];
        if (annotation && [annotation isKindOfClass:Annotation.class]) {
            if ([annotation.parent.parent isKindOfClass:Person.class]) {
                NSArray *entityPathParts = [Utilities deserializeJSONToObject:entityPath];
                if (entityPathParts) {
                    NSString *selectedEntityUUID;
                    for (NSDictionary *entityPathPart in entityPathParts) {
                        if ([entityPathPart[@"entity"] isEqualToString:NSStringFromClass(Person.class)]) {
                            selectedEntityUUID = entityPathPart[@"uuid"];
                            break;
                        }
                    }
                    if (selectedEntityUUID) {
                        [self showSettings:YES completion:^{
                            UINavigationController *navigationController = (UINavigationController *)self.settingsViewController.settingsPersonsViewController.parentViewController;
                            [self.settingsViewController.settingsPersonsViewController view];
                            NSInteger tabIndex = [self.settingsViewController.childViewControllers indexOfObject:navigationController];
                            [self.settingsViewController setSelectedIndex:tabIndex];
                            if ([self.settingsViewController.settingsPersonsViewController didSelectEntity:selectedEntityUUID]) {
                                // TODO: personDetail not on top...?
                                PersonListDetailTableViewController *personDetail = (PersonListDetailTableViewController *)navigationController.topViewController;
                                if ([personDetail isKindOfClass:PersonListDetailTableViewController.class]) {
                                    [personDetail showAnnotations];
                                    [personDetail.annotationViewController showAnnotation:annotation.uuid];
                                }
                            }
                        }];
                    }
                }
            } else {
                if ([self.menuViewController restoreStateFromEntityPath:entityPath]) {
                    if ([self.contentViewController isKindOfClass:AbstractTabBarViewController.class]) {
                        AbstractTabBarViewController *tabBarController = (AbstractTabBarViewController *)self.contentViewController;
                        NSInteger tabIndex = 0;
                        UIViewController *viewController;
                        AnnotationViewController *annotationViewController;
                        for (UIViewController *tabController in tabBarController.childViewControllers) {
                            if ([tabController isKindOfClass:UINavigationController.class]) {
                                UINavigationController *navigationController = (UINavigationController *)tabController;
                                [navigationController popToRootViewControllerAnimated:NO];
                                viewController = [navigationController topViewController];
                            } else {
                                viewController = tabController;
                            }
                            if ([viewController isKindOfClass:AbstractBaseViewController.class]) {
                                annotationViewController = [(AbstractBaseViewController *)viewController annotationViewController];
                            } else if ([viewController isKindOfClass:AbstractBaseTableViewController.class]) {
                                annotationViewController = [(AbstractBaseTableViewController *)viewController annotationViewController];
                            }
                            if (annotationViewController) {
                                break;
                            }
                            tabIndex++;
                        }
                        if (annotationViewController) {
                            [tabBarController setSelectedIndex:tabIndex];
                            [viewController view];
                            [annotationViewController showAnnotation:annotation.uuid];
                        }
                    }
                }
            }
            [annotation unscheduleReminder];
        }
    } cancelHandler:nil];
}

- (void)clearBadgeCount {
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (void)increaseBadgeCountBy:(int)count {
    [UIApplication sharedApplication].applicationIconBadgeNumber += count;
}

- (void)decreaseBadgeCountBy:(int)count {
    [UIApplication sharedApplication].applicationIconBadgeNumber -= count;
    if ([UIApplication sharedApplication].applicationIconBadgeNumber < 0) {
        [self clearBadgeCount];
    }
}

- (NSString *)activeApplication {
    return [[NSUserDefaults standardUserDefaults] valueForKey:kConfigKeyActiveApplication];
}

- (void)setActiveApplication:(NSString *)uuid {
    [[NSUserDefaults standardUserDefaults] setValue:uuid forKey:kConfigKeyActiveApplication];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)switchApplication:(NSString *)uuid lock:(BOOL)lock {
    [self reset];
    [self setActiveApplication:uuid];
    [self bootstrap];
    [self showStartContent];
    [self.mainViewController slideMenuHide:NO];
    if (lock) {
        [self.lockScreen show];
    }
}

- (void)reset {
    [self.menuViewController clearState];
    [[Model instance] clear];
}

- (void)lockApplication {
    SecureStore *secureStore = [SecureStore instance];
    if ([secureStore isOpen]) {
        [[Model instance] store];
        [self lock];
    }
}

- (void)bootstrap {
    NSString *applicationUUID = [self activeApplication];
    applicationUUID = [[Model instance] load:applicationUUID];
    [self setActiveApplication:applicationUUID];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[Configuration instance] check];
    [[Model instance].application setSuppressProtected:NO];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    if (self.backgroundTaskIdentifier != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskIdentifier];
        self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
        [self.lockTimer invalidate];
        self.lockTimer = nil;
    }
    [self.lockScreen show];
    if (self.setupViewController) {
        [self.setupViewController resume];
    }
    if ([self userNotificationAllowed]) {
        [self clearBadgeCount];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [self.window endEditing:YES];
    [self dismissPresentedViewControllerAnimated:NO completion:nil];
    SecureStore *secureStore = [SecureStore instance];
    if ([secureStore isOpen]) {
        [[Model instance] store];
    }
    if ([Configuration instance].exitOnResignActive) {
        exit(0);
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    SecureStore *secureStore = [SecureStore instance];
    if ([secureStore isOpen]) {
        // TODO: Handle return value => error -> alert
        [[Model instance] store];
        NSInteger passcodeTimeout = [[secureStore objectForKey:kSecureStorePasscodeTimeout] integerValue];
        if (passcodeTimeout == 0) {
            [self lock];
        } else {
            self.lockTimer = [NSTimer scheduledTimerWithTimeInterval:passcodeTimeout * 60 target:self selector:@selector(lock) userInfo:nil repeats:NO];
        }
    }
    self.backgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [self.lockTimer fire];
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskIdentifier];
        self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
    }];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [Utilities clearGeneratedFolder];
        [Utilities backupApplication:[self activeApplication]];
    });
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[Model instance] store];
    [Utilities clearGeneratedFolder];
}

- (void)lock {
    self.locked = YES;
    [[SecureStore instance] close];
    [self showLockScreen];
}

- (void)unlock {
    self.locked = NO;
    [self bootstrap];
    [self hideLockScreen:YES];
    [[Configuration instance] applyStatusBarColorAnimated:YES];
    [self.menuViewController restoreState];
}

- (void)showLockScreen {
    [self.lockScreen.view removeFromSuperview];
    self.lockScreen.view.frame = [UIScreen mainScreen].bounds;
    [self.lockScreen show];
    if (self.settingsVisible) {
        [self.settingsViewController addChildViewController:self.lockScreen];
        [self.settingsViewController.view addSubview:self.lockScreen.view];
    } else {
        [self.window.rootViewController addChildViewController:self.lockScreen];
        [self.window.rootViewController.view addSubview:self.lockScreen.view];
    }
}

- (void)hideLockScreen:(BOOL)animated {
    [self.lockScreen removeFromParentViewController];
    [self.lockScreen.view removeFromSuperview];
    if (animated) {
        [UIView animateWithDuration:0.5 animations:^{
            self.lockScreen.view.center = CGPointMake(self.lockScreen.view.center.x, 3 * self.lockScreen.view.center.y);
        } completion:^(BOOL finished) {
            [self.lockScreen.view removeFromSuperview];
        }];
    } else {
        self.lockScreen.view.center = CGPointMake(self.lockScreen.view.center.x, 3 * self.lockScreen.view.center.y);
        [self.lockScreen.view removeFromSuperview];
    }
}

- (void)didUnlockWithPasscode:(NSString *)passcode {
    SecureStore *secureStore = [SecureStore instance];
    if (![secureStore exists]) {
        if ([secureStore create:passcode]) {
            // TODO: Change in case passcode is changed later
            [secureStore storePasscodeForTouchId:passcode];
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSInteger passcodeTimeout = [userDefaults integerForKey:kConfigKeySecurityPasscodeTimeout];
            if (!passcodeTimeout) {
                passcodeTimeout = 0;
            }
            [secureStore setObject:@(passcodeTimeout) forKey:kSecureStorePasscodeTimeout];
            [secureStore synchronize];
            [self unlock];
        }
    } else {
        if ([secureStore open:passcode]) {
            [self unlock];
        } else {
            [self.lockScreen wrongPasscodeShake];
        }
    }
}

- (void)didUnlockWithTouchID {
    SecureStore *secureStore = [SecureStore instance];
    if ([secureStore exists]) {
        [secureStore passcodeWithTouchId:^(NSString *passcode) {
            if ([secureStore open:passcode]) {
                [self unlock];
            }
        } error:^{
            // TODO: Error
        }];
    }
}

- (void)showStartContent {
    [self showContent:[self.startViewController embedInNavigationController] hideMenu:NO];
}

- (void)updateActiveEntity:(UIViewController *)viewController {
    self.activeEntity = nil;
    SEL entitySelector = NSSelectorFromString(@"entity");
    if ([viewController respondsToSelector:entitySelector]) {
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        self.activeEntity = [viewController performSelector:entitySelector];
    }
}

- (void)showContent:(UIViewController *)viewController hideMenu:(BOOL)hideMenu {
    [self updateActiveEntity:viewController];
    self.contentViewController = viewController;
    for (UIViewController *childViewController in self.mainViewController.childViewControllers) {
        [childViewController removeFromParentViewController];
    }
    for (UIView *subView in self.mainViewController.view.subviews) {
        [subView removeFromSuperview];
    }
    viewController.view.frame = self.mainViewController.view.bounds;
    [self.mainViewController.view addSubview:viewController.view];
    [self.mainViewController addChildViewController:viewController];
    if ([viewController isKindOfClass:AbstractTabBarViewController.class]) {
        AbstractTabBarViewController *tabBarViewController = (AbstractTabBarViewController *)viewController;
        tabBarViewController.delegate = self;
        NSNumber *tabSelection = [Model instance].application.tabSelection[NSStringFromClass(tabBarViewController.class)];
        if (!tabSelection || [tabSelection integerValue] < 0 || [tabSelection integerValue] >= tabBarViewController.childViewControllers.count) {
            tabSelection = @(0);
        }
        tabBarViewController.selectedViewController = tabBarViewController.childViewControllers[[tabSelection integerValue]];
        [self tabBarController:tabBarViewController didSelectViewController:tabBarViewController.selectedViewController];
    } else {
        [self setContext:viewController title:nil];
    }
    if (hideMenu) {
        [self.mainViewController slideMenuHide:YES];
    }
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    AbstractTabBarViewController *tabBarViewController = (AbstractTabBarViewController *)tabBarController;
    [self setContext:viewController title:tabBarViewController.title];
    [Model instance].application.tabSelection[NSStringFromClass(tabBarController.class)] =
    @([tabBarViewController.childViewControllers indexOfObject:viewController]);
    [self.mainViewController enableMenuSwipe:tabBarViewController.menuSwipeEnabled];
}

- (void)setContext:(UIViewController *)viewController title:(NSString *)title {
    if ([viewController isKindOfClass:UINavigationController.class]) {
        UINavigationController *navigationController = (UINavigationController *)viewController;
        if (navigationController.viewControllers.count <= 1) {
            navigationController.topViewController.navigationItem.leftBarButtonItem = [self.mainViewController createMenuButton];
            if (title) {
                navigationController.topViewController.title = title;
            }
        }
    }
}

- (void)didShowMenu {
}

- (void)didHideMenu {
    if ([self.contentViewController isKindOfClass:UITabBarController.class]) {
        [((UITabBarController *)self.contentViewController).selectedViewController viewWillAppear:NO];
    } else if ([self.contentViewController isKindOfClass:UINavigationController.class]) {
        [((UINavigationController *)self.contentViewController).topViewController viewWillAppear:NO];
    }
}

- (void)enableMenuSwipe:(BOOL)enabled {
    [self.mainViewController enableMenuSwipe:enabled];
}

- (SettingsTabBarViewController *)settingsViewController {
    if (!_settingsViewController) {
        _settingsViewController = [SettingsTabBarViewController new];
    }
    return _settingsViewController;
}

- (void)showSettings:(BOOL)animated completion:(void (^)(void))completion {
    self.settingsVisible = YES;
    [self.settingsViewController resetViewController:self.settingsViewController];
    [self present:self.settingsViewController presenter:self.window.rootViewController animated:animated completion:completion];
}

- (void)showSetup {
    if (!self.setupViewController) {
        self.setupViewController = [SetupWelcomeViewController new];
    }
    UINavigationController *setupNavViewController = [self.setupViewController embedInNavigationController];
    [self present:setupNavViewController presenter:self.window.rootViewController animated:NO completion:nil];
}

- (void)showHelp {
    [self showStartContent];
    [self.mainViewController slideMenuHide:YES];
}

- (void)showSystemSettings {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

- (void)requestUserNotification {
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
}

- (BOOL)userNotificationAllowed {
    UIUserNotificationSettings *settings = [[UIApplication sharedApplication] currentUserNotificationSettings];
    return settings.types != UIUserNotificationTypeNone;
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    if ([self isLocked] && [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskPortrait;
    } else {
        return self.contentViewController.supportedInterfaceOrientations;
    }
}

- (void)present:(UIViewController *)viewController presenter:(UIViewController *)presenter animated:(BOOL)animated completion:(void (^)(void))completion {
    if ([viewController conformsToProtocol:@protocol(ModalViewController)] ||
        ([viewController isKindOfClass:UINavigationController.class] &&
         [[(UINavigationController *)viewController topViewController] conformsToProtocol:@protocol(ModalViewController)])) {
        [presenter presentViewController:viewController animated:animated completion:completion];
        if ([viewController isKindOfClass:UIAlertController.class]) {
            viewController.view.tintColor = [Configuration instance].highlightColor;
        }
    } else {
        [self dismissPresentedViewControllerAnimated:NO completion:^{
            self.presentedViewController = viewController;
            [presenter presentViewController:viewController animated:animated completion:completion];
            if ([viewController isKindOfClass:UIAlertController.class]) {
                viewController.view.tintColor = [Configuration instance].highlightColor;
            }
        }];
    }
}

- (void)dismissPresentedViewControllerAnimated:(BOOL)animated completion:(void (^)(void))completion {
    if (self.presentedViewController && self.presentedViewController.presentingViewController) {
        [self dismiss:self.presentedViewController animated:animated completion:completion];
        self.presentedViewController = nil;
    } else {
        if (completion) {
            completion();
        }
    }
}

- (void)dismiss:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(void))completion {
    if (viewController == self.settingsViewController ||
        viewController.parentViewController == self.settingsViewController ||
        viewController.parentViewController.parentViewController == self.settingsViewController) {
        self.settingsVisible = NO;
    }
    [viewController dismissViewControllerAnimated:animated completion:completion];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    [[Model instance] store];
    [self showStartContent];
    [self.menuNavigationController popToRootViewControllerAnimated:YES];
    [[Model instance] cleanup];
}

+ (id)instance {
	return [UIApplication sharedApplication].delegate;
}

@end