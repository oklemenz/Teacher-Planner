//
//  ShareUtilities.m
//  TeacherPlanner
//
//  Created by Oliver on 20.06.14.
//
//

#import "ShareUtilities.h"
#import "ExportCalendarActivity.h"
#import "Configuration.h"
#import "Utilities.h"
#import "NSString+Extension.h"
#import "AppDelegate.h"

#import "Model.h"
#import "Application.h"
#import "Settings.h"
#import "School.h"
#import "SchoolClass.h"
#import "Student.h"
#import "Person.h"
#import "Photo.h"
#import "Common.h"

@implementation ShareUtilities

+ (UIActivityViewController *)showPDFActivityView:(NSString *)title url:(NSURL *)url presenter:(UIViewController *)presenter {
    NSArray *items = @[title, url];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:items
                                                                                         applicationActivities:nil];
    [activityViewController setValue:title forKey:@"subject"];
    activityViewController.completionWithItemsHandler = ^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
    };
    [[AppDelegate instance] present:activityViewController presenter:presenter animated:YES completion:nil];
    return activityViewController;
}

+ (UIActivityViewController *)showExportCalendarActivityView:(NSArray *)calendarEntries presenter:(UIViewController *)presenter {
    ExportCalendarActivity *exportCalendarActivity = [ExportCalendarActivity new];
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:calendarEntries applicationActivities:@[exportCalendarActivity]];
    activityViewController.completionWithItemsHandler = ^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
    };
    [[AppDelegate instance] present:activityViewController presenter:presenter animated:YES completion:nil];
    return activityViewController;
}

+ (UIAlertController *)showExportSchoolClassActionSheet:(SchoolClass *)schoolClass presenter:(UIViewController<MFMailComposeViewControllerDelegate> *)presenter  {
    NSString *title = [NSString stringWithFormat:NSLocalizedString(@"Export School Class: %@", @""), schoolClass.name];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:NSLocalizedString(@"Choose export location", @"")
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Export by Mail", @"")
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action) {
                                                [ShareUtilities showPasswordProtection:presenter handler:^(NSString *password) {
                                                    [ShareUtilities showExportSchoolClassByMail:schoolClass password:password presenter:presenter];
                                                }];
                                            }]];

    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Export to iTunes", @"")
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action) {
                                                [ShareUtilities showPasswordProtection:presenter handler:^(NSString *password) {
                                                    [ShareUtilities showExportSchoolClassToITunes:schoolClass password:password presenter:presenter];
                                                }];
                                            }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"")
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * action) {
                                            }]];
    [[AppDelegate instance] present:alert presenter:presenter animated:YES completion:nil];
    return alert;
}

+ (MFMailComposeViewController *)showExportSchoolClassByMail:(SchoolClass *)schoolClass password:(NSString *)password presenter:(UIViewController<MFMailComposeViewControllerDelegate> *)presenter {
    
    UIAlertController *activity = [ShareUtilities showActivity:presenter];
    
    NSString *fileName = [SchoolClass exportSchoolClass:schoolClass password:password temp:YES];
    if (!fileName) {
        [Common showMessage:presenter title:NSLocalizedString(@"Export Error", @"") message:NSLocalizedString(@"An unexpected error occured during export. Try again later.", @"") okHandler:nil];
        return nil;
    }
    NSData *fileData = [Utilities read:[[Utilities generatedFolder] stringByAppendingPathComponent:fileName]];
    
    MFMailComposeViewController *mail = [MFMailComposeViewController new];
    
    NSString *title = [NSString stringWithFormat:@"%@ - %@", schoolClass.name, schoolClass.parent.name];
    NSString *text = [NSString stringWithFormat:NSLocalizedString(@"", @"")];
    [mail setSubject:title];
    
    NSString *mimeType = [@"application/" stringByAppendingString:kClassExtension];
    [mail addAttachmentData:fileData mimeType:mimeType fileName:fileName];
    
    [mail setToRecipients:@[]];
    [mail setMessageBody:text isHTML:NO];
    
    mail.mailComposeDelegate = presenter;
    
    [[AppDelegate instance] dismiss:activity animated:YES completion:^{
        [[AppDelegate instance] present:mail presenter:presenter animated:YES completion:nil];
    }];

    return mail;
}

