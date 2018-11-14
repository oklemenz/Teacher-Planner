//
//  SettingsTabBarViewController.h
//  TeacherPlanner
//
//  Created by Oliver on 17.05.14.
//
//

#import <UIKit/UIKit.h>
#import "AbstractTabBarViewController.h"
#import "SettingsPersonsViewController.h"

@interface SettingsTabBarViewController : AbstractTabBarViewController <ModalViewController>

@property (nonatomic, strong) SettingsPersonsViewController *settingsPersonsViewController;

@end