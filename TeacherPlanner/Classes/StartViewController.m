//
//  StartViewController.m
//  TeacherPlanner
//
//  Created by Klemenz, Oliver on 13.09.13.
//  Copyright (c) 2013 Oliver Klemenz. All rights reserved.
//

#import "StartViewController.h"
#import "UITabBarItem+Extension.h"

@interface StartViewController ()
@end

@implementation StartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"Teacher Planner", @"");
    
    // TODO: Add tab bar item
    self.tabBarItem = [UITabBarItem createCustomTintedBottomTabBarItem:NSLocalizedString(@"General", @"") imageName:@"settings" selectedImageName:nil];
    
    UIBarButtonItem *actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:nil action:nil];
    actionButton.enabled  = NO;
    self.editButtonItem.enabled = NO;
    self.navigationItem.rightBarButtonItems = @[self.editButtonItem, actionButton];
    
    // TODO: Add arrows
    
    UILabel *welcomeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    welcomeLabel.numberOfLines = 2;
    welcomeLabel.text = NSLocalizedString(@"Welcome to\nTeacher Planner!", @"");
    welcomeLabel.textAlignment = NSTextAlignmentCenter;
    welcomeLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:30.0f];
    [welcomeLabel sizeToFit];
    welcomeLabel.center = self.view.center;
    [self.view addSubview:welcomeLabel];
    
    UILabel *menuLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    menuLabel.numberOfLines = 5;
    menuLabel.text = NSLocalizedString(@"Access School Years,\nSchool Classes, Students\nand application settings", @"");
    menuLabel.textAlignment = NSTextAlignmentLeft;
    menuLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0f];
    [menuLabel sizeToFit];
    menuLabel.frame = CGRectMake(10.0f, 100.0f, menuLabel.frame.size.width, menuLabel.frame.size.height);
    [self.view addSubview:menuLabel];

    UILabel *actionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    actionLabel.numberOfLines = 5;
    actionLabel.text = NSLocalizedString(@"Edit and execute\n actions on\n selected entities", @"");
    actionLabel.textAlignment = NSTextAlignmentRight;
    actionLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0f];
    [actionLabel sizeToFit];
    actionLabel.frame = CGRectMake(self.view.frame.size.width - actionLabel.frame.size.width - 10.0f, 100.0f,
                                 actionLabel.frame.size.width, menuLabel.frame.size.height);
    [self.view addSubview:actionLabel];

    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    contentLabel.numberOfLines = 5;
    contentLabel.text = NSLocalizedString(@"Selection tabs to display\n content facets of entity ", @"");
    contentLabel.textAlignment = NSTextAlignmentCenter;
    contentLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0f];
    [contentLabel sizeToFit];
    contentLabel.frame = CGRectMake((self.view.frame.size.width - contentLabel.frame.size.width) / 2.0,
                                    self.view.frame.size.height - 130.0f,
                                   contentLabel.frame.size.width, menuLabel.frame.size.height);
    [self.view addSubview:contentLabel];

    
}

@end