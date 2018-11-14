//
//  InlineColorPreviewTableViewCell.h
//  TeacherPlanner
//
//  Created by Oliver Klemenz on 12.03.15.
//
//

#import <UIKit/UIKit.h>
#import "AbstractTableViewCell.h"

@interface InlineColorPreviewTableViewCell : AbstractTableViewCell

@property (nonatomic, strong) UIColor *color;
@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat alphaValue;

@end