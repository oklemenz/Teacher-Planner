//
//  UIBarButtonItem+Extension.h
//  TeacherPlanner
//
//  Created by Oliver on 04.05.14.
//
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (Extension)

+ (UIBarButtonItem *)createCustomTintedTopBarButtonItem:(NSString *)imageName;
+ (UIBarButtonItem *)createCustomTintedBottomBarButtonItem:(NSString *)imageName;
+ (UIBarButtonItem *)createCustomTintedBarButtonItem:(NSString *)imageName color:(UIColor *)color disabledColor:(UIColor *)lightColor;

@end
