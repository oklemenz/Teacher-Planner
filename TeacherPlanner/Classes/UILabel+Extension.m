//
//  UILabel+Extension.m
//  TeacherPlanner
//
//  Created by Oliver on 05.10.14.
//
//

#import "UILabel+Extension.h"

@implementation UILabel (Extension)

+ (UILabel *)createTwoLineTitleLabel:(NSString *)title color:(UIColor *)color {
    UIFont *font = [UIFont systemFontOfSize:14.0f];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
    label.backgroundColor = [UIColor clearColor];
    label.numberOfLines = 2;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = color;
    label.font = font;
    [label updateTwoLineTitleLabel:title color:color];
    return label;
}

- (void)updateTwoLineTitleLabel:(NSString *)title color:(UIColor *)color {
    UIFont *font = [UIFont systemFontOfSize:14.0f];
    UIFont *boldFont = [UIFont boldSystemFontOfSize:15.0f];
    NSMutableAttributedString *attrTitle = [[NSMutableAttributedString alloc] initWithString:title];
    if (color) {
        [attrTitle addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, title.length)];
    }
    [attrTitle addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, title.length)];
    NSInteger firstLineLocation = [title rangeOfString:@"\n"].location;
    if (firstLineLocation != NSNotFound) {
        NSRange firstLineRange = NSMakeRange(0, firstLineLocation);
        [attrTitle addAttribute:NSFontAttributeName value:boldFont range:firstLineRange];
    } else {
        [attrTitle addAttribute:NSFontAttributeName value:boldFont range:NSMakeRange(0, title.length)];
    }
    self.attributedText = attrTitle;
}

+ (UILabel *)createSlideLabel:(NSString *)text frame:(CGRect)frame direction:(SlideDirection)direction {
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:25];
    switch (direction) {
        case SlideDirectionLeftToRight:
            label.textAlignment = NSTextAlignmentLeft;
            break;
        case SlideDirectionRightToLeft:
            label.textAlignment = NSTextAlignmentRight;
            break;
        default:
            label.textAlignment = NSTextAlignmentCenter;
            break;
    }
    NSMutableAttributedString *attrText = [[NSMutableAttributedString alloc] initWithString:text];
    if ([text rangeOfString:@">"].location == 0 || [text rangeOfString:@"^"].location == 0) {
        [attrText addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Light" size:35] range:NSMakeRange(0, 1)];
    }
    if ([text rangeOfString:@"<"].location == text.length-1) {
        [attrText addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Light" size:35] range:NSMakeRange(text.length-1, 1)];
    }
    [label slideWithText:attrText direction:direction duration:2.0f];
    return label;
}

- (void)slideWithText:(NSAttributedString *)text direction:(SlideDirection)direction duration:(CFTimeInterval)duration {
    if (text) {
        self.attributedText = text;
    }
    
    NSString *maskImage = @"";
    CGRect maskFrame;
    
    switch (direction) {
        case SlideDirectionLeftToRight:
            maskImage = @"mask_h";
            maskFrame = CGRectMake(-self.frame.size.width, 0.0, self.frame.size.width * 2, self.frame.size.height);
            break;
        case SlideDirectionRightToLeft:
            maskImage = @"mask_h";
            maskFrame = CGRectMake(0.0, 0.0, self.frame.size.width * 2, self.frame.size.height);
            break;
        case SlideDirectionTopToBottom:
            maskImage = @"mask_v";
            maskFrame = CGRectMake(0.0, -self.frame.size.height, self.frame.size.width, self.frame.size.height * 2);
            break;
        case SlideDirectionBottomToTop:
            maskImage = @"mask_v";
            maskFrame = CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height * 2);
            break;
        default:
            break;
    }
    
    CALayer *maskLayer = [CALayer layer];
    maskLayer.backgroundColor = [[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.15f] CGColor];
    maskLayer.contents = (id)[[UIImage imageNamed:maskImage] CGImage];
    maskLayer.contentsGravity = kCAGravityCenter;
    maskLayer.frame = maskFrame;
    self.layer.mask = maskLayer;
    
    [self addSlideAnimation:direction duration:duration];
}

- (void)addSlideAnimation:(SlideDirection)direction duration:(CFTimeInterval)duration {
    NSString *maskProperty = @"";
    CGFloat maskAnimByValue = 0.0;

    switch (direction) {
        case SlideDirectionLeftToRight:
            maskProperty = @"position.x";
            maskAnimByValue = self.frame.size.width;
            break;
        case SlideDirectionRightToLeft:
            maskProperty = @"position.x";
            maskAnimByValue = -self.frame.size.width;
            break;
        case SlideDirectionTopToBottom:
            maskProperty = @"position.y";
            maskAnimByValue = self.frame.size.height;
            break;
        case SlideDirectionBottomToTop:
            maskProperty = @"position.y";
            maskAnimByValue = -self.frame.size.height;
            break;
        default:
            break;
    }
    CABasicAnimation *maskAnim = [CABasicAnimation animationWithKeyPath:maskProperty];
    maskAnim.byValue = @(maskAnimByValue);
    maskAnim.repeatCount = FLT_MAX;
    maskAnim.duration = duration;
    [self.layer.mask addAnimation:maskAnim forKey:@"slideAnim"];
}

@end