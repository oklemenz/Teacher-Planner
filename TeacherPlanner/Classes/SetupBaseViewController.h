//
//  SetupBaseViewController.h
//  TeacherPlanner
//
//  Created by Oliver Klemenz on 14.06.15.
//
//

#import <UIKit/UIKit.h>

@interface SetupBaseViewController : UIViewController

- (void)createFormField:(NSString *)labelText form:(UIView *)form row:(NSInteger)row;
- (void)didPressSkip:(id)sender;

@end