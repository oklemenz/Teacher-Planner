//
//  AbstractBaseViewController.h
//  TeacherPlanner
//
//  Created by Oliver on 22.06.14.
//
//

#import <UIKit/UIKit.h>
#import "PropertyBinding.h"
#import "JSONEntity.h"
#import "UIViewController+Extension.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@class AnnotationViewController;

@interface AbstractBaseViewController : UIViewController <MFMailComposeViewControllerDelegate, Bindable, PropertyBindingDelegate>

@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSString *subTitle;
@property(nonatomic, strong) NSString *tabBarIcon;
@property(nonatomic, strong) NSString *selectedTabBarIcon;
@property(nonatomic) BOOL editable;
@property(nonatomic) BOOL closeable;
@property(nonatomic) BOOL visible;
@property(nonatomic, strong) AnnotationViewController *annotationViewController;

@property(nonatomic, strong) JSONEntity *entity;

- (void)close:(id)sender;

@end