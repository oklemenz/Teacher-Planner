//
//  AbstractMenuBaseTableViewController.m
//  TeacherPlanner
//
//  Created by Oliver on 08.05.14.
//
//

#import "AbstractMenuBaseTableViewController.h"
#import "Configuration.h"
#import "Model.h"
#import "PropertyBinding.h"
#import "JSONEntity.h"
#import "Application.h"
#import "UIButton+Extension.h"
#import "UIBarButtonItem+Extension.h"
#import "Utilities.h"
#import "UILabel+Extension.h"
#import "AppDelegate.h"
#import "AbstractTabBarViewController.h"

@interface AbstractMenuBaseTableViewController ()
@end

@implementation AbstractMenuBaseTableViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.showSettings = YES;
        self.showLock = YES;
        self.showHelp = YES;
        self.showRefresh = YES;
        self.menuDelegate = self;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(modelDidChange:) name:ModelDidChangeNotification object:nil];
    }
    return self;
}

- (NSString *)title {
    if (self.entity.name) {
        return self.entity.name;
    }
    return super.title;
}

- (void)setName:(NSString *)name {
    self.title = name;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = YES;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(newPressed:)];
	self.navigationItem.rightBarButtonItems = @[self.editButtonItem, addButton];
    
    if (self.showRefresh) {
        UIRefreshControl *refresh = [UIRefreshControl new];
        refresh.tintColor = [Configuration instance].highlightColor;
        refresh.attributedTitle = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Pull to Refresh", @"")];
        [refresh addTarget:self action:@selector(refreshData:) forControlEvents:UIControlEventValueChanged];
        self.refreshControl = refresh;
    }
    
    self.tableView.sectionIndexColor = [Configuration instance].highlightColor;
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationController.toolbarHidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        [[Model instance].application popMenuSelection];
    }
    [super viewWillDisappear:animated];
}

- (InlineEditTableViewCell *)createCell:(NSString *)reuseIdentifier {
    return [self createCell:reuseIdentifier style:UITableViewCellStyleDefault];
}

- (InlineEditTableViewCell *)createCell:(NSString *)reuseIdentifier showButton:(BOOL)showButton {
    return [self createCell:reuseIdentifier style:UITableViewCellStyleDefault];
}

- (InlineEditTableViewCell *)createCell:(NSString *)reuseIdentifier style:(UITableViewCellStyle)style {
    return [self createCell:reuseIdentifier style:style content:YES];
}

