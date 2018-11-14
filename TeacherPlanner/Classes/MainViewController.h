//
//  MainViewController.h
//  TeacherPlanner
//
//  Created by Oliver on 30.05.14.
//
//

#import <UIKit/UIKit.h>

#define SLIDE_TIME        0.75
#define SLIDE_SPRING_DAMP 0.8
#define SLIDE_SPRING_VELO 1.0
#define SLIDE_OUT         270
#define SLIDE_BIAS         50
#define SLIDE_BEVEL        40

@protocol MainViewControllerDelegate <NSObject>
@optional
- (void)didShowMenu;
- (void)didHideMenu;
@end

@interface MainViewController : UIViewController<UIGestureRecognizerDelegate>

@property(nonatomic, weak) id<MainViewControllerDelegate> delegate;

- (UIBarButtonItem *)createMenuButton;
- (void)attachSlideGesture;
- (void)slideMenuShow:(BOOL)animated;
- (void)slideMenuHide:(BOOL)animated;

- (void)enableMenuSwipe:(BOOL)enabled;

@end
