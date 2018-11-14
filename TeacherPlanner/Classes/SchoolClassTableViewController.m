//
//  SchoolClassTableViewController.m
//  TeacherPlanner
//
//  Created by Oliver on 13.04.14.
//
//

#import "SchoolClassTableViewController.h"
#import "SchoolClassExportTableViewController.h"
#import "SchoolYear.h"
#import "SchoolClass.h"
#import "ShareUtilities.h"
#import "UIBarButtonItem+Extension.h"
#import "AppDelegate.h"

@interface SchoolClassTableViewController ()

@end

@implementation SchoolClassTableViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.subTitle = NSLocalizedString(@"Classes", @"");
        self.definition = @{
                            @"context" : @"schoolClass",
                            @"placeholder" : NSLocalizedString(@"School Class Name", @""),
                            @"group" : @(YES),
                            @"delete" : @(YES),
                            @"copy" : @(YES),
                            @"cellStyle" : @(UITableViewCellStyleValue1),
                            @"bindings" : @[ @{ @"property" : @"name" },
                                             @{ @"property" : @"color",
                                                @"bindableProperty" : @"color" },
                                             @{ @"property" : @"subject",
                                                @"bindableProperty" : @"detailText" }],
                            @"detail" : @{
                                    @"className" : @"StudentTableViewController"
                                    },
                            @"content" : @{
                                    @"className" : @"SchoolClassTabBarViewController",
                                    @"bindings" : @[ @{ @"property" : @"name",
                                                        @"bindableProperty" : @"title" } ]
                                    }};
    }
    return self;
}

- (SchoolYear *)schoolYear {
    return (SchoolYear *)self.entity;
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *actions = [[super tableView:tableView editActionsForRowAtIndexPath:indexPath] mutableCopy];

    UITableViewRowAction *exportButton = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:NSLocalizedString(@"Export", @"") handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        SchoolClass *schoolClass = [self.schoolYear schoolClassByGroup:indexPath.section index:indexPath.row];
        [self export:schoolClass indexPath:indexPath];
    }];
    [actions addObject:exportButton];
    
    return actions;
}

- (void)export:(SchoolClass *)schoolClass indexPath:(NSIndexPath *)indexPath {
    [self.tableView setEditing:YES];
    [self.tableView setEditing:NO];
    [ShareUtilities showExportSchoolClassActionSheet:schoolClass presenter:self];
}

- (NSArray *)toolbarItems {
    NSMutableArray *items = [super.toolbarItems mutableCopy];
    if (items.count > 0) {
        UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        [items addObject:flexibleSpace];
    }

    UIBarButtonItem *importButton = [UIBarButtonItem createCustomTintedBottomBarButtonItem:@"school_class_import"];
    [(UIButton *)importButton.customView addTarget:self action:@selector(didPressAction:)
                                    forControlEvents:UIControlEventTouchUpInside];
    [items addObject:importButton];
    
    return items;
}

- (void)didPressAction:(id)sender {
    SchoolClassExportTableViewController *schoolClassExport = [SchoolClassExportTableViewController new];
    schoolClassExport.entity = self.entity;
    UINavigationController *export = [schoolClassExport embedInNavigationController];
    [[AppDelegate instance] present:export presenter:self animated:YES completion:nil];
}

@end