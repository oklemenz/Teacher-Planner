//
//  InlinePhotoPickerTableViewCell.h
//  TeacherPlanner
//
//  Created by Oliver on 14.06.14.
//
//

#import "AbstractTableViewCell.h"
#import "PhotoAnnotationViewController.h"

@interface InlinePhotoPickerTableViewCell : AbstractTableViewCell <UIImagePickerControllerDelegate, UINavigationControllerDelegate, PhotoAnnotationViewControllerDelegate>

@end