//
//  InlineSliderTableViewCell.m
//  TeacherPlanner
//
//  Created by Oliver Klemenz on 12.03.15.
//
//

#import "InlineSliderTableViewCell.h"


@interface InlineSliderTableViewCell ()
@property (nonatomic, strong) UISlider *slider;
@end

@implementation InlineSliderTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (UISlider *)slider {
    if (!_slider) {
        _slider = [[UISlider alloc] initWithFrame:CGRectZero];
        [_slider addTarget:self action:@selector(didChangeSlider:) forControlEvents:UIControlEventValueChanged];
    }
    return _slider;
}

- (void)updateContent:(BOOL)animated editing:(BOOL)editing height:(CGFloat)height offsetX:(CGFloat)offsetX offsetY:(CGFloat)offsetY duration:(CGFloat)duration {
    self.slider.frame = CGRectMake(offsetX,
                                   offsetY + self.offsetTitle,
                                   self.contentView.bounds.size.width - 2 * offsetX,
                                   height - 2 * offsetY - self.offsetTitle);
    [self setViews:@[self.slider] editing:editing animated:YES duration:duration];
}

- (void)setMinimumValue:(CGFloat)minimumValue {
    _minimumValue = minimumValue;
    self.slider.minimumValue = minimumValue;
}

- (void)setMaximumValue:(CGFloat)maximumValue {
    _maximumValue = maximumValue;
    self.slider.maximumValue = maximumValue;
}

- (void)setContinuous:(BOOL)continuous {
    _continuous = continuous;
    self.slider.continuous = continuous;
}

- (void)setValue:(id)value {
    if (!value) {
        value = @(0.0f);
    }
    super.value = value;
    self.slider.value = [value floatValue];
}

- (void)didChangeSlider:(UISlider *)slider {
    [self setProperty:@"value" value:@(slider.value)];
}

- (void)reset {
    [super reset];
    _continuous = NO;
}

@end