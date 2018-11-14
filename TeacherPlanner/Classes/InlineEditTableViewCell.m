//
//  InlineEditTableViewCell.m
//  TeacherPlanner
//
//  Created by Oliver on 13.04.14.
//
//

#import "InlineEditTableViewCell.h"
#import <QuartzCore/QuartzCore.h>
#import "Configuration.h"
#import "JSONEntity.h"
#import "Model.h"
#import "Application.h"
#import "Photo.h"
#import "PropertyBinding.h"
#import "Utilities.h"
#import "UIImage+Extension.h"

#define kPhotoImageSize 41

@interface InlineEditTableViewCell ()
@property (nonatomic, strong) UIView *ribbonView;
@end

@implementation InlineEditTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.imageView.layer.cornerRadius = kPhotoImageSize / 2.0;
        self.imageView.clipsToBounds = YES;
        self.imageView.autoresizingMask = UIViewAutoresizingNone;
    }
    return self;
}

- (UITextField *)textField {
    if (!_textField) {
        _textField = [[UITextField alloc] initWithFrame:CGRectZero];
        _textField.font = self.textLabel.font;
        _textField.tintColor = [Configuration instance].highlightColor;
        _textField.hidden = YES;
        _textField.enabled = NO;
        _textField.delegate = self;
        _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
        [_textField addTarget:self action:@selector(textDidChange:) forControlEvents:UIControlEventEditingChanged];
        [self.contentView addSubview:_textField];
    }
    return _textField;
}

- (UIView *)ribbonView {
    if (!_ribbonView) {
        _ribbonView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 5.0f, self.frame.size.height)];
        _ribbonView.backgroundColor = [UIColor clearColor];
        _ribbonView.autoresizingMask = UIViewAutoresizingFlexibleHeight |
            UIViewAutoresizingFlexibleRightMargin;
    }
    return _ribbonView;
}

- (void)reset {
    [super reset];
    self.imageValue = nil;
    self.color = nil;
    _showInitialsIcon = NO;
    _showPhotoIcon = NO;
    _secureTextEntry = NO;
    _secureTextEntryNumber = @(NO);
    _keyboard = nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = self.contentView.frame.size.width - self.accessoryWidth - kCellContentOffset;
    self.imageView.frame = CGRectMake(kCellContentOffset,
                                      3,
                                      kPhotoImageSize,
                                      kPhotoImageSize);
    self.textField.frame = CGRectMake(kCellContentOffset +
                                      (self.showIcon ? kPhotoImageSize + kCellContentOffset : 0),
                                      0,
                                      width -
                                      (self.showIcon ? kPhotoImageSize + kCellContentOffset : 0),
                                      self.contentView.frame.size.height);
    self.initialsTextLabel.frame = self.imageView.frame;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    if (editing || self.alwaysEditing) {
        self.textField.hidden = NO;
        self.textField.enabled = YES;
        self.textLabel.hidden = YES;
        [UIView animateWithDuration:0.25 animations:^{
            self.detailTextLabel.alpha = 0.0;
        }];
    } else {
        self.textField.hidden = YES;
        self.textField.enabled = NO;
        self.textLabel.hidden = NO;
        [UIView animateWithDuration:0.25 animations:^{
            self.detailTextLabel.alpha = 1.0;
        }];
    }
    [super setEditing:editing animated:animated];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self.delegate didBeginTextEditCell:self];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self.delegate didEndTextEditCell:self];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    self.ribbonView.backgroundColor = self.color;
}

- (NSString *)placeholder {
    return self.textField.placeholder;
}

- (void)setPlaceholder:(NSString *)text {
    self.textField.placeholder = text;
}

- (void)setShowInitialsIcon:(BOOL)showInitialsIcon {
    _showInitialsIcon = showInitialsIcon;
}

- (void)setShowPhotoIcon:(BOOL)showPhotoIcon {
    _showPhotoIcon = showPhotoIcon;
    _showInitialsIcon = showPhotoIcon;
}

- (void)setSecureTextEntry:(BOOL)secureTextEntry {
    _secureTextEntry = secureTextEntry;
    _secureTextEntryNumber = @(_secureTextEntry);
    self.textField.secureTextEntry = _secureTextEntry;
    self.value = @"";
    [self.textField setNeedsLayout];
    [self.textField setNeedsDisplay];
}

