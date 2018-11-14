//
//  InlineTimeFromToTableViewCell.m
//  TeacherPlanner
//
//  Created by Oliver on 24.05.14.
//
//

#import "InlineTimeFromToTableViewCell.h"
#import "Utilities.h"

@interface InlineTimeFromToTableViewCell ()
@property (nonatomic, strong) UIDatePicker *startPickerView;
@property (nonatomic, strong) UIDatePicker *endPickerView;
@property (nonatomic, strong) UILabel *toLabel;
@end

@implementation InlineTimeFromToTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (UIDatePicker *)startPickerView {
    if (!_startPickerView) {
        _startPickerView = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, self.contentView.bounds.size.width / 2.0, 162)];
        _startPickerView.datePickerMode = UIDatePickerModeTime;
        _startPickerView.alpha = 0.0;
        _startPickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
        [_startPickerView addTarget:self action:@selector(didChangeStartDate) forControlEvents:UIControlEventValueChanged];
    }
    return _startPickerView;
}

- (UILabel *)toLabel {
    if (!_toLabel) {
        _toLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _toLabel.text = NSLocalizedString(@"to", @"");
        _toLabel.textAlignment = NSTextAlignmentCenter;
        _toLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        _toLabel.alpha = 0.0;
    }
    return _toLabel;
}

- (UIDatePicker *)endPickerView {
    if (!_endPickerView) {
        _endPickerView = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, self.contentView.bounds.size.width / 2.0, 162)];
        _endPickerView.datePickerMode = UIDatePickerModeTime;
        _endPickerView.alpha = 0.0;
        _endPickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;
        [_endPickerView addTarget:self action:@selector(didChangeEndDate) forControlEvents:UIControlEventValueChanged];
    }
    return _endPickerView;
}

- (void)setSelectedEditingActive:(BOOL)selectedEditingActive {
    [self setSelectedEditingActive:selectedEditingActive animated:NO];
}

- (void)setSelectedEditingActive:(BOOL)selectedEditingActive animated:(BOOL)animated {
    if (selectedEditingActive && !super.selectedEditingActive) {
        void (^changes)(void) = ^{
            self.startPickerView.alpha = 1.0;
            self.toLabel.alpha = 1.0;
            self.endPickerView.alpha = 1.0;
            self.textLabel.alpha = 0.0;
            CGFloat offsetY = [[self.definition valueForKeyPath:@"select.offsetY"] floatValue];
            self.startPickerView.frame = CGRectMake(0,
                                                    offsetY,
                                                    self.contentView.bounds.size.width / 2.0,
                                                    162);
            [self.contentView addSubview:self.startPickerView];
            self.toLabel.frame = CGRectMake(self.contentView.bounds.size.width / 2.0 - 20,
                                            162 / 2.0 - 20,
                                            40,
                                            40);
            [self.contentView addSubview:self.toLabel];
            self.endPickerView.frame = CGRectMake(self.contentView.bounds.size.width / 2.0,
                                                  offsetY,
                                                  self.contentView.bounds.size.width / 2.0,
                                                  162);
            [self.contentView addSubview:self.endPickerView];
        };
        if (animated) {
            [UIView animateWithDuration:0.25 animations:changes];
        } else {
            changes();
        }
    } else if (!selectedEditingActive) {
        void (^changes)(void) = ^{
            self.startPickerView.alpha = 0.0;
            self.toLabel.alpha = 0.0;
            self.endPickerView.alpha = 0.0;
            self.textLabel.alpha = 1.0;
        };
        if (animated) {
            [UIView animateWithDuration:0.25 animations:changes completion:^(BOOL finished) {
                [self.startPickerView removeFromSuperview];
                [self.toLabel removeFromSuperview];
                [self.endPickerView removeFromSuperview];
            }];
        } else {
            changes();
        }
    }
    [super setSelectedEditingActive:selectedEditingActive];
}

- (void)setDateText {
    self.textLabel.text = [NSString stringWithFormat:@"%tu. %@ %@ %@", self.row + 1,
                           [[Utilities timeFormatter] stringFromDate:(NSDate *)self.valueStart],
                           NSLocalizedString(@"to", @""),
                           [[Utilities timeFormatter] stringFromDate:(NSDate *)self.valueEnd]];
}

- (void)setValueStart:(NSDate *)valueStart {
    _valueStart = valueStart;
    if (valueStart) {
        [self.startPickerView setDate:valueStart animated:NO];
        [self setDateText];
    }
}

- (void)setValueEnd:(NSDate *)valueEnd {
    _valueEnd = valueEnd;
    if (valueEnd) {
        [self.endPickerView setDate:valueEnd animated:NO];
        [self setDateText];
    }
}

- (void)didChangeStartDate {
    [self setProperty:@"valueStart" value:self.startPickerView.date];
}

- (void)didChangeEndDate {
    [self setProperty:@"valueEnd" value:self.endPickerView.date];
}

- (void)reset {
    [super reset];
    self.valueStart = nil;
    self.valueEnd = nil;
}

@end