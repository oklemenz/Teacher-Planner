//
//  AbstractContentViewController.m
//  TeacherPlanner
//
//  Created by Oliver on 22.06.14.
//
//

#import "AbstractBaseViewController.h"
#import "DefaultBindable.h"
#import "Utilities.h"
#import "Common.h"
#import "UILabel+Extension.h"
#import "Configuration.h"
#import "AbstractTabBarViewController.h"
#import "UITabBarItem+Extension.h"
#import "AppDelegate.h"

@interface AbstractBaseViewController () {
    NSString *_title;
    DefaultBindable *_bindable;
    UILabel *_twoLineTitle;
}

@property (nonatomic, strong) UIBarButtonItem *closeButton;

@end

#pragma clang diagnostic ignored "-Wprotocol"
@implementation AbstractBaseViewController

@synthesize entity = _entity;

- (instancetype)init {
    self = [super init];
    if (self) {
        _bindable = [[DefaultBindable alloc] initWithDelegate:self];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.visible = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.visible = NO;
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
        _twoLineTitle = [UILabel createTwoLineTitleLabel:[NSString stringWithFormat:@"%@\n%@", self.title, self.subTitle] color:[[Configuration instance] titleColor]];
        self.navigationItem.titleView = _twoLineTitle;
    }
    return _twoLineTitle;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    self.navigationItem.title = title;
    if (self.subTitle) {
        self.navigationItem.titleView = self.twoLineTitle;
    } else {
        _twoLineTitle = nil;
        self.navigationItem.titleView = nil;
    }
}

- (NSString *)title {
    return _title;
}

- (void)setEntity:(JSONEntity *)entity {
    _entity = entity;
    if (self.subTitle) {
        [self.twoLineTitle updateTwoLineTitleLabel:[NSString stringWithFormat:@"%@\n%@", self.title, self.subTitle] color:nil];
    }
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

- (void)setContext:(id)contextValue source:(id)source userInfo:(NSDictionary *)userInfo {
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