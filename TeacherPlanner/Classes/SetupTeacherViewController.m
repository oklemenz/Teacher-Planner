//
//  SetupTeacherViewController.m
//  TeacherPlanner
//
//  Created by Oliver Klemenz on 14.06.15.
//
//

#import "SetupTeacherViewController.h"
#import "SetupSchoolViewController.h"

@interface SetupTeacherViewController ()
@property (nonatomic, strong) UIView *form;
@end

@implementation SetupTeacherViewController

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Teacher", @"");
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *schoolButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"School >", @"")
                                                                    style:UIBarButtonItemStylePlain target:self
                                                                   action:@selector(didPressSchool:)];
    UIBarButtonItem *skipButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Skip", @"")
                                                                   style:UIBarButtonItemStylePlain target:self
                                                                  action:@selector(didPressSkip:)];
    self.navigationItem.rightBarButtonItems = @[schoolButton, skipButton];
    
    UILabel *headerLabel = [UILabel new];
    headerLabel.text = NSLocalizedString(@"Give information about you", @"");
    headerLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:25];
    [headerLabel sizeToFit];
    headerLabel.center = CGPointMake(self.view.center.x, 100);
    headerLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:headerLabel];
    
    UILabel *subHeaderLabel = [UILabel new];
    subHeaderLabel.text = NSLocalizedString(@"Enter your name and your email address", @"");
    subHeaderLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
    [subHeaderLabel sizeToFit];
    subHeaderLabel.center = CGPointMake(self.view.center.x, 130);
    subHeaderLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:subHeaderLabel];
    
    [self createForm];
}

- (void)createForm {
    self.form = [[UIView alloc] initWithFrame:CGRectMake(40, 50, self.view.bounds.size.width - 80, 100)];
    self.form.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.form.center = CGPointMake(self.view.center.x, self.view.center.y - 50);
    [self.view addSubview:self.form];
    
    [self createFormField:NSLocalizedString(@"First Name", @"") form:self.form row:0];
    [self createFormField:NSLocalizedString(@"Last Name", @"") form:self.form row:1];
    [self createFormField:NSLocalizedString(@"Email", @"") form:self.form row:2];
}

- (void)didPressSchool:(id)sender {
    SetupSchoolViewController *schoolViewController = [SetupSchoolViewController new];
    [self.navigationController pushViewController:schoolViewController animated:YES];
}

@end