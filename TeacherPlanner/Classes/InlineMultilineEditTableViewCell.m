//
//  InlineMultilineEditTableViewCell.m
//  TeacherPlanner
//
//  Created by Oliver Klemenz on 28.12.14.
//
//

#import "InlineMultilineEditTableViewCell.h"
#import "Configuration.h"

@interface InlineMultilineEditTableViewCell ()
@property (nonatomic, retain) UITextView *textView;
@end

@implementation InlineMultilineEditTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (UITextView *)textView {
    if (!_textView) {
        _textView = [[UITextView alloc] initWithFrame:CGRectZero];
        _textView.font = self.textLabel.font;
        _textView.tintColor = [Configuration instance].highlightColor;
        _textView.hidden = NO;
        _textView.delegate = self;
        _textView.autocapitalizationType = UITextAutocapitalizationTypeNone;
        [self.contentView addSubview:_textView];
    }
    return _textView;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = self.contentView.frame.size.width - 2 * 12;
    CGFloat height = self.contentView.frame.size.height;
    self.textView.frame = CGRectMake(12, 0, width, height);
    if (self.label && !self.editing) {
        self.textView.frame = CGRectMake(12 + width / 3.0, 0, width * 2.0 / 3.0, height);
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    if (editing || self.alwaysEditing) {
        [UIView animateWithDuration:0.25 animations:^{
            self.textLabel.alpha = 0.0;
        }];
        if (self.label) {
            self.textView.textAlignment = NSTextAlignmentLeft;
            self.textView.textColor = self.textLabel.textColor;
            [self addPlaceholder];
        }
    } else {
        [UIView animateWithDuration:0.25 animations:^{
            self.textLabel.alpha = 1.0;
        }];
        if (self.label) {
            self.textView.textAlignment = NSTextAlignmentRight;
            self.textView.textColor = self.detailTextLabel.textColor;
            [self removePlaceholder];
        }
    }
    self.textView.editable = editing;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [self removePlaceholder];
    [self.delegate didBeginTextEditCell:self];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [self addPlaceholder];
    [self.delegate didEndTextEditCell:self];
}

- (void)setPlaceholder:(NSString *)placeholder {
    [super setPlaceholder:placeholder];
    [self addPlaceholder];
}

- (void)addPlaceholder {
    if (!self.label || self.editing) {
        self.textView.textColor = [UIColor blackColor];
        if ([self.textView.text isEqualToString:@""] ||
            [self.textView.text isEqualToString:self.placeholder]) {
            self.textView.text = self.placeholder;
            self.textView.textColor = PLACEHOLDER_COLOR;
        }
    }
}

- (void)removePlaceholder {
    if (!self.label || self.editing) {
        if ([self.textView.text isEqualToString:self.placeholder]) {
            self.textView.text = @"";
            self.textView.textColor = [UIColor blackColor];
        }
    }
}

- (void)setValue:(id)value {
    super.value = value;
    NSString *text = (NSString *)value;
    if (![self.textView.text isEqual:text]) {
        self.textView.text = text;
        [self addPlaceholder];
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    [self setProperty:@"value" value:textView.text];
}

- (void)resignFirstResponder {
    [self.textView resignFirstResponder];
}

@end