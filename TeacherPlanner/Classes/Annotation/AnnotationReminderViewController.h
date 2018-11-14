//
//  AnnotationReminderViewController.h
//  TeacherPlanner
//
//  Created by Klemenz, Oliver on 25.08.14.
//
//

#import <UIKit/UIKit.h>
#import "AbstractContentTableViewController.h"

@class Annotation;

@protocol AnnotationReminderViewControllerDelegate <NSObject>
- (void)didChangeReminder:(NSDate *)reminderDate offset:(NSDateComponents *)offset annotation:(Annotation *)annotation sender:(id)sender;
@end

@interface AnnotationReminderViewController : AbstractContentTableViewController

@property (nonatomic, weak) id<AnnotationReminderViewControllerDelegate> delegate;
@property (nonatomic, strong) Annotation *annotation;

@end