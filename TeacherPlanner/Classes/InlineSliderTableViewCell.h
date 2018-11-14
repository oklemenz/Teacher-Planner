//
//  InlineSliderTableViewCell.h
//  TeacherPlanner
//
//  Created by Oliver Klemenz on 12.03.15.
//
//

#import <UIKit/UIKit.h>
#import "AbstractTableViewCell.h"

@interface InlineSliderTableViewCell : AbstractTableViewCell

@property (nonatomic) CGFloat minimumValue;
@property (nonatomic) CGFloat maximumValue;

// Options
@property (nonatomic) BOOL continuous;

@end