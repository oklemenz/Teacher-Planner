//
//  PersonGeneralViewController.m
//  TeacherPlanner
//
//  Created by Oliver Klemenz on 27.12.14.
//
//

#import "PersonGeneralViewController.h"

@interface PersonGeneralViewController ()

@end

@implementation PersonGeneralViewController

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
        self.tabBarIcon = @"person_general";
        self.editable = YES;
        
        self.definition = @[ @{ @"title" : NSLocalizedString(@"Person", @""),
                                @"definition" : @[
                                        @{ @"title" : NSLocalizedString(@"Photo", @""),
                                           @"control" : @"PhotoPicker",
                                           @"bindings" : @[ @{ @"property" : @"photoUUID" } ],
                                           @"display" : @{
                                                   @"height" : @(120) },
                                           @"edit" : @{
                                                   @"height" : @(120) } },
                                        @{ @"title" : NSLocalizedString(@"Name", @""),
                                           @"control" : @"Edit",
                                           @"label" : @(YES),
                                           @"bindings" : @[ @{ @"property" : @"name" } ] },
                                        @{ @"title" : NSLocalizedString(@"Address", @""),
                                           @"control" : @"MultilineEdit",
                                           @"bindings" : @[ @{ @"property" : @"address" } ],
                                           @"label" : @(YES),
                                           @"display" : @{
                                                   @"height" : @(84) },
                                           @"edit" : @{
                                                   @"height" : @(84) } },
                                        @{ @"title" : NSLocalizedString(@"Phone", @""),
                                           @"control" : @"Edit",
                                           @"label" : @(YES),
                                           @"bindings" : @[ @{ @"property" : @"phone" } ] },
                                        @{ @"title" : NSLocalizedString(@"E-Mail", @""),
                                           @"control" : @"Edit",
                                           @"options" : @{
                                                   @"keyboard" : @(UIKeyboardTypeEmailAddress),
                                                   },
                                           @"label" : @(YES),
                                           @"bindings" : @[ @{ @"property" : @"email" } ] },
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
    return [NSString stringWithFormat:@"%@", NSLocalizedString(@"Persons", @"")];
}

@end