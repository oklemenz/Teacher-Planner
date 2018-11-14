//
//  RootViewController.m
//  TeacherPlanner
//
//  Created by Oliver on 04.01.14.
//
//

#import "RootViewController.h"
#import "Configuration.h"
#import "AppDelegate.h"

@interface RootViewController ()

@end

@implementation RootViewController

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)close:(id)sender {
    [[AppDelegate instance] dismiss:self animated:YES completion:nil];
}

@end