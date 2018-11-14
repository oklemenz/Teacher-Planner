//
//  AbstractMenuTableViewController.m
//  TeacherPlanner
//
//  Created by Oliver Klemenz on 29.01.15.
//
//

#import "AbstractMenuTableViewController.h"
#import "AbstractTabBarViewController.h"
#import "AppDelegate.h"
#import "PropertyBinding.h"
#import "ContextBinding.h"
#import "Configuration.h"
#import "Common.h"

@interface AbstractMenuTableViewController ()
@property (nonatomic, strong) ContextBinding *contextBinding;
@end

@implementation AbstractMenuTableViewController

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self.definition[@"search"] boolValue]) {
        [self addSearch];
        self.searchBar.text = @"";
    }
    
    if ([self.definition[@"index"] boolValue]) {
        self.tableView.sectionIndexColor = [Configuration instance].highlightColor;
    }
}

- (void)setEntity:(JSONEntity *)entity {
    super.entity = entity;
    self.contextBinding = [self bindContext:self.entity context:self.definition[@"context"]];
    if ([self.definition[@"search"] boolValue]) {
        [self.contextEntity resetFilterAggregation:self.aggregation];
        self.searchBar.text = @"";
    }
    // TODO: Reload table data when entity or definition changed (and both are set, else empty table)...
}

- (JSONEntity *)contextEntity {
    return [self.contextBinding contextEntity];
}

- (NSString *)aggregation {
    return [self.contextBinding contextEntityBinding];
}

- (NSString *)aggregationReferenced {
    NSString *aggregation = self.aggregation;
    if ([self.definition[@"ref"] boolValue] && [aggregation hasSuffix:@"Ref"]) {
        aggregation = [aggregation substringToIndex:aggregation.length - 3];
    }
    return aggregation;
}

- (NSIndexPath *)addRow:(JSONEntity *)entity {
    NSIndexPath *indexPath;
    if ([self.definition[@"group"] boolValue]) {
        indexPath = [self.contextEntity aggregationGroupIndex:self.aggregation uuid:entity.uuid];
    } else {
        indexPath = [NSIndexPath indexPathForRow:[self.contextEntity aggregationIndex:
                                             self.aggregation uuid:entity.uuid] inSection:0];
    }
    [self.tableView beginUpdates];
    if ([self.definition[@"group"] boolValue]) {
        if ([self.contextEntity numberOfAggregation:self.aggregation group:indexPath.section] == 1 &&
            ![[self.contextEntity aggregationGroupName:self.aggregation group:indexPath.section] isEqualToString:@""]) {
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    return indexPath;
}

- (void)refreshData:(id)sender {
    [super refreshData:sender];
    [self.contextEntity updateAggregation:self.aggregation object:nil action:@"sort" trigger:self.contextBinding];
    [self.tableView reloadData];
}

- (void)newPressed:(id)sender {
    JSONEntity *entity = [self.contextEntity addAggregation:self.aggregationReferenced trigger:self.contextBinding];
    NSIndexPath *indexPath = [self addRow:entity];
    [self setEditing:YES animated:YES];
    [self didSelectContentForEntity:entity.uuid hideMenu:NO];
    InlineEditTableViewCell *cell = (InlineEditTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    cell.placeholder = self.definition[@"placeholder"];
    [cell.textField becomeFirstResponder];
}

- (void)setContext:(id)contextValue source:(id)source userInfo:(NSDictionary *)userInfo {
    [super setContext:contextValue source:source userInfo:userInfo];
    if ([self.definition[@"search"] boolValue]) {
        [self.contextEntity resetFilterAggregation:self.aggregation];
        self.searchBar.text = @"";
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([self.definition[@"group"] boolValue]) {
        return [self.contextEntity numberOfAggregationGroup:self.aggregation];
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.definition[@"group"] boolValue]) {
        return [self.contextEntity numberOfAggregation:self.aggregation group:section];
    } else {
        return [self.contextEntity numberOfAggregation:self.aggregation];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.aggregation && [self.definition[@"group"] boolValue]) {
        return [self.contextEntity aggregationGroupName:self.aggregation group:section];
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.tableView.editing && [self.definition valueForKeyPath:@"edit.height"]) {
        return [[self.definition valueForKeyPath:@"edit.height"] floatValue];
    }
    if ([self.definition valueForKeyPath:@"display.height"]) {
        return [[self.definition valueForKeyPath:@"display.height"] floatValue];
    }
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [self.definition[@"index"] boolValue] ? [self.contextEntity aggregationIndex:self.aggregation] : nil;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [[self.contextEntity aggregationIndex:self.aggregation] indexOfObject:title];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CellIdentifier";
    BOOL content = NO;
    if ([self.definition valueForKeyPath:@"content.className"]) {
        content = YES;
    }
    
    UITableViewCellStyle style = UITableViewCellStyleDefault;
    if (self.definition[@"cellStyle"]) {
        style = [self.definition[@"cellStyle"] integerValue];
    }
    
    InlineEditTableViewCell *cell = [self createCell:CellIdentifier style:style content:content];
    cell.placeholder = self.definition[@"placeholder"];
    if ([self.definition[@"photoIcon"] boolValue]) {
        cell.showPhotoIcon = YES;
    }
    JSONEntity *aggregationEntity = [self aggregationEntityByIndexPath:indexPath];
    if (self.definition[@"bindings"]) {
        for (NSDictionary *binding in self.definition[@"bindings"]) {
            [cell bind:aggregationEntity context:binding[@"context"] property:binding[@"property"] bindableProperty:binding[@"bindableProperty"]].delegate = self;
        }
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.definition[@"readOnly"] boolValue] ? NO : YES;
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *actions = [@[] mutableCopy];
    
    if ([self.definition[@"delete"] boolValue]) {
        UITableViewRowAction *deleteButton = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:NSLocalizedString(@"Delete", @"") handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
            [self tableView:tableView commitEditingStyle:UITableViewCellEditingStyleDelete forRowAtIndexPath:indexPath];
        }];
        [actions addObject:deleteButton];
    }
    
    if ([self.definition[@"copy"] boolValue]) {
        UITableViewRowAction *copyButton = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:NSLocalizedString(@"Copy", @"") handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
            JSONEntity *aggregationEntity = [self aggregationEntityByIndexPath:indexPath];
            if ([self.definition[@"ref"] boolValue]) {
                aggregationEntity = [self.contextEntity aggregation:self.aggregationReferenced uuid:aggregationEntity.uuid];
            }
            JSONEntity *entityCopy = [self.contextEntity callAggregation:self.aggregationReferenced object:aggregationEntity action:@"copy" trigger:self.contextBinding];
            NSIndexPath *copyIndexPath = [self addRow:entityCopy];
            [self setEditing:NO animated:YES];
            [self setEditing:YES animated:YES];
            InlineEditTableViewCell *cell = (InlineEditTableViewCell *)[self.tableView cellForRowAtIndexPath:copyIndexPath];
            [cell.textField becomeFirstResponder];
        }];
        [actions addObject:copyButton];
    }

    return actions;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [Common showDeletionConfirmation:self okHandler:^{
            JSONEntity *aggregationEntity = [self aggregationEntityByIndexPath:indexPath];
            NSString *groupName = [self.definition[@"group"] boolValue] ? [self.contextEntity aggregationGroupName:self.aggregation group:indexPath.section] : nil;
            [self.tableView beginUpdates];
            [self.contextEntity removeAggregation:self.aggregation uuid:aggregationEntity.uuid trigger:self.contextBinding];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            if ([self.definition[@"group"] boolValue]) {
                if ([self.contextEntity numberOfAggregation:self.aggregation groupName:groupName] == 0 &&
                    ![groupName isEqualToString:@""]) {
                    [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
                }
            }
            [self.tableView endUpdates];
            if ([self.contextEntity numberOfAggregation:self.aggregation] == 0) {
                [self setEditing:NO animated:YES];
            }
        } cancelHandler:nil];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    JSONEntity *aggregationEntity = [self aggregationEntityByIndexPath:indexPath];
    if ([self.definition[@"selectDetail"] boolValue]) {
        [self didSelectContentForEntity:aggregationEntity.uuid hideMenu:YES];
    } else {
        [self didSelectEntity:aggregationEntity.uuid animated:YES];
    }
}

