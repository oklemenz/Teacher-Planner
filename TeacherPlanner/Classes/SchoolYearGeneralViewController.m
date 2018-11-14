//
//  SchoolYearGeneralViewController.m
//  TeacherPlanner
//
//  Created by Oliver on 04.05.14.
//
//

#import "SchoolYearGeneralViewController.h"

@interface SchoolYearGeneralViewController ()
@end

@implementation SchoolYearGeneralViewController

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
        self.subTitle = self.name;
        self.tabBarIcon = @"school_year_general";
        self.editable = YES;
        
        self.definition = @[ @{ @"title" : NSLocalizedString(@"School Year", @""),
                                @"definition" : @[
                                        @{ @"title" : NSLocalizedString(@"Name", @""),
                                           @"control" : @"Edit",
                                           @"label" : @(YES),
                                           @"bindings" : @[ @{ @"property" : @"name" } ] },
                                        @{ @"title" : NSLocalizedString(@"Active", @""),
                                           @"control" : @"Switch",
                                           @"bindings" : @[ @{ @"property" : @"isActive" } ] },
                                        @{ @"title" : NSLocalizedString(@"In Planning", @""),
                                           @"control" : @"Switch",
                                           @"bindings" : @[ @{ @"property" : @"isPlanned" } ] },
                                        @{ @"title" : NSLocalizedString(@"Merge Lesson Cells", @""),
                                           @"control" : @"Switch",
                                           @"bindings" : @[ @{ @"property" : @"mergeLessonCells" } ] },
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

@end