//
//  UITabBarItem+Extension.h
//  TeacherPlanner
//
//  Created by Oliver on 04.05.14.
//
//

#import <UIKit/UIKit.h>

@interface UITabBarItem (Extension)

+ (UITabBarItem *)createCustomTintedBottomTabBarItem:(NSString *)title imageName:(NSString *)imageName
                                   selectedImageName:(NSString *)seletedImageName;
+ (UITabBarItem *)createCustomTintedTabBarItem:(NSString *)title imageName:(NSString *)imageName
                             selectedImageName:(NSString *)selectedImageName color:(UIColor *)color selectedColor:(UIColor *)selectedColor;

@end
