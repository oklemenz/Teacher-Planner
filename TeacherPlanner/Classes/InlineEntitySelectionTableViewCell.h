//
//  InlineEntitySelectionTableViewCell.h
//  TeacherPlanner
//
//  Created by Oliver Klemenz on 18.12.14.
//
//

#import <UIKit/UIKit.h>
#import "AbstractTableViewCell.h"

@interface InlineEntitySelectionTableViewCell : AbstractTableViewCell

@property (nonatomic, strong) NSArray *entity;

// Options
@property (nonatomic, strong) NSString *descriptionPath;
@property (nonatomic) BOOL showIndex;

@end
