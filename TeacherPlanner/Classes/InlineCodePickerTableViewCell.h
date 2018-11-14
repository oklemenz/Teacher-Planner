//
//  InlineCodePickerTableViewCell.h
//  TeacherPlanner
//
//  Created by Oliver on 24.05.14.
//
//

#import <UIKit/UIKit.h>
#import "AbstractTableViewCell.h"

@interface InlineCodePickerTableViewCell : AbstractTableViewCell<UIPickerViewDelegate, UIPickerViewDataSource>

// Options
@property (nonatomic) BOOL includeEmpty;

- (NSString *)code;

@end
