//
//  AbstractMenuBaseTableViewController.h
//  TeacherPlanner
//
//  Created by Oliver on 08.05.14.
//
//

#import <UIKit/UIKit.h>
#import "AbstractBaseTableViewController.h"
#import "InlineEditTableViewCell.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@protocol AbstractMenuBaseTableViewControllerDelegate <NSObject>
- (void)didPressSettings:(id)sender;
- (void)didPressLock:(id)sender;
- (void)didPressHelp:(id)sender;
@end

@interface AbstractMenuBaseTableViewController : AbstractBaseTableViewController<UISearchBarDelegate, AbstractMenuBaseTableViewControllerDelegate>

@property(nonatomic) BOOL showSettings;
@property(nonatomic) BOOL showLock;
@property(nonatomic) BOOL showHelp;
@property(nonatomic) BOOL showRefresh;

@property(nonatomic, strong) UISearchBar *searchBar;
@property(nonatomic, weak) id<AbstractMenuBaseTableViewControllerDelegate> menuDelegate;

- (void)newPressed:(id)sender;
- (void)addSearch;
- (void)refreshData:(id)sender;

- (InlineEditTableViewCell *)createCell:(NSString *)identifier;
- (InlineEditTableViewCell *)createCell:(NSString *)reuseIdentifier showButton:(BOOL)showButton;
- (InlineEditTableViewCell *)createCell:(NSString *)identifier style:(UITableViewCellStyle)style;
- (InlineEditTableViewCell *)createCell:(NSString *)identifier style:(UITableViewCellStyle)style content:(BOOL)content;

- (JSONEntity *)entityByUUID:(NSString *)uuid;
- (AbstractMenuBaseTableViewController *)didSelectEntity:(NSString *)uuid animated:(BOOL)animated;
- (BOOL)didSelectContentForEntity:(NSString *)uuid hideMenu:(BOOL)hideMenu;
- (void)accessoryButtonTapped:(UIControl *)button event:(UIEvent *)event;

- (void)clearState;
- (void)restoreState;
- (BOOL)restoreStateFromEntityPath:(NSString *)entityPath;
- (void)refresh;

- (void)close:(id)sender;

@end