- (void)setSecureTextEntryNumber:(NSNumber *)secureTextEntryNumber {
    _secureTextEntryNumber = secureTextEntryNumber;
    _secureTextEntry = [secureTextEntryNumber boolValue];
    self.textField.secureTextEntry = _secureTextEntry;
    self.value = @"";
    [self.textField setNeedsLayout];
    [self.textField setNeedsDisplay];
}

- (void)_updateIcon {
    if (self.showPhotoIcon && self.imageValue) {
        [self _updatePhotoIcon];
    } else if (self.showInitialsIcon) {
        [self _updateInitialsIcon];
    }
}

- (BOOL)showIcon {
    return (self.showPhotoIcon && self.imageValue) || self.showInitialsIcon;
}

- (void)_updateInitialsIcon {
    self.imageView.image = nil;
    if (self.showInitialsIcon) {
        self.initialsTextLabel.hidden = NO;
        NSString *nameInitials = [Utilities nameInitials:self.value];
        if (nameInitials) {
            self.imageView.image = [UIImage imageNamed:@"initials_icon"];
            if (!self.initialsTextLabel) {
                self.initialsTextLabel = [[UILabel alloc] initWithFrame:CGRectZero];
                self.initialsTextLabel.textAlignment = NSTextAlignmentCenter;
                self.initialsTextLabel.backgroundColor = [UIColor clearColor];
                self.initialsTextLabel.numberOfLines = 1;
                self.initialsTextLabel.textColor = [UIColor whiteColor];
                self.initialsTextLabel.font = [UIFont systemFontOfSize:16.0f];
                [self.contentView addSubview:self.initialsTextLabel];
            }
            self.initialsTextLabel.frame = self.imageView.frame;
            self.initialsTextLabel.text = nameInitials;
        } else {
            self.imageView.image = [UIImage imageNamed:@"initials_icon_person"];
            if (self.initialsTextLabel) {
                [self.initialsTextLabel removeFromSuperview];
            }
            self.initialsTextLabel = nil;
        }
    } else {
        self.imageView.image = nil;
        self.initialsTextLabel.hidden = YES;
    }
}

- (void)_updatePhotoIcon {
    if (self.showPhotoIcon && self.imageValue) {
        [Photo asyncPhotoThumbnail:self.imageValue done:^(UIImage *image) {
            self.imageView.image = image;
            self.initialsTextLabel.hidden = YES;
        }];
    } else {
        self.imageView.image = nil;
        self.initialsTextLabel.hidden = YES;
    }
}

- (void)setValue:(id)value {
    super.value = value;
    NSString *text = (NSString *)value;
    self.textField.text = text;
    if (self.label) {
        self.textLabel.textColor = [UIColor blackColor];
        self.detailTextLabel.text = text;
    } else {
        if (text.length > 0) {
            self.textLabel.textColor = [UIColor blackColor];
            self.textLabel.text = text;
        } else {
            self.textLabel.textColor = PLACEHOLDER_COLOR;
            self.textLabel.text = self.placeholder;
        }
    }
    if (!(self.showPhotoIcon && self.imageValue) && self.showInitialsIcon) {
        [self _updateInitialsIcon];
    }
}

- (void)setDetailValue:(id)detailValue {
    super.detailValue = detailValue;
    self.detailTextLabel.text = (NSString *)detailValue;
}

- (void)setColor:(UIColor *)color {
    _color = color;
    if (color) {
        self.ribbonView.backgroundColor = color;
        [self.contentView addSubview:self.ribbonView];
    } else {
        [self.ribbonView removeFromSuperview];
    }
}

- (void)setImageValue:(NSString *)imageValue {
    _imageValue = imageValue;
    [self _updateIcon];
}

- (void)textDidChange:(UITextField *)textField {
    NSString *text = [textField.text stringByTrimmingCharactersInSet:
                      [NSCharacterSet whitespaceCharacterSet]];
    [self setProperty:@"value" value:text];
}

- (void)setKeyboard:(NSNumber *)keyboard {
    _keyboard = keyboard;
    if (keyboard) {
        self.textField.keyboardType = [keyboard integerValue];
    } else {
        self.textField.keyboardType = UIKeyboardTypeDefault;
    }
}

- (void)setAutocapitalization:(NSNumber *)autocapitalization {
    _autocapitalization = autocapitalization;
    if (autocapitalization) {
        self.textField.autocapitalizationType = [autocapitalization integerValue];
    } else {
        self.textField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    }
}

- (void)resignFirstResponder {
    [self.textField resignFirstResponder];
}

@end