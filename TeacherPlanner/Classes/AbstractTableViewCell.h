//
//  AbstractTableViewCell.h
//  TeacherPlanner
//
//  Created by Oliver on 25.05.14.
//
//

#import <UIKit/UIKit.h>
#import "JSONEntity.h"
#import "Bindable.h"
#import "PropertyBinding.h"

#define kCellContentOffset 16
#define kCellAccessoryOffset 24

#define PLACEHOLDER_COLOR [UIColor colorWithWhite:0.0980392 alpha:0.22]
#define DETAIL_TEXT_COLOR [UIColor colorWithRed:0.556863 green:0.556863 blue:0.576471 alpha:1]

@class AbstractTableViewCell;

@protocol AbstractTableViewCellDelegate <NSObject>

- (void)present:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(void))completion;
- (void)push:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(void))completion;

- (void)popToRootViewControllerAnimated:(BOOL)animated;
- (void)popViewControllerAnimated:(BOOL)animated;

- (void)didBeginTextEditCell:(AbstractTableViewCell *)cell;
- (void)didEndTextEditCell:(AbstractTableViewCell *)cell;

@end

@interface AbstractTableViewCell : UITableViewCell <Bindable>

@property(nonatomic) NSDictionary *definition;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic) CGFloat offsetTitle;
@property(nonatomic) NSInteger accessoryWidth;

@property (nonatomic) NSInteger row;
@property (nonatomic) NSNumber *index;
@property (nonatomic) NSString *uuid;

@property (nonatomic) NSIndexPath *indexPath;

@property(nonatomic, strong) id value;
@property(nonatomic, strong) id detailValue;
@property(nonatomic, strong) id text;
@property(nonatomic, strong) id detailText;
@property(nonatomic, strong) id icon;

@property(nonatomic, strong) NSString *placeholder;

@property(nonatomic) BOOL label;
@property(nonatomic) BOOL editTitle;
@property(nonatomic) BOOL alwaysEditing;
@property(nonatomic) BOOL selectedEditing;
@property(nonatomic) BOOL selectedEditingActive;

// Options
@property(nonatomic) BOOL showTitle;

@property(nonatomic, weak) id<AbstractTableViewCellDelegate> delegate;

- (void)updateContent:(BOOL)animated;
- (void)reset;

- (NSObject<Bindable> *)bindable;

- (void)setViews:(NSArray *)views editing:(BOOL)editing animated:(BOOL)animated duration:(CGFloat)duration;
- (void)resignFirstResponder;

@end