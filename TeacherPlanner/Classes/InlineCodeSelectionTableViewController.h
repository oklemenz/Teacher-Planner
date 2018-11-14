//
//  InlineCodeSelectionTableViewController.h
//  TeacherPlanner
//
//  Created by Oliver on 01.06.14.
//
//

#import <UIKit/UIKit.h>
#import "PropertyBinding.h"


@interface InlineCodeSelectionTableViewController : UITableViewController

@property (nonatomic, strong, readonly) PropertyBinding *propertyBinding;
@property (nonatomic, strong, readonly) NSString *code;

// Options
@property (nonatomic) BOOL selectionMode;
@property (nonatomic) BOOL hideClear;

- (instancetype)initWithCode:(NSString *)code propertyBinding:(PropertyBinding *)propertyBinding;

@end
