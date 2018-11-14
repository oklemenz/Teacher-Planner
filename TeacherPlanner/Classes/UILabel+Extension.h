//
//  UILabel+Extension.h
//  TeacherPlanner
//
//  Created by Oliver on 05.10.14.
//
//

#import <UIKit/UIKit.h>

typedef enum SlideDirection : NSUInteger {
    SlideDirectionLeftToRight,
    SlideDirectionRightToLeft,
    SlideDirectionTopToBottom,
    SlideDirectionBottomToTop
} SlideDirection;

@interface UILabel (Extension)

+ (UILabel *)createTwoLineTitleLabel:(NSString *)title color:(UIColor *)color;
- (void)updateTwoLineTitleLabel:(NSString *)title color:(UIColor *)color;

+ (UILabel *)createSlideLabel:(NSString *)text frame:(CGRect)frame direction:(SlideDirection)direction;
- (void)slideWithText:(NSAttributedString *)text direction:(SlideDirection)direction duration:(CFTimeInterval)duration;
- (void)addSlideAnimation:(SlideDirection)direction duration:(CFTimeInterval)duration;

@end