+ (UIAlertController *)showExportSchoolClassToITunes:(SchoolClass *)schoolClass password:(NSString *)password  presenter:(UIViewController *)presenter {

    UIAlertController *activity = [ShareUtilities showActivity:presenter];
    
    NSString *fileName = [SchoolClass exportSchoolClass:schoolClass password:password temp:NO];
    if (!fileName) {
        [Common showMessage:presenter title:NSLocalizedString(@"Export Error", @"") message:NSLocalizedString(@"An unexpected error occured during export. Try again later.", @"") okHandler:nil];
        return nil;
    }
    
    NSString *title = [NSString stringWithFormat:NSLocalizedString(@"School Class: %@", @""), schoolClass.name];
    
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"School Class exported to file %@ in Documents folder, accessible via iTunes file sharing.", @""), fileName];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"")
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action) {
                                            }]];
    
    [[AppDelegate instance] dismiss:activity animated:YES completion:^{
        [[AppDelegate instance] present:alert presenter:presenter animated:YES completion:nil];
    }];
    return alert;
}

+ (UIAlertController *)showPasswordProtection:(UIViewController *)presenter handler:(void (^)(NSString *password))handler {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Provide Password Protection", @"") message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    __weak UIAlertController *weakAlert = alert;
    void (^handleNotification)(NSNotification *note) = ^(NSNotification *note) {
        UITextField *password = weakAlert.textFields.firstObject;
        UITextField *retypePassword = weakAlert.textFields.lastObject;
        UIAlertAction *okAction = weakAlert.actions.firstObject;
        okAction.enabled = [password.text isEqual:retypePassword.text] && password.text.length > 0;
    };
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = NSLocalizedString(@"Password", @"");
        textField.secureTextEntry = YES;
        [[NSNotificationCenter defaultCenter] addObserverForName:UITextFieldTextDidChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:handleNotification];
    }];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = NSLocalizedString(@"Retype Password", @"");
        textField.secureTextEntry = YES;
        [[NSNotificationCenter defaultCenter] addObserverForName:UITextFieldTextDidChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:handleNotification];
    }];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"")
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * action) {
                                                   [[NSNotificationCenter defaultCenter]
                                                    removeObserver:self name:UITextFieldTextDidChangeNotification
                                                    object:nil];
                                                   UITextField *password = alert.textFields.firstObject;
                                                   handler(password.text);
                                               }];
    ok.enabled = NO;
    [alert addAction:ok];

    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Skip", @"")
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action) {
                                                [[NSNotificationCenter defaultCenter]
                                                 removeObserver:self name:UITextFieldTextDidChangeNotification
                                                 object:nil];
                                                handler(nil);
                                            }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"")
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * action) {
                                                [[NSNotificationCenter defaultCenter]
                                                 removeObserver:self name:UITextFieldTextDidChangeNotification
                                                 object:nil];
                                            }]];
    [[AppDelegate instance] present:alert presenter:presenter animated:YES completion:nil];
    return alert;
}

+ (MFMailComposeViewController *)showMailConfiguration:(UIViewController<MFMailComposeViewControllerDelegate> *)presenter {
    School *school = [Model instance].application.settings.school;
    NSDictionary *config = @{ kConfigKeyBrandingPrefix : [Configuration instance].configuration,
                              kConfigKeySchoolPrefix   : school.toDictionary };
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:config options:NSJSONWritingPrettyPrinted error:nil];
    NSString *fileName = [@"config" stringByAppendingPathExtension:kBrandingExtension];
    
    MFMailComposeViewController *mail = [MFMailComposeViewController new];
    mail.mailComposeDelegate = presenter;
    
    NSString *title = NSLocalizedString(@"Teacher Planner Branding", @"");
    NSString *schoolName = school.name ? [NSString stringWithFormat:@"\"%@\"", school.name] : @"";
    NSString *text = [NSString stringWithFormat:NSLocalizedString(@"Your school%@ asks you to brand your application.\n\nTap the attached file \"config.tpb\" and open it with the application \"Teacher Planner\" to apply the school branding.\n\nThe following configuration is applied: \n- School color theme\n- School name, country and state\n- School weekdays\n- School times", @""), schoolName];
    [mail setSubject:title];
    
    NSString *mimeType = [@"application/" stringByAppendingString:kBrandingExtension];
    [mail addAttachmentData:jsonData mimeType:mimeType fileName:fileName];
    
    [mail setToRecipients:@[]];
    [mail setMessageBody:text isHTML:NO];
    [[AppDelegate instance] present:mail presenter:presenter animated:YES completion:nil];
    
    return mail;
}