- (JSONEntity *)entityByUUID:(NSString *)uuid {
    return [self.contextEntity aggregation:self.aggregationReferenced uuid:uuid];
}

- (AbstractMenuBaseTableViewController *)didSelectEntity:(NSString *)uuid animated:(BOOL)animated {
    if ([self.definition valueForKeyPath:@"detail.className"]) {
        AbstractMenuBaseTableViewController *menuTableViewController = [NSClassFromString([self.definition valueForKeyPath:@"detail.className"]) new];
        JSONEntity *aggregationEntity = [self.contextEntity aggregation:self.aggregationReferenced uuid:uuid];
        if (aggregationEntity) {
            menuTableViewController.entity = aggregationEntity;
            if ([self.definition valueForKeyPath:@"detail.bindings"]) {
                for (NSDictionary *binding in [self.definition valueForKeyPath:@"detail.bindings"]) {
                    [menuTableViewController bind:aggregationEntity context:binding[@"context"] property:binding[@"property"] bindableProperty:binding[@"bindableProperty"]].delegate = menuTableViewController;
                }
            }
            [self.navigationController pushViewController:menuTableViewController animated:animated];
            return menuTableViewController;
        }
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
    JSONEntity *aggregationEntity = [self aggregationEntityByIndexPath:indexPath];
    [self didSelectContentForEntity:aggregationEntity.uuid hideMenu:YES];
}

- (BOOL)didSelectContentForEntity:(NSString *)uuid hideMenu:(BOOL)hideMenu {
    if ([self.definition valueForKeyPath:@"content.className"]) {
        AbstractTabBarViewController *contentViewController = [NSClassFromString([self.definition valueForKeyPath:@"content.className"]) new];
        JSONEntity *aggregationEntity = [self.contextEntity aggregation:self.aggregationReferenced uuid:uuid];
        if (aggregationEntity) {
            contentViewController.entity = aggregationEntity;
            if ([self.definition valueForKeyPath:@"content.bindings"]) {
                for (NSDictionary *binding in [self.definition valueForKeyPath:@"content.bindings"]) {
                    [contentViewController bind:aggregationEntity context:binding[@"context"] property:binding[@"property"] bindableProperty:binding[@"bindableProperty"]].delegate = self;
                }
            }
            [[AppDelegate instance] showContent:contentViewController hideMenu:hideMenu];
            return YES;
        }
    }
    return NO;
}

- (JSONEntity *)aggregationEntityByIndexPath:(NSIndexPath *)indexPath {
    NSString *aggregation = self.aggregation;
    if ([self.definition[@"group"] boolValue]) {
        return [self.contextEntity aggregation:aggregation group:indexPath.section index:indexPath.row];
    } else {
        return [self.contextEntity aggregation:aggregation index:indexPath.row];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self.contextEntity filterAggregation:self.aggregation bySearchText:searchText];
    [self.tableView reloadData];
}

@end