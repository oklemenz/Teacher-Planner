//
//  JSONValueTransformer+UIColor.h
//  TeacherPlanner
//
//  Created by Oliver on 28.09.14.
//
//
#import "JSONValueTransformer.h"

@interface JSONValueTransformer (UIColor)

- (UIColor *)UIColorFromNSString:(NSString*)string;
- (id)JSONObjectFromUIColor:(UIColor *)color;

@end
