//
//  SetupBaseViewController.m
//  TeacherPlanner
//
//  Created by Oliver Klemenz on 14.06.15.
//
//

#import "SetupBaseViewController.h"
#import "Common.h"
#import "AppDelegate.h"

@interface SetupBaseViewController ()

@end

@implementation SetupBaseViewController

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)createFormField:(NSString *)labelText form:(UIView *)form row:(NSInteger)row {
    UILabel *textLabel = [UILabel new];
    textLabel.text = NSLocalizedString(labelText, @"");
    textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20];
    textLabel.frame = CGRectMake(0, 0 + row * 35, 100, 25);
    textLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    [form addSubview:textLabel];
    
    UITextField *textField = [UITextField new];
    textField.placeholder = NSLocalizedString(labelText, @"");
    textField.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20];
    textField.frame = CGRectMake(110, 0 + row * 35, form.bounds.size.width - 110, 25);
    CALayer *textFieldBorder = [CALayer layer];
    textFieldBorder.frame = CGRectMake(0.0f, textField.frame.size.height - 1.0f, textField.frame.size.width, 1.0f);
    textFieldBorder.backgroundColor = [UIColor lightGrayColor].CGColor;
    [textField.layer addSublayer:textFieldBorder];
    textField.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [form addSubview:textField];
}

- (void)didPressSkip:(id)sender {
    [Common showConfirmation:self title:NSLocalizedString(@"Teacher Planner", @"") message:NSLocalizedString(@"Do you want to skip the guided setup?", @"") okButtonTitle:nil destructive:NO cancelButtonTitle:nil okHandler:^{
        [[AppDelegate instance] dismiss:self animated:YES completion:nil];
    } cancelHandler:nil];
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

@end