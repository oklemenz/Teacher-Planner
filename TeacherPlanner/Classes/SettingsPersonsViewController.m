//
//  SettingsPersonsViewController.m
//  TeacherPlanner
//
//  Created by Oliver Klemenz on 27.12.14.
//
//

#import "SettingsPersonsViewController.h"
#import "Model.h"
#import "Application.h"

@interface SettingsPersonsViewController ()

@end

@implementation SettingsPersonsViewController

@synthesize subTitle = _subTitle;

- (instancetype)init {
    self = [self initWithStyle:UITableViewStylePlain];
    if (self) {
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        self.name = NSLocalizedString(@"Persons", @"");
        self.subTitle = NSLocalizedString(@"Settings", @"");
        self.title = [NSString stringWithFormat:@"%@\n%@", self.name, self.subTitle];
        self.tabBarIcon = @"settings_persons";
        self.editable = YES;
        self.addable = YES;
        self.closeable = YES;
    }
    return self;
}

- (void)setSubTitle:(NSString *)subTitle {
    _subTitle = subTitle;
}

- (void)resetFilter {
    [[[Model instance] application] resetFilterPersonRef];
    self.searchBar.text = @"";
    [self.tableView reloadData];
}

@end