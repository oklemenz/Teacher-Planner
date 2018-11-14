//
//  AbstractContentTableViewController.h
//  TeacherPlanner
//
//  Created by Oliver on 17.05.14.
//
//

#import <UIKit/UIKit.h>
#import "AbstractBaseTableViewController.h"
#import "AbstractContentDetailTableViewController.h"
#import "UIViewController+Extension.h"

@interface AbstractContentTableViewController : AbstractBaseTableViewController
    <AbstractContentDetailTableViewControllerDelegate>

@property(nonatomic, strong) NSArray *definition;
@property (nonatomic) NSIndexPath *selectedEditingIndexPath;

- (void)showCell:(AbstractTableViewCell *)cell indexPath:(NSIndexPath *)indexPath;
- (void)showContent:(AbstractContentTableViewController *)contentViewController;
- (void)showDetails:(AbstractContentDetailTableViewController *)detailsViewController;

@end