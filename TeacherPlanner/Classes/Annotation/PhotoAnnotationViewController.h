//
//  PhotoAnnotationViewController.h
//  TeacherPlanner
//
//  Created by Klemenz, Oliver on 29.07.14.
//
//

#import <UIKit/UIKit.h>
#import "ImageAnnotationViewController.h"

@protocol PhotoAnnotationViewControllerDelegate <NSObject>
- (void)didFinishEditImage:(UIImage *)image;
@end

@interface PhotoAnnotationViewController : UIViewController <UIScrollViewDelegate, ImageAnnotationViewControllerDelegate>

@property (nonatomic, weak) id<PhotoAnnotationViewControllerDelegate> delegate;
@property (nonatomic, weak) id<ImageAnnotationDataSource> dataSource;

- (instancetype)initWithImage:(UIImage *)image;

@end