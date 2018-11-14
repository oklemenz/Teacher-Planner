//
//  InlineCodePickerTableViewCell.m
//  TeacherPlanner
//
//  Created by Oliver on 24.05.14.
//
//

#import "InlineCodePickerTableViewCell.h"
#import "Codes.h"

@interface InlineCodePickerTableViewCell()
@property (nonatomic, strong) UIPickerView *pickerView;
@end

@implementation InlineCodePickerTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (UIPickerView *)pickerView {
    if (!_pickerView) {
        _pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, 200, 162)];
        _pickerView.delegate = self;
        _pickerView.dataSource = self;
        _pickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    return _pickerView;
}

- (void)updateContent:(BOOL)animated editing:(BOOL)editing height:(CGFloat)height offsetX:(CGFloat)offsetX offsetY:(CGFloat)offsetY duration:(CGFloat)duration {
    self.pickerView.frame = CGRectMake(offsetX + 20.0f,
                                       offsetY + self.offsetTitle,
                                       self.contentView.bounds.size.width - 2 * (offsetX + 20.0f),
                                       162.0f);
    [self setViews:@[self.pickerView] editing:editing animated:animated duration:duration];
    [self.pickerView reloadAllComponents];
    [self.pickerView setNeedsLayout];
    
}

- (void)setDefinition:(NSDictionary *)definition {
    [super setDefinition:definition];
    [self.pickerView reloadAllComponents];
}

- (NSString *)code {
    return self.definition[@"code"];
}

- (void)setValue:(id)value {
    if (!value || [value integerValue] == 0) {
        value = @(0);
    }
    super.value = value;
    NSString *codeText = [Codes textForCode:self.code value:[value integerValue]];
    if (self.editing || !self.label) {
        if (codeText.length > 0) {
            self.textLabel.textColor = [UIColor blackColor];
            self.textLabel.text = codeText;
        } else {
            self.textLabel.textColor = PLACEHOLDER_COLOR;
            self.textLabel.text = self.placeholder;
        }
    } else {
        self.textLabel.textColor = [UIColor blackColor];
        self.textLabel.text = self.text;
        self.detailTextLabel.text = codeText;
    }
    NSInteger row = 0;
    if (self.includeEmpty) {
        if (!value || [value integerValue] == 0) {
            [self.pickerView selectRow:0 inComponent:0 animated:YES];
            return;
        }
        row = [value integerValue];
    } else {
        row = [value integerValue] - 1;
    }
    if (row < 0) {
        row = 0;
    }
    [self.pickerView selectRow:row inComponent:0 animated:YES];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSInteger count = [Codes codeCount:self.code];
    count = self.includeEmpty ? count + 1 : count;
    return count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSInteger value = row + 1;
    if (self.includeEmpty) {
        if (row == 0) {
            return @"";
        }
        value--;
    }
    NSString *code = [Codes textForCode:self.code value:value];
    return code;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSInteger value = row + 1;
    if (self.includeEmpty) {
        if (row == 0) {
            [self setProperty:@"value" value:nil];
            return;
        }
        value--;
    }
    [self setProperty:@"value" value:@(value)];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
    return self.pickerView.frame.size.width;
}

- (void)setIncludeEmpty:(BOOL)includeEmpty {
    _includeEmpty = includeEmpty;
}

- (void)reset {
    [super reset];
    _includeEmpty = NO;
}

@end