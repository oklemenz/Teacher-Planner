//
//  AbstractTabBarViewController.h
//  TeacherPlanner
//
//  Created by Oliver on 25.05.14.
//
//

#import <UIKit/UIKit.h>
#import "JSONEntity.h"
#import "Bindable.h"

@interface AbstractTabBarViewController : UITabBarController <Bindable>

@property(nonatomic, strong) JSONEntity *entity;

- (BOOL)menuSwipeEnabled;
- (void)resetViewController:(UIViewController *)viewController;

@end