+ (MFMailComposeViewController *)showMailExport:(NSString *)filePath presenter:(UIViewController<MFMailComposeViewControllerDelegate> *)presenter {
    
    MFMailComposeViewController *mail = [MFMailComposeViewController new];
    mail.mailComposeDelegate = presenter;
    
    NSString *fileName = [[filePath lastPathComponent] stringByDeletingPathExtension];
    NSString *title = [NSString stringWithFormat:NSLocalizedString(@"Teacher Planner Export: %@", @""), fileName];
    [mail setSubject:title];
    
    NSString *mimeType = [@"application/" stringByAppendingString:kApplicationExtension];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    [mail addAttachmentData:data mimeType:mimeType fileName:fileName];
    
    Teacher *teacher = [Model instance].application.settings.teacher;
    if (teacher.email) {
        [mail setToRecipients:@[teacher.email]];
    }

    NSString *text = NSLocalizedString(@"To import the Teacher Planner export file just tap it. Teacher Planner will open and import after confirmation of the popup.\nThe imported profile can be made active by selecting it in the profile screen accessible via the info icon of the lock screen.", @"");
    [mail setMessageBody:text isHTML:NO];
    [[AppDelegate instance] present:mail presenter:presenter animated:YES completion:nil];
    
    return mail;
}

+ (UIAlertController *)showActivity:(UIViewController *)presenter {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Teacher Planner", @"") message:NSLocalizedString(@"Processing...\n\n", @"") preferredStyle:UIAlertControllerStyleAlert];

    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityView.color = [UIColor blackColor];
    [activityView startAnimating];

    [[AppDelegate instance] present:alert presenter:presenter animated:NO completion:^{
        CGRect frame = alert.view.bounds;
        frame.origin.y += 25.0f;
        activityView.frame = frame;
        activityView.alpha = 0.0;
        [alert.view addSubview:activityView];
        [UIView animateWithDuration:0.5 animations:^{
            activityView.alpha = 1.0;
        }];
    }];
    return alert;
}

+ (UIAlertController *)showPasswordEntry:(UIViewController *)presenter handler:(void (^)(NSString *password))handler {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Enter password", @"") message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    __weak UIAlertController *weakAlert = alert;
    void (^handleNotification)(NSNotification *note) = ^(NSNotification *note) {
        UITextField *password = weakAlert.textFields.firstObject;
        UIAlertAction *okAction = weakAlert.actions.firstObject;
        okAction.enabled = password.text.length > 0;
    };
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = NSLocalizedString(@"Password", @"");
        textField.secureTextEntry = YES;
        [[NSNotificationCenter defaultCenter] addObserverForName:UITextFieldTextDidChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:handleNotification];
    }];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"")
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * action) {
                                                   [[NSNotificationCenter defaultCenter]
                                                    removeObserver:self name:UITextFieldTextDidChangeNotification
                                                    object:nil];
                                                   UITextField *password = alert.textFields.firstObject;
                                                   handler(password.text);
                                               }];
    ok.enabled = NO;
    [alert addAction:ok];
    
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"")
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * action) {
                                                [[NSNotificationCenter defaultCenter]
                                                 removeObserver:self name:UITextFieldTextDidChangeNotification
                                                 object:nil];
                                            }]];
    [[AppDelegate instance] present:alert presenter:presenter animated:YES completion:nil];
    return alert;
}

+ (UIAlertController *)showSchoolClassImportOptions:(UIViewController *)presenter handler:(void (^)(NSInteger option))handler {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"School Class Import", @"")
                                                                   message:NSLocalizedString(@"Choose import option:", @"")
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Create new persons", @"")
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action) {
                                                handler(kActionSheetImportSchoolClassNewPerson);
                                            }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Overwrite existing photos", @"")
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action) {
                                                handler(kActionSheetImportSchoolClassOverwritePhoto);
                                            }]];

    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Add missing photos only", @"")
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action) {
                                                handler(kActionSheetImportSchoolClassAddMissingPhoto);
                                            }]];

    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Don't import photos", @"")
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action) {
                                                handler(kActionSheetImportSchoolClassNoPhoto);
                                            }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"")
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * action) {
                                                handler(kActionSheetImportSchoolClassCancel);
                                            }]];
    [[AppDelegate instance] present:alert presenter:presenter animated:YES completion:nil];
    return alert;
}

@end