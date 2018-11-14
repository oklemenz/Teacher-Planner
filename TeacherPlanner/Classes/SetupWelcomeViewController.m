//
//  SetupWelcomeViewController.m
//  TeacherPlanner
//
//  Created by Oliver Klemenz on 14.06.15.
//
//

#import "SetupWelcomeViewController.h"
#import "UILabel+Extension.h"
#import "SetupTeacherViewController.h"

@interface SetupWelcomeViewController ()
@property (nonatomic, strong) UILabel *startLabel;
@property (nonatomic) BOOL animated;
@end

@implementation SetupWelcomeViewController

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Teacher Planner", @"");
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *startButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Start >", @"")
                                                                    style:UIBarButtonItemStylePlain target:self
                                                                   action:@selector(didPressStart:)];
    UIBarButtonItem *skipButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Skip", @"")
                                                                    style:UIBarButtonItemStylePlain target:self
                                                                   action:@selector(didPressSkip:)];
    self.navigationItem.rightBarButtonItems = @[startButton, skipButton];
    
    UILabel *welcomeLabel = [UILabel new];
    welcomeLabel.text = NSLocalizedString(@"Welcome", @"");
    welcomeLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:45];
    [welcomeLabel sizeToFit];
    welcomeLabel.center = self.view.center;
    welcomeLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:welcomeLabel];
    
    self.startLabel = [UILabel createSlideLabel:NSLocalizedString(@"> Tap Start to Setup <", @"")
                                           frame:CGRectMake(0.0f, 0.0f, 350.0f, 50.0f)
                                       direction:SlideDirectionLeftToRight];
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didPressStart:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    self.startLabel.userInteractionEnabled = YES;
    [self.startLabel addGestureRecognizer:tapGestureRecognizer];
    self.startLabel.textColor = [UIColor blackColor];
    
    self.startLabel.textAlignment = NSTextAlignmentCenter;
    CGFloat offsetX = (self.view.bounds.size.width - self.startLabel.bounds.size.width) / 2.0f;
    CGFloat offsetY = self.view.frame.size.height - 75;
    self.startLabel.frame = CGRectMake(offsetX, offsetY,
                                       self.startLabel.bounds.size.width,
                                       self.startLabel.bounds.size.height);
    self.startLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleTopMargin;

    [self.view addSubview:self.startLabel];
}

- (void)didPressStart:(id)sender {
    SetupTeacherViewController *teacherViewController = [SetupTeacherViewController new];
    [self.navigationController pushViewController:teacherViewController animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!animated) {
        [self resume];
        animated = YES;
    }
}

- (void)resume {
    [self.startLabel addSlideAnimation:SlideDirectionLeftToRight duration:2.0];
}

@end