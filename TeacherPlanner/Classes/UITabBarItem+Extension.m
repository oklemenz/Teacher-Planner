//
//  UITabBarItem+Extension.m
//  TeacherPlanner
//
//  Created by Oliver on 04.05.14.
//
//

#import "UITabBarItem+Extension.h"
#import "Configuration.h"
#import "UIImage+Extension.h"

@implementation UITabBarItem (Extension)

+ (UITabBarItem *)createCustomTintedBottomTabBarItem:(NSString *)title imageName:(NSString *)imageName
                                   selectedImageName:(NSString *)selectedImageName {
    return [UITabBarItem createCustomTintedTabBarItem:title imageName:imageName selectedImageName:selectedImageName color:[Configuration instance].disabledBottomButtonColor selectedColor:[Configuration instance].bottomButtonColor];
}

+ (UITabBarItem *)createCustomTintedTabBarItem:(NSString *)title imageName:(NSString *)imageName
                             selectedImageName:(NSString *)selectedImageName color:(UIColor *)color selectedColor:(UIColor *)selectedColor {
    UIImage *image = [UIImage imageNamed:imageName];
    UIImage *selectedImage = [UIImage imageNamed:selectedImageName ? selectedImageName : imageName];
    if ([Configuration instance].brandingActive) {
        image = [[image tintImage:color] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        selectedImage = [[selectedImage tintImage:selectedColor] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    UITabBarItem *tabBarItem = [[UITabBarItem alloc] initWithTitle:title image:image selectedImage:selectedImage];
    return tabBarItem;
}

@end
