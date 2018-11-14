//
//  InlineDatePickerTableViewCell.m
//  TeacherPlanner
//
//  Created by Oliver on 14.06.14.
//
//

#import "InlineDatePickerTableViewCell.h"
#import "Utilities.h"

@interface InlineDatePickerTableViewCell()
@property (nonatomic, strong) UIDatePicker *datePicker;
@end

@implementation InlineDatePickerTableViewCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (UIDatePicker *)datePicker {
    if (!_datePicker) {
        _datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, 200, 162)];
        _datePicker.datePickerMode = UIDatePickerModeDate;
        [_datePicker addTarget:self action:@selector(didChangeDate) forControlEvents:UIControlEventValueChanged];
        _datePicker.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    return _datePicker;
}

- (void)updateContent:(BOOL)animated editing:(BOOL)editing height:(CGFloat)height offsetX:(CGFloat)offsetX offsetY:(CGFloat)offsetY duration:(CGFloat)duration {
    self.datePicker.frame = CGRectMake(offsetX + 20.0f,
                                       offsetY + self.offsetTitle,
                                       self.contentView.bounds.size.width - 2 * (offsetX + 20.0f),
                                       162.0f);
    [self setViews:@[self.datePicker] editing:editing animated:YES duration:duration];
    [self.datePicker setNeedsLayout];
}

- (void)setValue:(id)value {
    super.value = value;
    NSDate *date = (NSDate *)value;
    if (date) {
        [self.datePicker setDate:date animated:YES];
        NSString *dateText = @"";
        switch (self.datePicker.datePickerMode) {
            case UIDatePickerModeDate:
            default:
                dateText = [NSString stringWithFormat:@"%@", [[Utilities dateFormatter] stringFromDate:(NSDate *)self.value]];
                break;
            case UIDatePickerModeDateAndTime:
                dateText = [NSString stringWithFormat:@"%@", [[Utilities dateTimeFormatter] stringFromDate:(NSDate *)self.value]];
                break;
            case UIDatePickerModeTime:
                dateText = [NSString stringWithFormat:@"%@", [[Utilities timeFormatter] stringFromDate:(NSDate *)self.value]];
                break;
        }
        self.textLabel.textColor = [UIColor blackColor];
        if (self.label) {
            self.detailTextLabel.text = dateText;
        } else {
            self.textLabel.text = dateText;
        }
    } else {
        self.textLabel.textColor = PLACEHOLDER_COLOR;
        if (self.label) {
            self.detailTextLabel.text = NSLocalizedString(@"Not specified", @"");
        } else {
            self.textLabel.text = self.placeholder;
        }
    }
}

- (void)didChangeDate {
    [self setProperty:@"value" value:self.datePicker.date];
}

- (void)setMode:(NSNumber *)mode {
    if (mode) {
        self.datePicker.datePickerMode = [mode integerValue];
    } else {
        self.datePicker.datePickerMode = UIDatePickerModeDate;
    }
}

- (void)reset {
    [super reset];
    self.mode = nil;
}

@end