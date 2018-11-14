//
//  InlineCodeSelectionTableViewController.m
//  TeacherPlanner
//
//  Created by Oliver on 01.06.14.
//
//

#import "InlineCodeSelectionTableViewController.h"
#import "Codes.h"
#import "AppDelegate.h"

@interface InlineCodeSelectionTableViewController () {
    UIBarButtonItem *_clearButton;
}

@end

@implementation InlineCodeSelectionTableViewController

- (instancetype)initWithCode:(NSString *)code propertyBinding:(PropertyBinding *)propertyBinding {
    self = [super init];
    if (self) {
        _code = code;
        _propertyBinding = propertyBinding;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [Codes textForCode:self.code plural:NO];
    if (self.selectionMode && !self.hideClear) {
        self.navigationItem.rightBarButtonItem = self.clearButton;
    }
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        [self setEdgesForExtendedLayout:UIRectEdgeBottom];
    }
}

- (void)setHideClear:(BOOL)hideClear {
    _hideClear = hideClear;
    if (hideClear) {
        self.navigationItem.rightBarButtonItem = nil;
    } else {
        self.navigationItem.rightBarButtonItem = self.clearButton;
    }
}

- (UIBarButtonItem *)clearButton {
    if (!_clearButton) {
        _clearButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Clear", @"")
                                                        style:UIBarButtonItemStylePlain target:self
                                                       action:@selector(clear:)];
    }
    return _clearButton;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [Codes codeCount:self.code];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    if (indexPath.row + 1 == [self.propertyBinding.value integerValue]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    cell.textLabel.text = [Codes textForCode:self.code value:indexPath.row + 1];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.selectionMode) {
        [self.propertyBinding setValue:@(indexPath.row + 1)];
        for (UITableViewCell *cell in self.tableView.visibleCells) {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        [self.tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)clear:(id)sender {
    if (self.selectionMode) {
        [self.propertyBinding setValue:@(0)];
        for (UITableViewCell *cell in self.tableView.visibleCells) {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
}

@end