//
//  UIViewController+Extension.h
//  TeacherPlanner
//
//  Created by Oliver on 22.06.14.
//
//

#import <UIKit/UIKit.h>

@protocol ModalViewController
@end

@interface UIViewController (Extension)

- (UINavigationController *)embedInNavigationController;

@end