- (InlineEditTableViewCell *)createCell:(NSString *)reuseIdentifier style:(UITableViewCellStyle)style content:(BOOL)content {
    InlineEditTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [[InlineEditTableViewCell alloc] initWithStyle:style reuseIdentifier:reuseIdentifier];
        if (content) {
            UIButton *button = [UIButton createCustomButton:@"show_detail"];
            [button addTarget:self action:@selector(accessoryButtonTapped:event:) forControlEvents:UIControlEventTouchUpInside];
            cell.accessoryView = button;
        }
    }
    [cell unbindAll];
    [cell reset];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath {
    AbstractTableViewCell *tableViewCell = (AbstractTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    [[Model instance].application pushMenuSelection:tableViewCell.entity.uuid];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    [[Model instance].application.contentSelection removeAllObjects];
    BOOL first = YES;
    for (AbstractMenuBaseTableViewController *menuController in self.navigationController.childViewControllers) {
        if (first) {
            first = NO;
            continue;
        }
        if (menuController.entity) {
            [[Model instance].application.contentSelection addObject:menuController.entity.uuid];
        }
    }
    AbstractTableViewCell *tableViewCell = (AbstractTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    [[Model instance].application.contentSelection addObject:tableViewCell.entity.uuid];
}

- (JSONEntity *)entityByUUID:(NSString *)uuid {
    return nil;
}

- (AbstractMenuBaseTableViewController *)didSelectEntity:(NSString *)uuid animated:(BOOL)animated {
    return nil;
}

- (BOOL)didSelectContentForEntity:(NSString *)uuid hideMenu:(BOOL)hideMenu {
    return NO;
}

- (void)clearState {
    [self.navigationController popToRootViewControllerAnimated:NO];
    [self.tableView reloadData];
}

- (void)restoreState {
    AbstractMenuBaseTableViewController *menuController = self;
    [menuController view];
    if ([Model instance].application.contentSelection.count > 0) {
        for (NSInteger i = 0; i < [Model instance].application.contentSelection.count; i++) {
            NSString *uuid = [Model instance].application.contentSelection[i];
            if (i < [Model instance].application.contentSelection.count - 1) {
                menuController = [menuController didSelectEntity:uuid animated:NO];
                [menuController view];
            } else {
                [menuController didSelectContentForEntity:uuid hideMenu:YES];
            }
        }
        [self.navigationController popToRootViewControllerAnimated:NO];
        menuController = self;
    }
    for (NSString *uuid in [Model instance].application.menuSelection) {
        menuController = [menuController didSelectEntity:uuid animated:NO];
        [menuController view];
    }
}

- (BOOL)restoreStateFromEntityPath:(NSString *)entityPath {
    [self clearState];
    NSArray *entityPathParts = [Utilities deserializeJSONToObject:entityPath];
    if (entityPathParts) {
        NSString *selectedEntityUUID = nil;
        NSString *selectedEntityClass = nil;
        AbstractMenuBaseTableViewController *selectedMenuController = nil;
        NSString *entityUUID = nil;
        NSString *entityClass = nil;
        AbstractMenuBaseTableViewController *menuController = self;
        for (NSDictionary *entityPathPart in entityPathParts) {
            entityUUID = entityPathPart[@"uuid"];
            entityClass = entityPathPart[@"entity"];
            [menuController view];
            JSONEntity *entity = [menuController entityByUUID:entityUUID];
            if (entity) {
                selectedEntityUUID = entityUUID;
                selectedEntityClass = entityClass;
                selectedMenuController = menuController;
            }
            AbstractMenuBaseTableViewController *nextMenuController = [menuController didSelectEntity:entityUUID animated:NO];
            if (nextMenuController) {
                menuController = nextMenuController;
            } else {
                if (!entity) {
                    [menuController.navigationController popViewControllerAnimated:NO];
                }
                break;
            }
        }
        if (selectedEntityUUID && selectedEntityClass && selectedMenuController) {
            if ([selectedMenuController didSelectContentForEntity:selectedEntityUUID hideMenu:YES]) {
                if ([(AbstractTabBarViewController *)[AppDelegate instance].contentViewController entity]) {
                    JSONEntity *entity = [(AbstractTabBarViewController *)[AppDelegate instance].contentViewController entity];
                    if ([NSStringFromClass(entity.class) isEqual:selectedEntityClass]) {
                        return YES;
                    }
                }
            }
        }
    }
    return NO;
}

- (void)refresh {
    for (AbstractTableViewCell *cell in self.tableView.visibleCells) {
        [cell refresh];
    }
}

- (NSArray *)toolbarItems {
    NSMutableArray *items = [@[] mutableCopy];
    if (self.showSettings) {
        UIBarButtonItem *settingsButton = [UIBarButtonItem createCustomTintedBottomBarButtonItem:@"settings"];
        [(UIButton *)settingsButton.customView addTarget:self.menuDelegate action:@selector(didPressSettings:)
                                                                forControlEvents:UIControlEventTouchUpInside];
        [items addObject:settingsButton];
    }
    if (self.showLock) {
        if (items.count > 0) {
        UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
            [items addObject:flexibleSpace];
        }
        UIBarButtonItem *lockButton = [UIBarButtonItem createCustomTintedBottomBarButtonItem:@"lock"];
        [(UIButton *)lockButton.customView addTarget:self.menuDelegate action:@selector(didPressLock:)
                                    forControlEvents:UIControlEventTouchUpInside];
        [items addObject:lockButton];
    }
    if (self.showHelp) {
        if (items.count > 0) {
            UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
            [items addObject:flexibleSpace];
        }
        UIBarButtonItem *infoButton = [UIBarButtonItem createCustomTintedBottomBarButtonItem:@"info"];
        [(UIButton *)infoButton.customView addTarget:self.menuDelegate action:@selector(didPressHelp:)
                                    forControlEvents:UIControlEventTouchUpInside];
        [items addObject:infoButton];
    }
    return items;
}

- (void)addSearch {
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    self.searchBar.tintColor = [Configuration instance].highlightColor;
    self.searchBar.delegate = self;
    [self.tableView setTableHeaderView:self.searchBar];
}

- (void)newPressed:(id)sender {
}

- (void)refreshData:(id)sender {
    if (self.refreshControl) {
        [self.refreshControl endRefreshing];
    }
}

- (void)setContext:(id)contextValue source:(id)source userInfo:(NSDictionary *)userInfo {
    if (!source || source != self) {
        [self.tableView reloadData];
    }
}

- (void)modelDidChange:(id)sender {
    [self.tableView reloadData];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)accessoryButtonTapped:(UIControl *)button event:(UIEvent *)event {
    NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint: [[[event touchesForView: button] anyObject] locationInView: self.tableView]];
    if (!indexPath) {
        return;
    }
    [self.tableView.delegate tableView: self.tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
}

- (void)didPressSettings:(id)sender {
    [[AppDelegate instance] showSettings:YES completion:nil];
}

- (void)didPressLock:(id)sender {
    [[AppDelegate instance] lockApplication];
}

- (void)didPressHelp:(id)sender {
    [[AppDelegate instance] showHelp];
}

- (void)close:(id)sender {
    [[AppDelegate instance] dismiss:self animated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [Utilities clearGeneratedFolder];
    [[AppDelegate instance] dismiss:controller animated:YES completion:nil];
}

@end