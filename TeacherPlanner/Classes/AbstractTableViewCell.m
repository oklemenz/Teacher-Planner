//
//  AbstractTableViewCell.m
//  TeacherPlanner
//
//  Created by Oliver on 25.05.14.
//
//

#import "AbstractTableViewCell.h"
#import "DefaultBindable.h"

#define kCellAccessoryOffset 24
#define kCellStateInitial 0
#define kCellStateEditing 1
#define kCellStateDisplay 2

#pragma clang diagnostic ignored "-Wprotocol"
@implementation AbstractTableViewCell {
    DefaultBindable *_bindable;
    NSInteger _state;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _bindable = [[DefaultBindable alloc] initWithDelegate:self];
        _state = kCellStateInitial;
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.accessoryWidth = 0;
    if (self.editing) {
        if (self.editingAccessoryView) {
            self.accessoryWidth = self.editingAccessoryView.frame.size.width;
        }
        if (self.editingAccessoryType != UITableViewCellAccessoryNone) {
            self.accessoryWidth = kCellAccessoryOffset;
        }
    } else {
        if (self.accessoryView) {
            self.accessoryWidth = self.accessoryView.frame.size.width;
        }
        if (self.accessoryType != UITableViewCellAccessoryNone) {
            self.accessoryWidth = kCellAccessoryOffset;
        }
    }
    if (self.detailTextLabel.text.length > 0) {
        CGRect frame = self.accessoryView.frame;
        frame.origin.x += 3.0f;
        self.accessoryView.frame = frame;
    }
    [self updateContent:NO];
}

- (void)setSelectedEditingActive:(BOOL)selectedEditingActive {
    _selectedEditingActive = selectedEditingActive;
    [self updateContent:NO];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self updateContent:animated];
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = self.textLabel.font;
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.text = self.textLabel.text;
    }
    return _titleLabel;
}

- (void)updateContent:(BOOL)animated {
    CGFloat height = [[self.definition valueForKeyPath:@"edit.height"] floatValue];
    CGFloat offsetX = [[self.definition valueForKeyPath:@"edit.offsetX"] floatValue];
    CGFloat offsetY = [[self.definition valueForKeyPath:@"edit.offsetY"] floatValue];
    BOOL editing = (!self.selectedEditing && (self.editing || self.alwaysEditing)) ||
                    (self.selectedEditing && (self.editing || self.alwaysEditing) && self.selectedEditingActive);
    if (editing) {
        if (self.showTitle) {
            self.titleLabel.frame = CGRectMake(self.textLabel.frame.origin.x, 12.0f,
                                               self.contentView.bounds.size.width, 20.5f);
            self.offsetTitle = self.titleLabel.frame.size.height;
        }
    }
    [self updateContent:animated editing:editing height:height offsetX:offsetX offsetY:offsetY duration:0.25f];
}

- (void)updateContent:(BOOL)animated editing:(BOOL)editing height:(CGFloat)height offsetX:(CGFloat)offsetX offsetY:(CGFloat)offsetY duration:(CGFloat)duration {
    // To be overwritten by specific cell sub-class
}

- (void)setViews:(NSArray *)views editing:(BOOL)editing animated:(BOOL)animated duration:(CGFloat)duration {
    if (editing && _state != kCellStateEditing) {
        if (self.showTitle) {
            [self.contentView addSubview:self.titleLabel];
        }
        for (UIView *view in views) {
            [self.contentView addSubview:view];
        }
        void (^changes)(void) = ^{
            if (self.titleLabel) {
                self.titleLabel.alpha = 1.0f;
            }
            for (UIView *view in views) {
                view.alpha = 1.0f;
            }
            self.textLabel.alpha = 0.0f;
            self.detailTextLabel.alpha = 0.0f;
        };
        if (animated) {
            [self.layer removeAllAnimations];
            [UIView animateWithDuration:duration animations:changes];
        } else {
            changes();
        }
        _state = kCellStateEditing;
    } else if (!editing && _state != kCellStateDisplay) {
        void (^changes)(void) = ^{
            if (self.showTitle) {
                self.titleLabel.alpha = 0.0f;
            }
            for (UIView *view in views) {
                view.alpha = 0.0f;
            }
            self.textLabel.alpha = 1.0f;
            self.detailTextLabel.alpha = 1.0f;
        };
        void (^completed)(BOOL finished) = ^(BOOL finished) {
            if (finished) {
                if (self.showTitle) {
                    [self.titleLabel removeFromSuperview];
                }
                for (UIView *view in views) {
                    [view removeFromSuperview];
                }
            }
        };
        if (animated) {
            [self.layer removeAllAnimations];
            [UIView animateWithDuration:duration animations:changes completion:completed];
        } else {
            changes();
            completed(YES);
        }
        _state = kCellStateDisplay;
    }
}

- (void)reset {
    self.row = 0;
    self.index = nil;
    self.uuid = nil;
    self.indexPath = nil;
    
    self.value = nil;
    self.detailValue = nil;
    self.text = @"";
    self.detailText = @"";
    self.placeholder = @"";
    self.icon = nil;
    
    _showTitle = NO;
    _label = NO;
    _alwaysEditing = NO;
    _selectedEditing = NO;
    _selectedEditingActive = NO;

    [self updateContent:NO];
    _state = kCellStateInitial;
}

- (void)setText:(id)text {
    _text = text;
    self.textLabel.text = [NSString stringWithFormat:@"%@", text ? text : @""];
    if (self.showTitle) {
        self.titleLabel.text = self.textLabel.text;
    }
}

- (void)setDetailText:(id)detailText {
    _detailText = detailText;
    self.detailTextLabel.text = [NSString stringWithFormat:@"%@", detailText ? detailText : @""];
}

- (void)setIcon:(id)icon {
    _icon = icon;
    if (icon) {
        self.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@", icon ? icon : @""]];
    } else {
        self.imageView.image = nil;
    }
}

- (NSObject<Bindable> *)bindable {
    return _bindable;
}

- (void)setLabel:(BOOL)label {
    _label = label;
    [self updateContent:NO];
}

- (void)editTitle:(BOOL)editTitle {
    _editTitle = editTitle;
    [self updateContent:NO];
}

- (void)setAlwaysEditing:(BOOL)alwaysEditing {
    _alwaysEditing = alwaysEditing;
    [self updateContent:NO];
}

- (void)setSelectedEditing:(BOOL)selectedEditing {
    _selectedEditing = selectedEditing;
    [self updateContent:NO];
}

- (void)setShowTitle:(BOOL)showTitle {
    _showTitle = showTitle;
    if (self.showTitle) {
        [self.contentView addSubview:self.titleLabel];
    } else {
        [self.titleLabel removeFromSuperview];
    }
    [self updateContent:NO];
}

- (void)resignFirstResponder {
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