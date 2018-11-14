//
//  AbstractContentDetailTableViewController.h
//  TeacherPlanner
//
//  Created by Oliver on 07.06.14.
//
//

#import <UIKit/UIKit.h>
#import "AbstractBaseTableViewController.h"
#import "PropertyBinding.h"
#import "ContextBinding.h"
#import "JSONEntity.h"
#import "InlineEditTableViewCell.h"
#import "AbstractTableViewCell.h"

@class AbstractContentDetailTableViewController;

@protocol AbstractContentDetailTableViewControllerDelegate <NSObject>
- (void)didSelectEntity:(NSString *)uuid index:(NSNumber *)index sender:(id)sender;
- (void)didClearEntity:(NSString *)uuid index:(NSNumber *)index sender:(id)sender;
@end

@interface AbstractContentDetailTableViewController : AbstractBaseTableViewController <UISearchBarDelegate>

@property(nonatomic, strong) UISearchBar *searchBar;
@property(nonatomic) BOOL showRefresh;

@property (nonatomic, strong) NSDictionary *definition;
@property (nonatomic, strong) ContextBinding *contextBinding;
@property (nonatomic, strong) NSMutableArray *contextValue;

@property (nonatomic) BOOL selectedEditing;
@property (nonatomic, strong) NSIndexPath *selectedEditingIndexPath;

@property (nonatomic) BOOL selectionMode;
@property (nonatomic) BOOL suppressSelectionClear;
@property (nonatomic, strong) NSNumber *selectionIndex;
@property (nonatomic, strong) NSString *selectionUUID;

@property(nonatomic) BOOL addable;

@property (nonatomic, weak) id<AbstractContentDetailTableViewControllerDelegate, PropertyBindingDelegate> delegate;

- (void)addSearch;

- (AbstractTableViewCell *)createCell:(NSIndexPath *)indexPath reuseIdentifier:(NSString *)reuseIdentifier style:(UITableViewCellStyle)style detail:(BOOL)detail;

- (void)updateCells;
- (void)updateCellBeforeDisplay:(AbstractTableViewCell *)cell indexPath:(NSIndexPath *)indexPath;

- (void)newPressed:(id)sender;
- (void)refreshData:(id)sender;

- (BOOL)didSelectEntity:(NSString *)uuid;

- (JSONEntity *)aggregationEntityByIndexPath:(NSIndexPath *)indexPath;

@end