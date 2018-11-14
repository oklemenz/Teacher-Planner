//
//  SchoolYearTableViewController.m
//  TeacherPlanner
//
//  Created by Oliver on 13.04.14.
//
//

#import "SchoolYearTableViewController.h"
#import "Model.h"
#import "Application.h"

@interface SchoolYearTableViewController ()
@end

@implementation SchoolYearTableViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.name = NSLocalizedString(@"Years", @"");
        self.definition = @{
                            @"context" : @"schoolYearRef",
                            @"placeholder" : NSLocalizedString(@"School Year Name", @""),
                            @"ref" : @(YES),
                            @"group" : @(YES),
                            @"delete" : @(YES),
                            @"copy" : @(YES),
                            @"bindings" : @[ @{ @"property" : @"name" } ],
                            @"detail" : @{
                                    @"className" : @"SchoolClassTableViewController"
                                    },
                            @"content" : @{
                                    @"className" : @"SchoolYearTabBarViewController",
                                    @"bindings" : @[ @{ @"property" : @"name",
                                                        @"bindableProperty" : @"title" } ]
                                    }};
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.entity = [Model instance].application;
}

- (Application *)application {
    return (Application *)self.entity;
}

- (void)setContext:(id)contextValue source:(id)source userInfo:(NSDictionary *)userInfo {
    if ([userInfo[@"property"] isEqualToString:@"isActive"] ||
        [userInfo[@"property"] isEqualToString:@"isPlanned"]) {
        [self.application sortSchoolYearRef];
        [self.tableView reloadData];
    } else {
        [super setContext:contextValue source:source userInfo:userInfo];
    }
}

@end