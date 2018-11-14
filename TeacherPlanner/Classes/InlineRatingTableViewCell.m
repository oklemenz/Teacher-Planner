//
//  InlineRatingTableViewCell.m
//  TeacherPlanner
//
//  Created by Oliver Klemenz on 13.12.14.
//
//

#import "InlineRatingTableViewCell.h"
#import "Configuration.h"
#import "Codes.h"

@interface InlineRatingTableViewCell ()
@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@end

@implementation InlineRatingTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (UISegmentedControl *)segmentedControl {
    if (!_segmentedControl) {
        NSArray *items = @[[Codes shortTextForCode:kCodeRating value:1],
                           [Codes shortTextForCode:kCodeRating value:2],
                           [Codes shortTextForCode:kCodeRating value:3],
                           [Codes shortTextForCode:kCodeRating value:4],
                           [Codes shortTextForCode:kCodeRating value:5]];
        _segmentedControl = [[UISegmentedControl alloc] initWithItems:items];
        _segmentedControl.selectedSegmentIndex = 2;
        [_segmentedControl addTarget:self action:@selector(segmentChanged:) forControlEvents:UIControlEventValueChanged];
        if ([Configuration instance].brandingActive && [Configuration instance].highlightColor) {
            _segmentedControl.tintColor = [Configuration instance].highlightColor;
        }
    }
    return _segmentedControl;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    NSString *text = [Codes textForCode:kCodeRating value:self.segmentedControl.selectedSegmentIndex + 1];
    if (editing || self.alwaysEditing) {
        self.editingAccessoryView = self.segmentedControl;
        self.segmentedControl.alpha = 0.0f;
        void (^changes)(void) = ^{
            self.segmentedControl.alpha = 1.0;
            self.detailTextLabel.alpha = 0.0;
        };
        if (animated) {
            [UIView animateWithDuration:0.25 animations:changes];
        } else {
            changes();
        }
    } else {
        void (^changes)(void) = ^{
            self.segmentedControl.alpha = 0.0;
            self.detailTextLabel.alpha = 1.0;
            self.textLabel.alpha = 1.0;
            self.detailTextLabel.text = text;
        };
        void (^completed)(BOOL finished) = ^(BOOL finished) {
            self.editingAccessoryView = nil;
        };
        if (animated) {
            [UIView animateWithDuration:0.25 animations:changes completion:completed];
        } else {
            changes();
            completed(YES);
        }
    }
    [super setEditing:editing animated:animated];
}

- (void)setValue:(id)value {
    if (!value) {
        value = @(2);
    }
    super.value = value;
    self.segmentedControl.selectedSegmentIndex = [value integerValue];
}

- (void)segmentChanged:(id)sender {
    [self setProperty:@"value" value:@(self.segmentedControl.selectedSegmentIndex)];
}

@end