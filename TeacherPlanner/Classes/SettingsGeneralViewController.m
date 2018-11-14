//
//  SettingsGeneralViewController.m
//  TeacherPlanner
//
//  Created by Oliver on 17.05.14.
//
//

#import "SettingsGeneralViewController.h"
#import "Model.h"
#import "Application.h"
#import "Settings.h"

@interface SettingsGeneralViewController ()
@end

@implementation SettingsGeneralViewController

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
        self.subTitle = NSLocalizedString(@"Settings", @"");
        self.title = [NSString stringWithFormat:@"%@\n%@", self.name, self.subTitle];
        self.tabBarIcon = @"settings_general";
        self.editable = YES;
        self.closeable = YES;

        self.entity = [Model instance].application.settings;
        self.definition = @[ @{ @"title" : NSLocalizedString(@"Teacher", @""),
                                @"context" : @"teacher",
                                @"definition" : @[
                                        @{ @"title" : NSLocalizedString(@"Photo", @""),
                                           @"control" : @"PhotoPicker",
                                           @"bindings" : @[ @{ @"property" : @"photoUUID" } ],
                                           @"display" : @{
                                                   @"height" : @(120) },
                                           @"edit" : @{
                                                   @"height" : @(120) } },
                                        @{ @"title" : NSLocalizedString(@"Title", @""),
                                           @"control" : @"CodePicker",
                                           @"selectedEditing" : @(YES),
                                           @"code" : @"CodePersonTitle",
                                           @"options" : @{
                                                   @"includeEmpty" : @(YES),
                                                   @"showTitle" : @(YES)
                                                   },
                                           @"bindings" : @[ @{ @"property" : @"title" } ],
                                           @"edit" : @{
                                                   @"height" : @(150),
                                                   @"offsetX" : @(15),
                                                   @"offsetY" : @(0) } },
                                        @{ @"title" : NSLocalizedString(@"First Name", @""),
                                           @"control" : @"Edit",
                                           @"bindings" : @[ @{ @"property" : @"firstName" } ] },
                                        @{ @"title" : NSLocalizedString(@"Last Name", @""),
                                           @"control" : @"Edit",
                                           @"bindings" : @[ @{ @"property" : @"lastName" } ] },
                                        @{ @"title" : NSLocalizedString(@"Code", @""),
                                           @"control" : @"Edit",
                                           @"bindings" : @[ @{ @"property" : @"code" } ],
                                           @"options" : @{
                                                   @"keyboard" : @(UIKeyboardTypeEmailAddress),
                                                   @"autocapitalization" : @(UITextAutocapitalizationTypeAllCharacters) } },
                                        @{ @"title" : NSLocalizedString(@"E-mail", @""),
                                           @"control" : @"Edit",
                                           @"bindings" : @[ @{ @"property" : @"email" } ],
                                           @"options" : @{
                                                   @"keyboard" : @(UIKeyboardTypeEmailAddress),
                                                   @"autocapitalization" : @(UITextAutocapitalizationTypeNone)
                                                   } },
                                        @{ @"title" : NSLocalizedString(@"Birth Date", @""),
                                           @"control" : @"DatePicker",
                                           @"label" : @(YES),
                                           @"selectedEditing" : @(YES),
                                           @"bindings" : @[ @{ @"property" : @"birthDate" } ],
                                           @"edit" : @{
                                                   @"height" : @(185),
                                                   @"offsetX" : @(15),
                                                   @"offsetY" : @(10) },
                                           @"options" : @{
                                                   @"mode" : @(UIDatePickerModeDate),
                                                   @"showTitle" : @(YES)
                                                   }}
                                ] },
                             @{ @"title" : NSLocalizedString(@"School", @""),
                                @"context" : @"school",
                                @"definition" : @[
                                        @{ @"title" : NSLocalizedString(@"Name", @""),
                                           @"control" : @"Edit",
                                           @"bindings" : @[ @{ @"property" : @"name" } ] },
                                        @{ @"title" : NSLocalizedString(@"Address", @""),
                                           @"control" : @"MultilineEdit",
                                           @"bindings" : @[ @{ @"property" : @"address" } ],
                                           @"label" : @(YES),
                                           @"display" : @{
                                                   @"height" : @(84) },
                                           @"edit" : @{
                                                   @"height" : @(84) } },
                                        @{ @"title" : NSLocalizedString(@"Country", @""),
                                           @"control" : @"Edit",
                                           @"bindings" : @[ @{ @"property" : @"country" } ] },
                                        @{ @"title" : NSLocalizedString(@"State", @""),
                                           @"control" : @"CodeSelection",
                                           @"code" : @"CodeGermanyState",
                                           @"selection" : @(YES),
                                           @"label" : @(YES),
                                           @"bindings" : @[ @{ @"property" : @"state" } ] },
                                        @{ @"title" : NSLocalizedString(@"School Times", @""),
                                           @"control" : @"Count",
                                           @"context" : @"schoolTime",
                                           @"selection" : @(YES),
                                           @"detail" : @{
                                                   @"bindings" : @[ @{ @"property" : @"startTime",
                                                                       @"bindableProperty" : @"valueStart" },
                                                                    @{ @"property" : @"endTime",
                                                                       @"bindableProperty" : @"valueEnd" } ],
                                                   @"selectedEditing" : @(YES),
                                                   @"delete" : @(YES),
                                                   @"control" : @"TimeFromTo",
                                                   @"select" : @{
                                                           @"height" : @(162),
                                                           @"offsetY" : @(0) } } },
                                        @{ @"title" : NSLocalizedString(@"School Weekdays", @""),
                                           @"control" : @"CodePicker",
                                           @"code" : @"CodeSchoolWeekDay",
                                           @"selectedEditing" : @(YES),
                                           @"options" : @{
                                                   @"showTitle" : @(YES)
                                                   },
                                           @"bindings" : @[ @{ @"property" : @"schoolWeekdays" } ],
                                           @"edit" : @{
                                                   @"height" : @(175),
                                                   @"offsetX" : @(15),
                                                   @"offsetY" : @(0) } }
                                ] },
                              @{ @"title" : NSLocalizedString(@"Misc", @""),
                                 @"definition" : @[
                                         @{ @"title" : NSLocalizedString(@"Private Mode", @""),
                                            @"control" : @"Switch",
                                            @"bindings" : @[ @{ @"property" : @"isPrivate" } ] },
                                         @{ @"title" : NSLocalizedString(@"Prompt Touch ID", @""),
                                            @"control" : @"Switch",
                                            @"bindings" : @[ @{ @"property" : @"promptTouchID" } ] }
                                         ] },
                             ];
    }
    return self;
}

@end