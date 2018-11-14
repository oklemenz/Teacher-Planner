//
//  SettingsTabBarViewController.m
//  TeacherPlanner
//
//  Created by Oliver on 17.05.14.
//
//

#import "SettingsTabBarViewController.h"
#import "SettingsGeneralViewController.h"
#import "SettingsExportViewController.h"
#import "SettingsConfigurationViewController.h"
#import "SettingsPersonsViewController.h"

@interface SettingsTabBarViewController ()

@end

@implementation SettingsTabBarViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        SettingsGeneralViewController *settingsGeneralViewController = [SettingsGeneralViewController new];
        SettingsConfigurationViewController *settingsConfigurationViewController =
                [SettingsConfigurationViewController new];
        self.settingsPersonsViewController = [SettingsPersonsViewController new];
        SettingsExportViewController *settingsExportViewController = [SettingsExportViewController new];
        
        [self setViewControllers:@[[settingsGeneralViewController embedInNavigationController],
                                   [settingsConfigurationViewController embedInNavigationController],
                                   [self.settingsPersonsViewController embedInNavigationController],
                                   [settingsExportViewController embedInNavigationController]]];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)resetViewController:(UIViewController *)viewController {
    [self.settingsPersonsViewController resetFilter];
    [super resetViewController:viewController];
}

@end