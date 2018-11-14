//
//  SettingsConfigurationViewController.m
//  TeacherPlanner
//
//  Created by Oliver Klemenz on 27.12.14.
//
//

#import "SettingsConfigurationViewController.h"
#import "TransientConfiguration.h"
#import "Utilities.h"
#import "ShareUtilities.h"

@interface SettingsConfigurationViewController ()

@end

@implementation SettingsConfigurationViewController

- (instancetype)init {
    self = [self initWithStyle:UITableViewStyleGrouped];
    if (self) {
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        self.name = NSLocalizedString(@"Configuration", @"");
        self.subTitle = NSLocalizedString(@"Settings", @"");
        self.title = [NSString stringWithFormat:@"%@\n%@", self.name, self.subTitle];
        self.tabBarIcon = @"settings_configuration";
        self.closeable = YES;
        
        if ([MFMailComposeViewController canSendMail]) {
            UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(didPressAction:)];
            self.navigationItem.rightBarButtonItems = @[self.editButtonItem, shareButton];
        } else {
            self.navigationItem.rightBarButtonItem = self.editButtonItem;
        }
        
        self.entity = [TransientConfiguration new];
        self.definition = @[ @{ @"title" : NSLocalizedString(@"Branding", @""),
                                @"footer" : NSLocalizedString(@"Branding settings only apply after complete restart of the app", @""),
                                @"definition" : @[
                                        @{ @"title" : NSLocalizedString(@"Active", @""),
                                           @"control" : @"Switch",
                                           @"bindings" : @[ @{ @"property" : @"brandingActive" } ] },
                                        @{ @"title" : NSLocalizedString(@"Title Color", @""),
                                           @"control" : @"ColorPicker",
                                           @"selectedEditing" : @(YES),
                                           @"bindings" : @[ @{ @"property" : @"titleColor" } ],
                                           @"options" : @{
                                                   @"showTitle" : @(YES)
                                                   },
                                           @"display" : @{
                                                   @"height" : @(70) },
                                           @"edit" : @{
                                                   @"offsetX" : @(15),
                                                   @"offsetY" : @(10),
                                                   @"height" : @(225) } },
                                        @{ @"title" : NSLocalizedString(@"Highlight Color", @""),
                                           @"control" : @"ColorPicker",
                                           @"selectedEditing" : @(YES),
                                           @"bindings" : @[ @{ @"property" : @"highlightColor" } ],
                                           @"options" : @{
                                                   @"showTitle" : @(YES)
                                                   },
                                           @"display" : @{
                                                   @"height" : @(70) },
                                           @"edit" : @{
                                                   @"offsetX" : @(15),
                                                   @"offsetY" : @(10),
                                                   @"height" : @(225) } },
                                        @{ @"title" : NSLocalizedString(@"Top Background Color", @""),
                                           @"control" : @"ColorPicker",
                                           @"selectedEditing" : @(YES),
                                           @"bindings" : @[ @{ @"property" : @"topBackgroundColor" } ],
                                           @"options" : @{
                                                   @"showTitle" : @(YES)
                                                   },
                                           @"display" : @{
                                                   @"height" : @(70) },
                                           @"edit" : @{
                                                   @"offsetX" : @(15),
                                                   @"offsetY" : @(10),
                                                   @"height" : @(225) } },
                                        @{ @"title" : NSLocalizedString(@"Top Button Color", @""),
                                           @"control" : @"ColorPicker",
                                           @"selectedEditing" : @(YES),
                                           @"bindings" : @[ @{ @"property" : @"topButtonColor" } ],
                                           @"options" : @{
                                                   @"showTitle" : @(YES)
                                                   },
                                           @"display" : @{
                                                   @"height" : @(70) },
                                           @"edit" : @{
                                                   @"offsetX" : @(15),
                                                   @"offsetY" : @(10),
                                                   @"height" : @(225) } },
                                        @{ @"title" : NSLocalizedString(@"Bottom Background Color", @""),
                                           @"control" : @"ColorPicker",
                                           @"selectedEditing" : @(YES),
                                           @"bindings" : @[ @{ @"property" : @"bottomBackgroundColor" } ],
                                           @"options" : @{
                                                   @"showTitle" : @(YES)
                                                   },
                                           @"display" : @{
                                                   @"height" : @(70) },
                                           @"edit" : @{
                                                   @"offsetX" : @(15),
                                                   @"offsetY" : @(10),
                                                   @"height" : @(225) } },
                                        @{ @"title" : NSLocalizedString(@"Bottom Button Color", @""),
                                           @"control" : @"ColorPicker",
                                           @"selectedEditing" : @(YES),
                                           @"bindings" : @[ @{ @"property" : @"bottomButtonColor" } ],
                                           @"options" : @{
                                                   @"showTitle" : @(YES)
                                                   },
                                           @"display" : @{
                                                   @"height" : @(70) },
                                           @"edit" : @{
                                                   @"offsetX" : @(15),
                                                   @"offsetY" : @(10),
                                                   @"height" : @(225) } },
                                        ] },
                              @{ @"title" : NSLocalizedString(@"Security", @""),
                                 @"footer" : NSLocalizedString(@"Shorter times are more secure", @""),
                                 @"definition" : @[
                                         @{ @"title" : NSLocalizedString(@"Request Passcode", @""),
                                            @"control" : @"CodeSelection",
                                            @"label" : @(YES),
                                            @"code" : @"CodeRequestPasscode",
                                            @"bindings" : @[ @{ @"property" : @"requestPasscode" } ],
                                            @"options" : @{
                                                    @"hideClear" : @(YES) }
                                            } ]
                                 } ];

    }
    return self;
}

- (void)entityPropertyDidChange:(PropertyBinding *)propertyBinding {
    [self refresh];
}

- (void)didPressAction:(id)sender {
    [ShareUtilities showMailConfiguration:self];
}

@end