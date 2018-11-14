//
//  AbstractContentDetailTableViewController.m
//  TeacherPlanner
//
//  Created by Oliver on 07.06.14.
//
//

#import "AbstractContentDetailTableViewController.h"
#import "AbstractTableViewCell.h"
#import "InlineEditTableViewCell.h"
#import "Configuration.h"
#import "UIButton+Extension.h"
#import "NSString+Extension.h"

@interface AbstractContentDetailTableViewController ()
@property (nonatomic, strong) UIBarButtonItem *addButton;
@property (nonatomic, strong) UIBarButtonItem *clearButton;
@end

@implementation AbstractContentDetailTableViewController

- (instancetype)init {
    self = [self initWithStyle:UITableViewStylePlain];
    if (self) {
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        self.showRefresh = YES;
        self.selectedEditingIndexPath = nil;
    }
    return self;
}

- (void)setDefinition:(NSDictionary *)definition {
    if (!_definition) {
        _definition = definition;
    } else {
        if (definition) {
            _definition = [_definition mutableCopy];
            [(NSMutableDictionary *)_definition addEntriesFromDictionary:definition];
        } else {
            _definition = nil;
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = YES;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    self.tableView.allowsSelectionDuringEditing = YES;
    
    if (self.showRefresh) {
        UIRefreshControl *refresh = [UIRefreshControl new];
        refresh.tintColor = [Configuration instance].highlightColor;
        refresh.attributedTitle = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Pull to Refresh", @"")];
        [refresh addTarget:self action:@selector(refreshData:) forControlEvents:UIControlEventValueChanged];
        self.refreshControl = refresh;
    }
    
    if (self.editing) {
        self.navigationItem.rightBarButtonItem = self.addButton;
    }
    
    if (self.selectionMode && !self.suppressSelectionClear) {
        self.navigationItem.rightBarButtonItem = self.clearButton;
    }
    
    if ([self.definition[@"search"] boolValue]) {
        [self addSearch];
        self.searchBar.text = @"";
    }
    
    if ([self.definition[@"index"] boolValue]) {
        self.tableView.sectionIndexColor = [Configuration instance].highlightColor;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
}

- (UIBarButtonItem *)addButton {
    if (!_addButton) {
        _addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(newPressed:)];
    }
    return _addButton;
}

- (UIBarButtonItem *)clearButton {
    if (!_clearButton) {
        _clearButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Clear", @"") style:UIBarButtonItemStyleDone target:self action:@selector(didPressClear:)];
    }
    return _clearButton;
}

- (void)setEntity:(JSONEntity *)entity {
    super.entity = entity;
    self.contextBinding = [self bindContext:self.entity context:self.definition[@"context"]];
    if ([self.definition[@"search"] boolValue]) {
        [self.contextEntity resetFilterAggregation:self.aggregation];
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
        indexPath = [self.contextEntity aggregationGroupIndex:self.aggregation uuid:
                     [self entityUUID:entity]];
    } else {
        indexPath = [NSIndexPath indexPathForRow:[self.contextEntity aggregationIndex:
                                                  self.aggregation uuid:[self entityUUID:entity]] inSection:0];
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

- (void)addSearch {
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    self.searchBar.tintColor = [Configuration instance].highlightColor;
    self.searchBar.delegate = self;
    [self.tableView setTableHeaderView:self.searchBar];
}

- (void)newPressed:(id)sender {
    JSONEntity *entity = [self.contextEntity addAggregation:self.aggregationReferenced trigger:self.contextBinding];
    [self updateCells];
    NSIndexPath *indexPath = [self addRow:entity];
    if (self.editable) {
        [self setEditing:YES animated:YES];
    }
    AbstractTableViewCell *cell = (AbstractTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    cell.placeholder = self.definition[@"placeholder"];
    if ([cell isKindOfClass:InlineEditTableViewCell.class]) {
        InlineEditTableViewCell *inlineEditCell = (InlineEditTableViewCell *)cell;
        [inlineEditCell.textField becomeFirstResponder];
    } else if (self.definition[@"detail"]) {
        [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
        [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
    }
}

- (void)refreshData:(id)sender {
    if (self.refreshControl) {
        [self.refreshControl endRefreshing];
    }
    [self.contextEntity updateAggregation:self.aggregation object:nil action:@"sort" trigger:self.contextBinding];
    self.selectedEditingIndexPath = nil;
    [self.tableView reloadData];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    if (!self.selectionMode) {
        if (self.editable && self.addable) {
            [self.navigationItem setRightBarButtonItems:@[self.editButtonItem, self.addButton] animated:animated];
        } else if (self.editing) {
            [self.navigationItem setRightBarButtonItems:@[self.addButton] animated:animated];
        } else if (self.addable) {
            [self.navigationItem setRightBarButtonItems:@[] animated:animated];
        }
    }
    if (animated) {
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    }
}

- (void)setAddable:(BOOL)addable {
    _addable = addable;
    if (addable) {
        if (self.editable && self.addable) {
            [self.navigationItem setRightBarButtonItems:@[self.editButtonItem, self.addButton] animated:NO];
        } else if (self.editing) {
            [self.navigationItem setRightBarButtonItems:@[self.addButton] animated:NO];
        } else if (self.addable) {
            [self.navigationItem setRightBarButtonItems:@[] animated:NO];
        }
    }
}

- (void)setSelectionMode:(BOOL)selectionMode {
    _selectionMode = selectionMode;
    if (selectionMode && !self.suppressSelectionClear) {
        [self.navigationItem setRightBarButtonItem:self.clearButton animated:YES];
    } else {
        [self.navigationItem setRightBarButtonItem:nil animated:YES];
    }
}

- (void)setSuppressSelectionClear:(BOOL)suppressSelectionClear {
    _suppressSelectionClear = suppressSelectionClear;
    if (self.selectionMode && !self.suppressSelectionClear) {
        [self.navigationItem setRightBarButtonItem:self.clearButton animated:YES];
    } else {
        [self.navigationItem setRightBarButtonItem:nil animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.selectedEditing) {
        BOOL selectedEditing = self.tableView.editing &&
                               [indexPath isEqual:self.selectedEditingIndexPath];
        if (selectedEditing) {
            if ([self.definition valueForKeyPath:@"select.height"]) {
                return [[self.definition valueForKeyPath:@"select.height"] floatValue];
            }
            if ([self.definition valueForKeyPath:@"edit.height"]) {
                return [[self.definition valueForKeyPath:@"edit.height"] floatValue];
            }
        }
        if ([self.definition valueForKeyPath:@"display.height"]) {
            return [[self.definition valueForKeyPath:@"display.height"] floatValue];
        }
    } else {
        if (self.tableView.editing && [self.definition valueForKeyPath:@"edit.height"]) {
            return [[self.definition valueForKeyPath:@"edit.height"] floatValue];
        }
        if ([self.definition valueForKeyPath:@"display.height"]) {
            return [[self.definition valueForKeyPath:@"display.height"] floatValue];
        }
    }
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
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
    if ([self.definition[@"group"] boolValue]) {
        return [self.contextEntity aggregationGroupName:self.aggregation group:section];
    }
    return nil;
}

- (AbstractTableViewCell *)createCell:(NSIndexPath *)indexPath reuseIdentifier:(NSString *)reuseIdentifier style:(UITableViewCellStyle)style detail:(BOOL)detail {
    InlineEditTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        if (self.definition[@"cellStyle"]) {
            style = [self.definition[@"cellStyle"] integerValue];
        }
        
        NSString *className = nil;
        if (self.definition[@"control"]) {
            className = [NSString stringWithFormat:@"Inline%@TableViewCell", self.definition[@"control"]];
        } else if (self.definition[@"cellClassName"]) {
            className = self.definition[@"cellClassName"];
        }
        
        if (className) {
            cell = [[NSClassFromString(className) alloc] initWithStyle:style reuseIdentifier:reuseIdentifier];
        } else {
            cell = [[InlineEditTableViewCell alloc] initWithStyle:style reuseIdentifier:reuseIdentifier];
        }
        
        if (detail) {
            if (!self.editing) {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            } else {
                cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
        }
    }
    return cell;
}

- (void)updateCells {
    if (self.selectedEditing) {
        for (AbstractTableViewCell *cell in self.tableView.visibleCells) {
            cell.selectedEditingActive = NO;
        }
    }
}

- (void)updateCellBeforeDisplay:(AbstractTableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    cell.row = indexPath.row;
    if (self.selectedEditing) {
        cell.selectedEditingActive = self.selectedEditing &&
                                     [indexPath isEqual:self.selectedEditingIndexPath];
    }
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [self.definition[@"index"] boolValue] ? [self.contextEntity aggregationIndex:self.aggregation] : nil;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [[self.contextEntity aggregationIndex:self.aggregation] indexOfObject:title];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CellIdentifier";
    AbstractTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        BOOL detail = NO;
        if ([self.definition valueForKeyPath:@"detail.className"]) {
            detail = YES;
        }
        cell = [self createCell:indexPath reuseIdentifier:CellIdentifier style:UITableViewCellStyleDefault detail:detail];
    }
    
    [cell unbindAll];
    [cell reset];
    
    cell.delegate = self;
    cell.indexPath = indexPath;    
    cell.editing = self.editing;
    cell.definition = self.definition;

    [Bindable setOptions:cell options:self.definition[@"options"]];
    
    [self updateCellBeforeDisplay:cell indexPath:indexPath];

    if ([cell isKindOfClass:InlineEditTableViewCell.class]) {
        ((InlineEditTableViewCell *)cell).showPhotoIcon = [self.definition[@"photoIcon"] boolValue];
    }
    
    if (![self.definition[@"group"] boolValue]) {
        // TODO: Support group/index binding?
        ContextBinding *contextBinding = [self.contextBinding appendRow:indexPath.row];
        [cell bindContext:contextBinding].delegate = self;
    }
    JSONEntity *aggregationEntity = [self aggregationEntityByIndexPath:indexPath];
    if (self.definition[@"bindings"]) {
        for (NSDictionary *binding in self.definition[@"bindings"]) {
            [cell bind:aggregationEntity context:binding[@"context"] property:binding[@"property"] bindableProperty:binding[@"bindableProperty"]].delegate = self;
        }
    }
    
    if (self.selectionMode) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        if (self.selectionIndex && [self.selectionIndex integerValue] == indexPath.row) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } if (self.selectionUUID && [self.selectionUUID isEqualToString:[self entityUUID:aggregationEntity]]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    
    return cell;
}

- (void)accessoryButtonTapped:(UIControl *)button event:(UIEvent *)event {
    NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint: [[[event touchesForView: button] anyObject] locationInView: self.tableView]];
    if (!indexPath) {
        return;
    }
    [self.tableView.delegate tableView:self.tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
}

- (BOOL)didSelectEntity:(NSString *)uuid {
    NSIndexPath *indexPath = [self.contextEntity aggregationGroupIndex:self.aggregation uuid:uuid];
    if (indexPath) {
        [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    [self tableView:tableView didSelectRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.selectionMode) {
        
        AbstractTableViewCell *cell = (AbstractTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        _selectionIndex = @(indexPath.row);
        JSONEntity *aggregationEntity = [self aggregationEntityByIndexPath:indexPath];
        _selectionUUID = [self entityUUID:aggregationEntity];
        [self.delegate didSelectEntity:self.selectionUUID index:self.selectionIndex sender:self];
        for (UITableViewCell *cell in self.tableView.visibleCells) {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        
    } else if (self.editing && self.selectedEditing) {
        
        if ([indexPath isEqual:self.selectedEditingIndexPath]) {
            self.selectedEditingIndexPath = nil;
        } else {
            self.selectedEditingIndexPath = indexPath;
        }
        [tableView beginUpdates];
        [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
        [tableView insertSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
        [tableView endUpdates];
        
    } else {
        
        NSDictionary *detailDefinition = self.definition[@"detail"];
        if (detailDefinition) {
            NSString *className = nil;
            if ([detailDefinition valueForKey:@"className"]) {
                className = [detailDefinition valueForKey:@"className"];
                AbstractBaseTableViewController *detailViewController = [NSClassFromString(className) new];
                
                JSONEntity *aggregationEntity = [self aggregationEntityByIndexPath:indexPath];
                if (!aggregationEntity) {
                    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
                    return;
                }
                
                if ([self.definition[@"ref"] boolValue]) {
                    aggregationEntity = [self.contextEntity aggregation:self.aggregationReferenced uuid:[self entityUUID:aggregationEntity]];
                }
                
                detailViewController.entity = aggregationEntity;
                
                if (detailDefinition[@"title"]) {
                    detailViewController.title = detailDefinition[@"title"];
                }
                
                [detailViewController bind:aggregationEntity context:nil property:@"shortName" bindableProperty:@"title"].delegate = self;
                
                if (![self.definition[@"suppressEdit"] boolValue]) {
                    detailViewController.editing = self.editing;
                }
                
                if ([self.definition valueForKeyPath:@"detail.bindings"]) {
                    for (NSDictionary *binding in [self.definition valueForKeyPath:@"detail.bindings"]) {
                        [detailViewController bind:aggregationEntity context:binding[@"context"] property:binding[@"property"] bindableProperty:binding[@"bindableProperty"]].delegate = detailViewController;
                    }
                }
                
                [self.navigationController pushViewController:detailViewController animated:YES];
            }
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.definition[@"delete"] boolValue] ? UITableViewCellEditingStyleDelete : UITableViewCellEditingStyleNone;
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *actions = [@[] mutableCopy];
    
    if ([self.definition[@"delete"] boolValue]) {
        UITableViewRowAction *deleteButton = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:NSLocalizedString(@"Delete", @"") handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
            [self tableView:tableView commitEditingStyle:UITableViewCellEditingStyleDelete forRowAtIndexPath:indexPath];
        }];
        [actions addObject:deleteButton];
    }
    
    return actions;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.definition[@"delete"] boolValue];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        JSONEntity *aggregationEntity = [self aggregationEntityByIndexPath:indexPath];
        NSString *groupName = [self.definition[@"group"] boolValue] ? [self.contextEntity aggregationGroupName:self.aggregation group:indexPath.section] : nil;
        [self.tableView beginUpdates];
        [self.contextEntity removeAggregation:self.aggregation uuid:[self entityUUID:aggregationEntity] trigger:self.contextBinding];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        if ([self.definition[@"group"] boolValue]) {
            if ([self.contextEntity numberOfAggregation:self.aggregation groupName:groupName] == 0 && ![groupName isEqualToString:@""]) {
                [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
            }
        }
        [self.tableView endUpdates];
        if ([self.contextEntity numberOfAggregation:self.aggregation] == 0) {
            [self setEditing:NO animated:YES];
        }
        if (self.selectedEditingIndexPath && [indexPath isEqual:self.selectedEditingIndexPath]) {
            self.selectedEditingIndexPath = nil;
        }
    }
}

- (JSONEntity *)aggregationEntityByIndexPath:(NSIndexPath *)indexPath {
    NSString *aggregation = self.aggregation;
    if ([self.definition[@"group"] boolValue]) {
        return [self.contextEntity aggregation:aggregation group:indexPath.section index:indexPath.row];
    } else {
        return [self.contextEntity aggregation:aggregation index:indexPath.row];
    }
}

- (NSString *)entityUUID:(JSONEntity *)entity {
    if ([entity isKindOfClass:JSONEntity.class]) {
        return entity.uuid;
    }
    return nil;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self.contextEntity filterAggregation:self.aggregation bySearchText:searchText];
    [self.tableView reloadData];
}

- (void)didPressClear:(id)sender {
    _selectionIndex = nil;
    _selectionUUID = nil;
    for (UITableViewCell *cell in self.tableView.visibleCells) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    AbstractTableViewCell *cell = (AbstractTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    JSONEntity *aggregationEntity = [self aggregationEntityByIndexPath:indexPath];
    [self.delegate didClearEntity:[self entityUUID:aggregationEntity] index:@(indexPath.row) sender:cell];
    [self.tableView reloadData];
}

- (void)setSelectionIndex:(NSNumber *)selectionIndex {
    _selectionIndex = selectionIndex;
    [self.tableView reloadData];
}

- (void)setSelectionUUID:(NSString *)selectionUUID {
    _selectionUUID = selectionUUID;
    [self.tableView reloadData];
}

- (void)entityPropertyDidChange:(PropertyBinding *)propertyBinding {
    [self.delegate entityPropertyDidChange:propertyBinding];
}

- (void)controlPropertyDidChange:(PropertyBinding *)propertyBinding {
    [self.delegate controlPropertyDidChange:propertyBinding];
}

@end