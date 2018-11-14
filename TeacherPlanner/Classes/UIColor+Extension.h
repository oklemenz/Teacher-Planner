//
//  UIColor+Extension.h
//  TeacherPlanner
//
//  Created by Oliver on 12.01.14.
//
//

#import <Foundation/Foundation.h>

@interface UIColor (Extension)

+ (UIColor *)colorWithHexString:(NSString *)hexString;
- (UIColor*)blendWithColor:(UIColor*)color alpha:(CGFloat)alpha;
- (NSString *)hexString;
- (UIColor *)lighterColor;
- (UIColor *)darkerColor;
- (BOOL)colorIsDark;

@end
