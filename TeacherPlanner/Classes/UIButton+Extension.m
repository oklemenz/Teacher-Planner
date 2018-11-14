//
//  UIButton+Extension.m
//  TeacherPlanner
//
//  Created by Oliver on 04.05.14.
//
//

#import "UIButton+Extension.h"
#import "Configuration.h"
#import "UIImage+Extension.h"

@implementation UIButton (Extension)

+ (UIButton *)createCustomButton:(NSString *)imageName {
    UIImage *image = [[UIImage imageNamed:imageName] tintImage:[Configuration instance].highlightColor];
    UIImage *imageLight = [[UIImage imageNamed:imageName] tintImage:[Configuration instance].lightHighlightColor];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button setBackgroundImage:imageLight forState:UIControlStateHighlighted];
    button.tintColor = [Configuration instance].highlightColor;
    button.backgroundColor = [UIColor clearColor];
    return button;
}

@end
