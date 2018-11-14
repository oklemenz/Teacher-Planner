//
//  TeacherPlannerController.h
//  TeacherPlanner
//
//  Created by Klemenz, Oliver on 25.07.14.
//
//

#import <UIKit/UIKit.h>
#import "AnnotationHandler.h"
#import "AnnotationReminderViewController.h"

@interface AnnotationViewController : UITableViewController<AnnotationHandlerDelegate, AnnotationReminderViewControllerDelegate>

@property (nonatomic, strong) JSONEntity<AnnotationDataSource> *dataSource;
@property (nonatomic, strong) JSONEntity<ImageAnnotationDataSource> *imageDataSource;
@property (nonatomic) BOOL showNewDialog;

- (void)showNewAnnotation;
- (void)showAnnotation:(NSString *)uuid;

@end
