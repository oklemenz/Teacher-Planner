//
//  PersonListDetailTableViewController.m
//  TeacherPlanner
//
//  Created by Oliver Klemenz on 29.12.14.
//
//

#import "PersonListDetailTableViewController.h"
#import "UIBarButtonItem+Extension.h"
#import "PersonAnnotationViewController.h"

@interface PersonListDetailTableViewController ()

@property (nonatomic, strong) JSONEntity *entity;
@property (nonatomic, strong) UIBarButtonItem *annotationButton;

@end

@implementation PersonListDetailTableViewController

@synthesize entity = _entity;

- (instancetype)init {
    self = [self initWithStyle:UITableViewStyleGrouped];
    if (self) {
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        self.name = NSLocalizedString(@"Persons", @"");
        
        self.annotationButton = [UIBarButtonItem createCustomTintedTopBarButtonItem:@"annotation"];
        [(UIButton *)self.annotationButton.customView addTarget:self action:@selector(didPressAnnotation:)
                                            forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItems = @[self.navigationItem.rightBarButtonItem, self.annotationButton];
    }
    return self;
}

- (JSONEntity *)entity {
    return _entity;
}

- (void)setEntity:(JSONEntity *)entity {
    _entity = entity;
}

- (NSString *)subTitle {
    return [NSString stringWithFormat:@"%@", self.name];
}

- (void)didPressAnnotation:(id)sender {
    [self showAnnotations];
}

- (void)showAnnotations {
    PersonAnnotationViewController *annotationController = [PersonAnnotationViewController new];
    annotationController.entity = self.entity;
    [self.navigationController pushViewController:annotationController animated:YES];
}

@end
