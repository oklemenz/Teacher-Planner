//
//  ImageAnnotationSettingsViewController.h
//  TeacherPlanner
//
//  Created by Klemenz, Oliver on 31.07.14.
//
//

#import <UIKit/UIKit.h>
#import "PencilStyle.h"
#import "AbstractContentTableViewController.h"

@protocol ImageAnnotationSettingsViewControllerDelegate <NSObject>
- (void)didChangeSettings:(PencilStyle *)pencilStyle sender:(id)sender;
@end

@interface ImageAnnotationSettingsViewController : AbstractContentTableViewController

@property(nonatomic, weak) id<ImageAnnotationSettingsViewControllerDelegate> delegate;

- (instancetype)initWithPencilStyle:(PencilStyle *)pencilStyle;

@end