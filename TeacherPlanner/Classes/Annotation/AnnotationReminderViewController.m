//
//  AnnotationReminderViewController.m
//  TeacherPlanner
//
//  Created by Klemenz, Oliver on 25.08.14.
//
//

#import "AnnotationReminderViewController.h"
#import "AppDelegate.h"
#import "Annotation.h"
#import "Common.h"
#import "TransientReminder.h"

@interface AnnotationReminderViewController ()
@end

@implementation AnnotationReminderViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"Reminder Settings", @"");
        self.editing = YES;
        
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"") style:UIBarButtonItemStyleDone target:self action:@selector(didSetReminder:)];
        UIBarButtonItem *clearButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Clear", @"") style:UIBarButtonItemStyleDone target:self action:@selector(didClearReminder:)];
        self.navigationItem.rightBarButtonItems = @[doneButton, clearButton];
        
        self.entity = [TransientReminder new];
        
        self.definition = @[ @{ @"title" : NSLocalizedString(@"Reminder Scheduling", @""),
                                @"definition" : @[
                                        @{ @"title" : NSLocalizedString(@"Status", @""),
                                           @"control" : @"Display",
                                           @"bindings" : @[ @{ @"property" : @"status" } ]
                                           },
                                        @{ @"title" : NSLocalizedString(@"Date & Time", @""),
                                           @"control" : @"DatePicker",
                                           @"options" : @{
                                                   @"mode" : @(UIDatePickerModeDateAndTime),
                                                   },
                                           @"bindings" : @[ @{ @"property" : @"date" } ],
                                           @"edit" : @{
                                                   @"height" : @(150),
                                                   @"offsetX" : @(10),
                                                   @"offsetY" : @(0) } },
                                        @{ @"title" : NSLocalizedString(@"Lesson", @""),
                                           @"control" : @"CodePicker",
                                           @"code" : @"CodeReminderLesson",
                                           @"options" : @{
                                                   @"includeEmpty" : @(YES)
                                                   },
                                           @"bindings" : @[ @{ @"property" : @"lesson" } ],
                                           @"edit" : @{
                                                   @"height" : @(150),
                                                   @"offsetX" : @(10),
                                                   @"offsetY" : @(0) } },
                                        @{ @"title" : NSLocalizedString(@"Remind before", @""),
                                           @"control" : @"CodePicker",
                                           @"code" : @"CodeReminderTimeOffset",
                                           @"bindings" : @[ @{ @"property" : @"offset" } ],
                                           @"edit" : @{
                                                   @"height" : @(150),
                                                   @"offsetX" : @(10),
                                                   @"offsetY" : @(0) } }
                                        ] } ];
        
        [[AppDelegate instance] requestUserNotification];
    }
    return self;
}

- (TransientReminder *)reminder {
    return (TransientReminder *)self.entity;
}

- (void)setAnnotation:(Annotation *)annotation {
    _annotation = annotation;
    self.reminder.annotation = annotation;
}

- (void)didSetReminder:(id)sender {
    [self.annotation scheduleReminder:self.reminder.date offset:self.reminder.offsetDateComponents];
    [self.delegate didChangeReminder:self.annotation.reminderDate offset:self.annotation.reminderOffset annotation:self.annotation sender:self];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didClearReminder:(id)sender {
    [self.annotation unscheduleReminder];
    [self.delegate didChangeReminder:nil offset:nil annotation:self.annotation sender:self];
    [self.navigationController popViewControllerAnimated:YES];
}

@end