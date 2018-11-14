//
//  SetupSchoolViewController.m
//  TeacherPlanner
//
//  Created by Oliver Klemenz on 14.06.15.
//
//

#import "SetupSchoolViewController.h"

@interface SetupSchoolViewController ()
@property (nonatomic, strong) UIView *form;
@end

@implementation SetupSchoolViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"School", @"");
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *schoolButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"State >", @"")
                                                                     style:UIBarButtonItemStylePlain target:self
                                                                    action:@selector(didPressState:)];
    UIBarButtonItem *skipButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Skip", @"")
                                                                   style:UIBarButtonItemStylePlain target:self
                                                                  action:@selector(didPressSkip:)];
    self.navigationItem.rightBarButtonItems = @[schoolButton, skipButton];
    
    UILabel *headerLabel = [UILabel new];
    headerLabel.text = NSLocalizedString(@"Provide details to your school", @"");
    headerLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:25];
    [headerLabel sizeToFit];
    headerLabel.center = CGPointMake(self.view.center.x, 100);
    headerLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:headerLabel];
    
    UILabel *subHeaderLabel = [UILabel new];
    subHeaderLabel.text = NSLocalizedString(@"Enter the school name and the country", @"");
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
    
    [self createFormField:NSLocalizedString(@"Name", @"") form:self.form row:0];
    [self createFormField:NSLocalizedString(@"Country", @"") form:self.form row:1];
}

- (void)didPressState:(id)sender {
    
}

@end
