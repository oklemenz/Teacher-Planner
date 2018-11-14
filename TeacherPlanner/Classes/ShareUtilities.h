//
//  ShareUtilities.h
//  TeacherPlanner
//
//  Created by Oliver on 20.06.14.
//
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

#define kActionSheetExportSchoolClassByMail 0
#define kActionSheetExportSchoolClassToITunes 1

#define kActionSheetImportSchoolClassCancel 0
#define kActionSheetImportSchoolClassNewPerson 1
#define kActionSheetImportSchoolClassOverwritePhoto 2
#define kActionSheetImportSchoolClassAddMissingPhoto 3
#define kActionSheetImportSchoolClassNoPhoto 4

@class SchoolClass;

@interface ShareUtilities : NSObject

+ (UIActivityViewController *)showPDFActivityView:(NSString *)title url:(NSURL *)url presenter:(UIViewController *)presenter;
+ (UIActivityViewController *)showExportCalendarActivityView:(NSArray *)calendarEntries presenter:(UIViewController *)presenter;

+ (UIAlertController *)showExportSchoolClassActionSheet:(SchoolClass *)schoolClass presenter:(UIViewController<MFMailComposeViewControllerDelegate> *)presenter;
+ (MFMailComposeViewController *)showExportSchoolClassByMail:(SchoolClass *)schoolClass password:(NSString *)password presenter:(UIViewController<MFMailComposeViewControllerDelegate> *)presenter;
+ (UIAlertController *)showExportSchoolClassToITunes:(SchoolClass *)schoolClass password:(NSString *)password presenter:(UIViewController *)presenter;

+ (MFMailComposeViewController *)showMailConfiguration:(UIViewController<MFMailComposeViewControllerDelegate> *)presenter;
+ (MFMailComposeViewController *)showMailExport:(NSString *)filePath presenter:(UIViewController<MFMailComposeViewControllerDelegate> *)presenter;

+ (UIAlertController *)showActivity:(UIViewController *)presenter;
+ (UIAlertController *)showPasswordProtection:(UIViewController *)presenter handler:(void (^)(NSString *password))handler;
+ (UIAlertController *)showPasswordEntry:(UIViewController *)presenter handler:(void (^)(NSString *password))handler;

+ (UIAlertController *)showSchoolClassImportOptions:(UIViewController *)presenter handler:(void (^)(NSInteger option))handler;

@end