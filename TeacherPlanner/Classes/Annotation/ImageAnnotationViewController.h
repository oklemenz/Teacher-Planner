//
//  ImageAnnotationViewController.h
//  TeacherPlanner
//
//  Created by Klemenz, Oliver on 31.07.14.
//
//

#import <UIKit/UIKit.h>
#import "ImageAnnotationSettingsViewController.h"
#import "PencilStyleView.h"

#define kImageAnnotationDefaultColor [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f]
#define kImageAnnotationMaxUndo 50
#define kImageAnnotationMaxHistoryPencilStyle 50

#define kImageAnnotationDefaultPencilStyle [[PencilStyle alloc] initWithColor:kImageAnnotationDefaultColor width:3.0 alpha:1.0]

@protocol ImageAnnotationDataSource
- (NSArray *)pencilStyles;
- (void)addPencilStyle:(PencilStyle *)pencilStyle;
@end

@protocol ImageAnnotationViewControllerDelegate <NSObject>
- (void)didFinishDrawingImage:(UIImage *)image updated:(BOOL)updated;
@end

@interface ImageAnnotationViewController : UIViewController <ImageAnnotationSettingsViewControllerDelegate, PencilStyleViewDelegate>

@property (nonatomic, weak) id<ImageAnnotationViewControllerDelegate> delegate;
@property (nonatomic, weak) id<ImageAnnotationDataSource> dataSource;

- (void)image:(UIImage *)image;

@end