//
//  AbstractContentTableViewController.m
//  TeacherPlanner
//
//  Created by Oliver on 17.05.14.
//
//

#import "AbstractContentTableViewController.h"
#import "AbstractContentDetailTableViewController.h"
#import "UIButton+Extension.h"
#import "NSString+Extension.h"
#import "Utilities.h"
#import "InlineCodeSelectionTableViewCell.h"
#import "objc/message.h"

@interface AbstractContentTableViewController ()

@end

@implementation AbstractContentTableViewController

- (instancetype)init {
    self = [self initWithStyle:UITableViewStyleGrouped];
    if (self) {
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        self.definition = @[];
        self.selectedEditingIndexPath = nil;
    }
    return self;
}

- (void)setDefinition:(NSArray *)definition {
    if (!_definition || _definition.count == 0) {
        _definition = definition;
    } else {
        if (definition) {
            NSMutableArray *newDefinition = [@[] mutableCopy];
            for (NSDictionary *section in _definition)  {
                [newDefinition addObject:[section mutableCopy]];
            }
            NSInteger index = 0;
            for (NSDictionary *section in definition)  {
                if (index < newDefinition.count) {
                    NSMutableDictionary *newSection = newDefinition[index];
                    [newSection addEntriesFromDictionary:section];
                } else {
                    [newDefinition addObject:section];
                }
                index++;
            }
            _definition = newDefinition;
        } else {
            _definition = nil;
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = YES;    
    self.tableView.allowsSelectionDuringEditing = YES;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    if (animated) {
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    }
    self.selectedEditingIndexPath = nil;
    for (AbstractTableViewCell *cell in [self.tableView visibleCells]) {
        cell.selectedEditingActive = NO;
    }
}

- (void)didSelectEntity:(NSString *)uuid index:(NSNumber *)index sender:(id)sender {
    NSIndexPath *selectedRow = [self.tableView indexPathForSelectedRow];
    AbstractTableViewCell *selectedCell = (AbstractTableViewCell *)[self.tableView cellForRowAtIndexPath:selectedRow];
    [selectedCell setProperty:@"uuid" value:uuid];
    [selectedCell setProperty:@"index" value:index];
}

- (void)didClearEntity:(NSString *)uuid index:(NSNumber *)index sender:(id)sender {
    NSIndexPath *selectedRow = [self.tableView indexPathForSelectedRow];
    AbstractTableViewCell *selectedCell = (AbstractTableViewCell *)[self.tableView cellForRowAtIndexPath:selectedRow];
    [selectedCell setProperty:@"uuid" value:nil];
    [selectedCell setProperty:@"index" value:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.definition count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.definition[section][@"definition"] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.definition[section][@"title"];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *definition = self.definition[indexPath.section][@"definition"][indexPath.row];
    if ([definition[@"selectedEditing"] boolValue]) {
        BOOL selectedEditing = self.tableView.editing &&
                               [indexPath isEqual:self.selectedEditingIndexPath];
        if (selectedEditing) {
            if ([definition valueForKeyPath:@"select.height"]) {
                return [[definition valueForKeyPath:@"select.height"] floatValue];
            }
            if ([definition valueForKeyPath:@"edit.height"]) {
                return [[definition valueForKeyPath:@"edit.height"] floatValue];
            }
        }
        if ([definition valueForKeyPath:@"display.height"]) {
            return [[definition valueForKeyPath:@"display.height"] floatValue];
        }
    } else {
        if (self.tableView.editing && [definition valueForKeyPath:@"edit.height"]) {
            return [[definition valueForKeyPath:@"edit.height"] floatValue];
        }
        if ([definition valueForKeyPath:@"display.height"]) {
            return [[definition valueForKeyPath:@"display.height"] floatValue];
        }
    }
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *section = self.definition[indexPath.section];
    NSDictionary *definition = section[@"definition"][indexPath.row];
    
    UITableViewCellStyle style = UITableViewCellStyleDefault;
    if ([definition[@"label"] boolValue]) {
        style = UITableViewCellStyleValue1;
    }
    
    NSString *className = @"";
    if (definition[@"control"]) {
        className = [NSString stringWithFormat:@"Inline%@TableViewCell", definition[@"control"]];
    } else if (definition[@"className"]) {
        className = className;
    }

    NSString *cellIdentifier = [NSString stringWithFormat:@"CellIdentifier_%tu_%tu", indexPath.section, indexPath.row];
    AbstractTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        if (!cell) {
            cell = [[NSClassFromString(className) alloc] initWithStyle:style reuseIdentifier:cellIdentifier];
        }
    }
    
    [cell unbindAll];
    [cell reset];
    
    cell.delegate = self;
    cell.indexPath = indexPath;
    cell.definition = definition;
    
    cell.editing = self.editing;
    
    [Bindable setOptions:cell options:definition[@"options"]];
    
    if ([definition[@"label"] boolValue]) {
        cell.label = YES;
    }
    if (definition[@"title"]) {
        cell.text = definition[@"title"];
        cell.placeholder = definition[@"title"];
    }
    if (definition[@"detailTitle"]) {
        cell.detailText = definition[@"detailTitle"];
    }
    if (definition[@"icon"]) {
        cell.icon = definition[@"icon"];
    }
    
    if ([definition[@"selectedEditing"] boolValue]) {
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.selectedEditing = YES;
        cell.selectedEditingActive = [indexPath isEqual:self.selectedEditingIndexPath];
    } else if (![definition[@"selection"] boolValue]) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (definition[@"detail"] || definition[@"displayDetail"]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    }
    if (definition[@"detail"] || definition[@"editDetail"]) {
        cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    if ([cell isKindOfClass:InlineCodeSelectionTableViewCell.class]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    ContextBinding *contextBinding = [ContextBinding createContextBinding:self.entity
                                                                  context:section[@"context"]];
    contextBinding = [contextBinding appendContext:definition[@"context"]];
    [cell bindContext:contextBinding].delegate = self;
    
    if (definition[@"bindings"]) {
        for (NSDictionary *binding in definition[@"bindings"]) {
            [cell bind:[contextBinding appendContext:binding[@"context"]] property:binding[@"property"]
                        bindableProperty:binding[@"bindableProperty"]].delegate = self;
        }
    }
    
    [self showCell:cell indexPath:indexPath];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    NSDictionary *sectionDefintion = self.definition[section];
    if (sectionDefintion[@"footer"]) {
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
        UILabel *explanationLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, self.view.frame.size.width - 30, 40)];
        explanationLabel.font = [UIFont systemFontOfSize:14.0f];
        explanationLabel.textColor = [UIColor darkGrayColor];
        explanationLabel.numberOfLines = 0;
        explanationLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        explanationLabel.text = sectionDefintion[@"footer"];
        explanationLabel.textAlignment = NSTextAlignmentLeft;
        [explanationLabel sizeToFit];
        [footerView addSubview:explanationLabel];
        return footerView;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 60;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    [self.tableView.delegate tableView:tableView didSelectRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    AbstractTableViewCell *cell = (AbstractTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];

    if (self.editing && cell.selectedEditing) {
        [tableView beginUpdates];
        if (self.selectedEditingIndexPath && ![self.selectedEditingIndexPath isEqual:indexPath]) {
            [tableView deleteRowsAtIndexPaths:@[self.selectedEditingIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[self.selectedEditingIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
        if ([indexPath isEqual:self.selectedEditingIndexPath]) {
            self.selectedEditingIndexPath = nil;
        } else {
            self.selectedEditingIndexPath = indexPath;
        }
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [tableView endUpdates];
    } else if (![cell.definition[@"control"] isEqualToString:@"EntitySelection"]) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }

    NSDictionary *definition = cell.definition;

    if ([cell isKindOfClass:InlineCodeSelectionTableViewCell.class]) {
        [self resignFirstResponder];
        [(InlineCodeSelectionTableViewCell *)cell showSelection:self.navigationController];
        return;
    }
    
    NSDictionary *detailDefinition = definition[@"detail"];
    if (self.editing && definition[@"editDetail"]) {
        detailDefinition = definition[@"editDetail"];
    } else if (!self.editing && definition[@"displayDetail"]) {
        detailDefinition = definition[@"displayDetail"];
    }
    
    if (detailDefinition) {
        [self resignFirstResponder];
        
        NSString *className = nil;
        if (detailDefinition[@"cellClassName"] || detailDefinition[@"control"]) {
            className = @"AbstractContentDetailTableViewController";
        } else {
            className = @"AbstractContentTableViewController";
        }
        if (detailDefinition[@"className"]) {
            className = detailDefinition[@"className"];
        }
        
        UIViewController *viewController = [NSClassFromString(className) new];
        
        viewController.title = detailDefinition[@"title"] ? detailDefinition[@"title"] : definition[@"title"];
        if ([viewController isKindOfClass:AbstractBaseTableViewController.class]) {
            NSString *subTitle = detailDefinition[@"subTitle"] ? detailDefinition[@"subTitle"] : definition[@"subTitle"];
            if (subTitle.length > 0) {
                [(AbstractBaseTableViewController *)viewController setSubTitle:subTitle];
            } else {
                [(AbstractBaseTableViewController *)viewController setSubTitle:
                 [NSString stringWithFormat:@"%@ - %@", self.subTitle, self.title]];
            }
        }
        
        if ([viewController isKindOfClass:AbstractContentTableViewController.class]) {

            AbstractContentTableViewController *contentViewController =
                (AbstractContentTableViewController *)viewController;
            
            ContextBinding *contextBinding = [cell.contextBinding appendContext:detailDefinition[@"context"]];
            contentViewController.entity = [contextBinding contextEntity];

            if (detailDefinition[@"definition"]) {
                contentViewController.definition = detailDefinition[@"definition"];
            }
            
            [contentViewController bind:contentViewController.entity context:nil property:@"shortName" bindableProperty:@"title"].delegate = self;
            
            [Bindable setOptions:contentViewController options:detailDefinition[@"options"]];
            
            if (![detailDefinition[@"suppressEdit"] boolValue]) {
                contentViewController.editing = self.editing;
            }
            
            [self showContent:contentViewController];
            [self.navigationController pushViewController:contentViewController animated:YES];
            
        } else if ([viewController isKindOfClass:AbstractContentDetailTableViewController.class]) {

            AbstractContentDetailTableViewController *detailViewController = (AbstractContentDetailTableViewController *)viewController;
            
            detailViewController.delegate = self;
            detailViewController.definition = detailDefinition;
            
            detailViewController.selectedEditing = detailDefinition[@"selectedEditing"] && [detailDefinition[@"selectedEditing"] boolValue];
            
            [Bindable setOptions:detailViewController options:detailDefinition[@"option"]];
            
            detailViewController.contextBinding = [cell.contextBinding appendContext:detailDefinition[@"context"]];
            [detailViewController bindContext:detailViewController.contextBinding].delegate = self;

            if ([cell propertyBinding:@"index"]) {
                detailViewController.selectionIndex = [[cell propertyBinding:@"index"] value];
            }
            if ([cell propertyBinding:@"uuid"]) {
                detailViewController.selectionUUID = [[cell propertyBinding:@"uuid"] value];
            }
            
            if ([detailDefinition[@"selection"] boolValue] ||
                [definition[@"control"] isEqualToString:@"EntitySelection"]) {
                detailViewController.selectionMode = self.editing;
                detailViewController.suppressSelectionClear = [detailDefinition[@"suppressSelectionClear"] boolValue];
                detailViewController.editing = NO;
            } else {
                if (![detailDefinition[@"suppressEdit"] boolValue]) {
                    detailViewController.editing = self.editing;
                }
            }
            
            [self showDetails:detailViewController];
            [self.navigationController pushViewController:detailViewController animated:YES];
        } else {
            ContextBinding *contextBinding = [cell.contextBinding appendContext:detailDefinition[@"context"]];
            if (contextBinding.entity) {
                SEL selector = NSSelectorFromString([NSString stringWithFormat:@"setEntity:"]);
                if ([viewController respondsToSelector:selector]) {
                    objc_msgSend(viewController, selector, contextBinding.entity);
                }
            }
            [self.navigationController pushViewController:viewController animated:YES];
        }
    }
}

- (void)accessoryButtonTapped:(UIControl *)button event:(UIEvent *)event {
    NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint: [[[event touchesForView: button] anyObject] locationInView: self.tableView]];
    if (!indexPath) {
        return;
    }
    [self.tableView.delegate tableView: self.tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

- (void)showCell:(AbstractTableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
}

- (void)showContent:(AbstractContentTableViewController *)contentViewController {
}

- (void)showDetails:(AbstractContentDetailTableViewController *)detailsViewController {
}

- (BOOL)resignFirstResponder {
    for (AbstractTableViewCell *cell in [self.tableView visibleCells]) {
        [cell resignFirstResponder];
    }
    return YES;
}

- (void)didChange {
    [self.tableView reloadData];
}

@end