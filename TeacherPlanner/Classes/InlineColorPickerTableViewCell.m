//
//  InlineColorPickerTableViewCell.m
//  TeacherPlanner
//
//  Created by Oliver Klemenz on 13.12.14.
//
//

#import "InlineColorPickerTableViewCell.h"

@interface InlineColorPickerTableViewCell ()
@property (nonatomic, strong) ColorPicker *colorPicker;
@property (nonatomic, strong) UIView *colorPreviewView;
@end

@implementation InlineColorPickerTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (ColorPicker *)colorPicker {
    if (!_colorPicker) {
        _colorPicker = [[ColorPicker alloc] initWithFrame:CGRectZero];
        _colorPicker.delegate = self;
        _colorPicker.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    }
    return _colorPicker;
}

- (UIView *)colorPreviewView {
    if (!_colorPreviewView) {
        _colorPreviewView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50.0f, 50.0f)];
        _colorPreviewView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _colorPreviewView.layer.borderWidth = 1.0f;
        _colorPreviewView.layer.cornerRadius = 10.0f;
        _colorPreviewView.layer.masksToBounds = YES;
        self.accessoryView = _colorPreviewView;
        self.editingAccessoryView = _colorPreviewView;
    }
    return _colorPreviewView;
}

- (void)setHighlighted:(BOOL)highlighted {
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    self.colorPreviewView.backgroundColor = (UIColor *)self.value;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.colorPreviewView.backgroundColor = (UIColor *)self.value;
}

- (void)updateContent:(BOOL)animated editing:(BOOL)editing height:(CGFloat)height offsetX:(CGFloat)offsetX offsetY:(CGFloat)offsetY duration:(CGFloat)duration {
    self.colorPicker.frame = CGRectMake(offsetX,
                                        offsetY + self.offsetTitle,
                                        self.contentView.bounds.size.width - 2 * offsetX,
                                        height - 2 * offsetY - self.offsetTitle);
    [self setViews:@[self.colorPicker] editing:editing animated:YES duration:duration];
}

- (void)setValue:(id)value {
    if (!value) {
        value = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f];
    }
    super.value = value;
    self.colorPicker.color = (UIColor *)value;
    self.colorPreviewView.backgroundColor = (UIColor *)value;
}

- (void)didPickColor:(UIColor *)color sender:(id)sender {
    [self setProperty:@"value" value:color];
}

@end