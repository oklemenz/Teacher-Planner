//
//  SettingsAddExportViewController.m
//  TeacherPlanner
//
//  Created by Oliver Klemenz on 30.12.14.
//
//

#import "SettingsAddExportViewController.h"
#import "TransientNewExport.h"
#import "Utilities.h"
#import "Model.h"
#import "Application.h"
#import "AppDelegate.h"
#import "ShareUtilities.h"

@interface SettingsAddExportViewController ()
@property (nonatomic, strong) UIBarButtonItem *doneButton;
@end

@implementation SettingsAddExportViewController

- (instancetype)init {
    self = [self initWithStyle:UITableViewStyleGrouped];
    if (self) {
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        self.navigationItem.title = NSLocalizedString(@"New Export", @"");
        self.editing = YES;
        
        self.doneButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"")
                                                                        style:UIBarButtonItemStylePlain target:self
                                                                       action:@selector(done:)];
        self.doneButton.enabled = NO;
        self.navigationItem.rightBarButtonItem = self.doneButton;
        
        self.entity = [TransientNewExport new];
        self.definition = @[ @{ @"title" : NSLocalizedString(@"Identification", @""),
                                @"definition" : @[
                                        @{ @"title" : NSLocalizedString(@"Name", @""),
                                           @"label" : @(YES),
                                           @"control" : @"Edit",
                                           @"bindings" : @[ @{ @"property" : @"name" } ],
                                         } ] },
                             @{ @"title" : NSLocalizedString(@"Protection", @""),
                                @"definition" : @[
                                         @{ @"title" : NSLocalizedString(@"Password", @""),
                                            @"label" : @(NO),
                                            @"options" : @{
                                                    @"secureTextEntry" : @(YES),
                                            },
                                            @"control" : @"Edit",
                                            @"bindings" : @[ @{ @"property" : @"password" },
                                                             @{ @"property" : @"secureTextEntry",
                                                                @"bindableProperty" : @"secureTextEntryNumber"} ] },
                                         @{ @"title" : NSLocalizedString(@"Retype Password", @""),
                                            @"label" : @(NO),
                                            @"control" : @"Edit",
                                            @"bindings" : @[ @{ @"property" : @"retypePassword" },
                                                             @{ @"property" : @"secureTextEntry",
                                                                @"bindableProperty" : @"secureTextEntryNumber"} ] },
                                         @{ @"title" : NSLocalizedString(@"Secure Text Entry", @""),
                                            @"label" : @(NO),
                                            @"control" : @"Switch",
                                            @"bindings" : @[ @{ @"property" : @"secureTextEntry" } ] }
                                        ] }
                             ];
    }
    return self;
}

- (void)entityPropertyDidChange:(PropertyBinding *)propertyBinding {
    self.doneButton.enabled = (self.newExport.name.length > 0 && self.newExport.password.length > 0 &&
                               [self.newExport.password isEqualToString:self.newExport.retypePassword]);
}

- (void)controlPropertyDidChange:(PropertyBinding *)propertyBinding {
}

- (void)done:(id)sender {
    NSString *applicationUUID = [[AppDelegate instance] activeApplication];
    [[Model instance] exportData];
    UIAlertController *activity = [ShareUtilities showActivity:self];
    [self performSelector:@selector(export:) withObject:@[applicationUUID, activity] afterDelay:0.1];
}

- (void)export:(NSArray *)parameters {
    NSString *applicationUUID = parameters[0];
    UIAlertController *activity = parameters[1];
    [Utilities exportApplication:applicationUUID fileName:self.newExport.name
                        password:self.newExport.password];
    [[AppDelegate instance] dismiss:activity animated:YES completion:^{
        [self.navigationController popViewControllerAnimated:YES];
    }];
}
     
- (TransientNewExport *)newExport {
 return (TransientNewExport *)self.entity;
}

@end