//
//  StudentGeneralViewController.m
//  TeacherPlanner
//
//  Created by Oliver on 17.05.14.
//
//

#import "StudentGeneralViewController.h"
#import "Application.h"
#import "Model.h"
#import "Student.h"

@interface StudentGeneralViewController ()

@end

@implementation StudentGeneralViewController

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
        self.tabBarIcon = @"student_general";
        self.editable = YES;
        
        self.definition = @[ @{ @"title" : NSLocalizedString(@"Student", @""),
                                @"definition" : @[
                                        @{ @"title" : NSLocalizedString(@"Photo", @""),
                                           @"control" : @"PhotoPicker",
                                           @"bindings" : @[ @{ @"property" : @"photoUUID",
                                                               @"context" : @"person" } ],
                                           @"display" : @{
                                                   @"height" : @(120) },
                                           @"edit" : @{
                                                   @"height" : @(120) } },
                                        @{ @"title" : NSLocalizedString(@"Name", @""),
                                           @"control" : @"Edit",
                                           @"label" : @(YES),
                                           @"selection" : @(YES),
                                           @"bindings" : @[ @{ @"property" : @"name",
                                                               @"context" : @"person" },
                                                            @{ @"property" : @"personUUID",
                                                               @"bindableProperty" : @"uuid" } ],
                                           @"displayDetail" : @{
                                                   @"context" : @"person",
                                                   @"className" : @"PersonListDetailTableViewController" },
                                           @"editDetail" : @{
                                                   @"title" : NSLocalizedString(@"Assign Person", @""),
                                                   @"subTitle" : NSLocalizedString(@"Persons", @""),
                                                   @"context" : @"/personRef",                                                   
                                                   @"suppressEdit" : @(YES),
                                                   @"selection" : @(YES),
                                                   @"suppressSelectionClear" : @(YES),
                                                   @"className" : @"PersonListTableViewController" } },
                                        @{ @"title" : NSLocalizedString(@"Address", @""),
                                           @"control" : @"MultilineEdit",
                                           @"bindings" : @[ @{ @"property" : @"address",
                                                               @"context" : @"person" } ],
                                           @"label" : @(YES),
                                           @"display" : @{
                                                   @"height" : @(84) },
                                           @"edit" : @{
                                                   @"height" : @(84) } },
                                        @{ @"title" : NSLocalizedString(@"Phone", @""),
                                           @"control" : @"Edit",
                                           @"label" : @(YES),
                                           @"bindings" : @[ @{ @"property" : @"phone",
                                                               @"context" : @"person" } ] },
                                        @{ @"title" : NSLocalizedString(@"E-Mail", @""),
                                           @"control" : @"Edit",
                                           @"label" : @(YES),
                                           @"options" : @{
                                                   @"keyboard" : @(UIKeyboardTypeEmailAddress),
                                                   },
                                           @"bindings" : @[ @{ @"property" : @"email",
                                                               @"context" : @"person" } ] },
                                        @{ @"title" : NSLocalizedString(@"Overall Rating", @""),
                                           @"control" : @"Rating",
                                           @"bindings" : @[ @{ @"property" : @"rating" } ] },
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
    return [NSString stringWithFormat:@"%@ - %@ - %@", self.name, self.student.parent.parent.name, self.student.parent.name];
}

- (Student *)student {
    return (Student *)self.entity;
}

@end
