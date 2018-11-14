//
//  InlineSwitchTableViewCell.m
//  TeacherPlanner
//
//  Created by Oliver on 30.05.14.
//
//

#import "InlineSwitchTableViewCell.h"
#import "Configuration.h"

#define kSwitchStateOn  NSLocalizedString(@"Yes", @"")
#define kSwitchStateOff NSLocalizedString(@"No", @"")

@interface InlineSwitchTableViewCell ()
@property (nonatomic, strong) UISwitch *switchView;
@end

@implementation InlineSwitchTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (UISwitch *)switchView {
    if (!_switchView) {
        _switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
        if ([Configuration instance].brandingActive && [Configuration instance].highlightColor) {
            [_switchView setOnTintColor:[Configuration instance].highlightColor];
        }
        [_switchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
        _switchView.alpha = 0.0f;
        self.editingAccessoryView = self.switchView;
    }
    return _switchView;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    NSString *text = [self.value boolValue] ? kSwitchStateOn : kSwitchStateOff;
    if (editing || self.alwaysEditing) {
        void (^changes)(void) = ^{
            self.switchView.alpha = 1.0;
            self.detailTextLabel.alpha = 0.0;
            self.detailTextLabel.text = nil;
        };
        if (animated) {
            [UIView animateWithDuration:0.25 animations:changes];
        } else {
            changes();
        }
    } else {
        void (^changes)(void) = ^{
            self.switchView.alpha = 0.0;
            self.detailTextLabel.alpha = 1.0;
            self.detailTextLabel.text = text;
        };
        if (animated) {
            [UIView animateWithDuration:0.25 animations:changes completion:nil];
        } else {
            changes();
        }
    }
}

- (void)setValue:(id)value {
    if (!value) {
        value = @(NO);
    }
    super.value = value;
    [self.switchView setOn:[value boolValue] animated:YES];
}

- (void)switchChanged:(id)sender {
    [self setProperty:@"value" value:@(self.switchView.isOn)];
}

@end