//
//  UIBarButtonItem+Extension.m
//  TeacherPlanner
//
//  Created by Oliver on 04.05.14.
//
//

#import "UIBarButtonItem+Extension.h"
#import "Configuration.h"
#import "UIImage+Extension.h"

@implementation UIBarButtonItem (Extension)

+ (UIBarButtonItem *)createCustomTintedTopBarButtonItem:(NSString *)imageName {
    return [UIBarButtonItem createCustomTintedBarButtonItem:imageName color:[Configuration instance].topButtonColor disabledColor:[Configuration instance].disabledTopButtonColor];
}

+ (UIBarButtonItem *)createCustomTintedBottomBarButtonItem:(NSString *)imageName {
    return [UIBarButtonItem createCustomTintedBarButtonItem:imageName color:[Configuration instance].bottomButtonColor disabledColor:[Configuration instance].disabledBottomButtonColor];
}

+ (UIBarButtonItem *)createCustomTintedBarButtonItem:(NSString *)imageName color:(UIColor *)color disabledColor:(UIColor *)disabledColor {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *image = [[UIImage imageNamed:imageName] tintImage:color];
    UIImage *imageDisabled = [[UIImage imageNamed:imageName] tintImage:disabledColor];
    button.bounds = CGRectMake(0, 0, image.size.width, image.size.height);
    [button setImage:image forState:UIControlStateNormal];
    [button setImage:imageDisabled forState:UIControlStateHighlighted];
    return [[UIBarButtonItem alloc] initWithCustomView:button];
}

@end