//
//  AbstractBaseTableViewController.m
//  TeacherPlanner
//
//  Created by Oliver Klemenz on 18.01.15.
//
//

#import "AbstractBaseTableViewController.h"
#import "DefaultBindable.h"
#import "Utilities.h"
#import "Common.h"
#import "UILabel+Extension.h"
#import "Configuration.h"
#import "AbstractTabBarViewController.h"
#import "UITabBarItem+Extension.h"
#import "NSString+Extension.h"
#import "AppDelegate.h"

@interface AbstractBaseTableViewController () {
    NSString *_title;
    DefaultBindable *_bindable;
    UILabel *_twoLineTitle;
    AbstractTableViewCell *_activeTextCell;
}

@property (nonatomic, strong) UIBarButtonItem *closeButton;

@end

#pragma clang diagnostic ignored "-Wprotocol"
@implementation AbstractBaseTableViewController

@synthesize entity = _entity;

- (id)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        [self setEdgesForExtendedLayout:UIRectEdgeBottom];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.visible = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.visible = NO;
}

- (void)setup {
    _bindable = [[DefaultBindable alloc] initWithDelegate:self];
    /*
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
     */
}

- (void)setTabBarIcon:(NSString *)tabBarIcon {
    _tabBarIcon = tabBarIcon;
    [self setTabBarItem];
}

- (void)setSelectedTabBarIcon:(NSString *)selectedTabBarIcon {
    _selectedTabBarIcon = selectedTabBarIcon;
    [self setTabBarItem];
}

- (void)setTabBarItem {
    if (self.tabBarIcon) {
        self.tabBarItem = [UITabBarItem createCustomTintedBottomTabBarItem:self.name imageName:self.tabBarIcon selectedImageName:self.selectedTabBarIcon];
    } else {
        self.tabBarIcon = nil;
    }
}

- (UIBarButtonItem *)closeButton {
    if (!_closeButton) {
        _closeButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", @"")
                                                        style:UIBarButtonItemStylePlain target:self
                                                       action:@selector(close:)];
    }
    return _closeButton;
}

- (void)setCloseable:(BOOL)closeable {
    _closeable = closeable;
    if (closeable) {
        self.navigationItem.leftBarButtonItem = self.closeButton;
    } else {
        self.navigationItem.leftBarButtonItem = nil;
    }
}

- (void)setEditable:(BOOL)editable {
    _editable = editable;
    if (editable) {
        self.navigationItem.rightBarButtonItem = self.editButtonItem;
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    if ([self.entity isProtected]) {
        [Common showEditConfirmation:self okHandler:^{
            [self.entity setSuppressProtected:YES];
            [super setEditing:editing animated:animated];
        } cancelHandler:nil];
    } else {
        [super setEditing:editing animated:animated];
    }
}

- (UILabel *)twoLineTitle {
    if (!_twoLineTitle) {
        NSString *title = @"";
        if (self.title) {
            title = self.title;
        }
        if (self.subTitle) {
            title = [title stringByAppendingFormat:@"%@%@", title.length > 0 ? @"\n" : @"", self.subTitle];
        }
        _twoLineTitle = [UILabel createTwoLineTitleLabel:title color:[[Configuration instance] titleColor]];
        self.navigationItem.titleView = _twoLineTitle;
    }
    return _twoLineTitle;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    self.navigationItem.title = title;
    [self updateTitle];
}

- (NSString *)title {
    return _title;
}

- (void)setSubTitle:(NSString *)subTitle {
    if (subTitle.length > 0) {
        _subTitle = [subTitle truncateHeadToWidth:0.5 * self.view.bounds.size.width font:self.twoLineTitle.font lineBreakMode:NSLineBreakByTruncatingHead];
    } else {
        _subTitle = subTitle;
    }
    [self updateTitle];
}

- (void)setEntity:(JSONEntity *)entity {
    _entity = entity;
    [self updateTitle];
}

- (JSONEntity *)entity {
    if (_entity) {
        return _entity;
    }
    if (self.tabBarController) {
        return ((AbstractTabBarViewController *)self.tabBarController).entity;
    }
    return nil;
}

- (void)updateTitle {
    if (self.subTitle) {
        [self.twoLineTitle updateTwoLineTitleLabel:[NSString stringWithFormat:@"%@\n%@", self.title, self.subTitle] color:nil];
    } else {
        _twoLineTitle = nil;
        self.navigationItem.titleView = nil;
    }
}

- (void)setContext:(id)contextValue source:(id)source userInfo:(NSDictionary *)userInfo {
    if (!source || source != self) {
        [self.tableView reloadData];
    }
}

- (void)entityPropertyDidChange:(PropertyBinding *)propertyBinding {
}

- (void)controlPropertyDidChange:(PropertyBinding *)propertyBinding {
}

- (void)close:(id)sender {
    [[AppDelegate instance] dismiss:self animated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [Utilities clearGeneratedFolder];
    [[AppDelegate instance] dismiss:controller animated:YES completion:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - AbstractTableViewCellDelegate

- (void)present:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(void))completion {
    [[AppDelegate instance] present:viewController presenter:self animated:animated completion:completion];
}

- (void)push:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(void))completion {
    [self.navigationController pushViewController:viewController animated:YES];
    if (completion) {
        completion();
    }
}

- (void)popToRootViewControllerAnimated:(BOOL)animated {
    [self.navigationController popToRootViewControllerAnimated:animated];
}

- (void)popViewControllerAnimated:(BOOL)animated {
    [self.navigationController popViewControllerAnimated:animated];
}

- (void)didBeginTextEditCell:(AbstractTableViewCell *)cell {
    _activeTextCell = cell;
    [self.tableView scrollToRowAtIndexPath:_activeTextCell.indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
}

- (void)didEndTextEditCell:(AbstractTableViewCell *)cell {
    _activeTextCell = nil;
}

#pragma mark - Keyboard notifications

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
    
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    
    if (_activeTextCell) {
        [self.tableView scrollToRowAtIndexPath:_activeTextCell.indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
}

#pragma mark - Method forwarding

- (void)forwardInvocation:(NSInvocation *)invocation {
    if ([_bindable respondsToSelector:[invocation selector]]) {
        [invocation invokeWithTarget:_bindable];
    } else{
        [super forwardInvocation:invocation];
    }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    NSMethodSignature *signature = [super methodSignatureForSelector:selector];
    if (!signature) {
        signature = [_bindable methodSignatureForSelector:selector];
    }
    return signature;
}

- (BOOL)conformsToProtocol:(Protocol *)protocol {
    return [super conformsToProtocol:protocol] || [_bindable conformsToProtocol:protocol];
}

@end