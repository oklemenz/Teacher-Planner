//
//  JSONValueTransformer+UIColor.m
//  TeacherPlanner
//
//  Created by Oliver on 28.09.14.
//
//

#import "JSONValueTransformer+UIColor.h"
#import "UIColor+Extension.h"

@implementation JSONValueTransformer (UIColor)

- (UIColor *)UIColorFromNSString:(NSString *)string {
    return [UIColor colorWithHexString:string];
}

- (id)JSONObjectFromUIColor:(UIColor *)color {
    return [color hexString];
}

@end
