//
//  InlineTimeFromToTableViewCell.h
//  TeacherPlanner
//
//  Created by Oliver on 24.05.14.
//
//

#import <UIKit/UIKit.h>
#import "AbstractTableViewCell.h"

@interface InlineTimeFromToTableViewCell : AbstractTableViewCell

@property (nonatomic, strong) NSDate *valueStart;
@property (nonatomic, strong) NSDate *valueEnd;

@end