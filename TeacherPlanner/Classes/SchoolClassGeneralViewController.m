//
//  SchoolClassGeneralViewController.m
//  TeacherPlanner
//
//  Created by Oliver on 17.05.14.
//
//

#import "SchoolClassGeneralViewController.h"
#import "SchoolClass.h"
#import "ShareUtilities.h"

@interface SchoolClassGeneralViewController ()

@end

@implementation SchoolClassGeneralViewController

- (instancetype)init {
    self = [self initWithStyle:UITableViewStyleGrouped];
    if (self) {
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        self.name = NSLocalizedString(@"General", @"");
        self.tabBarIcon = @"school_class_general";
        self.editable = YES;

        UIBarButtonItem *actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(didPressAction:)];
        self.navigationItem.rightBarButtonItems = @[self.editButtonItem, actionButton];
        
        self.definition = @[ @{ @"title" : NSLocalizedString(@"School Class", @""),
                                @"definition" : @[
                                        @{ @"title" : NSLocalizedString(@"Name", @""),
                                           @"control" : @"Edit",
                                           @"label" : @(YES),
                                           @"bindings" : @[ @{ @"property" : @"name" } ] },
                                        @{ @"title" : NSLocalizedString(@"Photo", @""),
                                           @"control" : @"PhotoPicker",
                                           @"bindings" : @[ @{ @"property" : @"photoUUID" } ],
                                           @"display" : @{
                                                   @"height" : @(120) },
                                           @"edit" : @{
                                                   @"height" : @(120) } },
                                        @{ @"title" : NSLocalizedString(@"Subject", @""),
                                           @"control" : @"Edit",
                                           @"label" : @(YES),
                                           @"bindings" : @[ @{ @"property" : @"subject" } ] },
                                        @{ @"title" : NSLocalizedString(@"Lessons", @""),
                                           @"control" : @"Count",
                                           @"context" : @"lesson",
                                           @"selection" : @(YES),
                                           @"detail" : @{
                                                   @"bindings" : @[ @{ @"property" : @"name",
                                                                       @"bindableProperty" : @"text" },
                                                                    @{ @"property" : @"room",
                                                                       @"bindableProperty" : @"detailText" }],
                                                   @"delete" : @(YES),
                                                   @"control" : @"Display",
                                                   @"cellStyle" : @(UITableViewCellStyleValue1),
                                                   @"detail" : @{
                                                           @"className" : @"SchoolClassLessonsViewController"
                                                           } } },
                                        @{ @"title" : NSLocalizedString(@"Class Room", @""),
                                           @"control" : @"Edit",
                                           @"label" : @(YES),
                                           @"bindings" : @[ @{ @"property" : @"classroom" } ] },
                                        @{ @"title" : NSLocalizedString(@"Color", @""),
                                           @"control" : @"ColorPicker",
                                           @"bindings" : @[ @{ @"property" : @"color" } ],
                                           @"display" : @{
                                                   @"height" : @(70) },
                                           @"edit" : @{
                                                   @"offsetX" : @(20),
                                                   @"offsetY" : @(10),
                                                   @"height" : @(200) } },
                                        @{ @"title" : NSLocalizedString(@"Comment", @""),
                                           @"control" : @"MultilineEdit",
                                           @"bindings" : @[ @{ @"property" : @"comment" } ],
                                           @"label" : @(NO),
                                           @"display" : @{
                                                   @"height" : @(168) },
                                           @"edit" : @{
                                                   @"height" : @(168) } }
                                        ] } ];
    }
    return self;
}

- (NSString *)subTitle {
    return [NSString stringWithFormat:@"%@ - %@", self.name, self.schoolClass.parent.name];
}

- (void)didPressAction:(id)sender {
    [ShareUtilities showExportSchoolClassActionSheet:self.schoolClass presenter:self];
}

- (SchoolClass *)schoolClass {
    return (SchoolClass *)self.entity;
}

@end