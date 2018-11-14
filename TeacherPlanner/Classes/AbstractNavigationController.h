//
//  AbstractNavigationController.h
//  TeacherPlanner
//
//  Created by Oliver on 20.06.14.
//
//

#import <UIKit/UIKit.h>
#import "JSONEntity.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface AbstractNavigationController : UINavigationController <MFMailComposeViewControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate>

@end