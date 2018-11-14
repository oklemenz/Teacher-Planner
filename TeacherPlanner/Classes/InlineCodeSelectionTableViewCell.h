//
//  InlineCodeSelectionTableViewCell.h
//  TeacherPlanner
//
//  Created by Oliver on 01.06.14.
//
//

#import <UIKit/UIKit.h>
#import "AbstractTableViewCell.h"

@interface InlineCodeSelectionTableViewCell : AbstractTableViewCell

- (NSString *)code;
- (void)showSelection:(UINavigationController *)navigationController;

// Options
@property (nonatomic) BOOL hideClear;

@end
