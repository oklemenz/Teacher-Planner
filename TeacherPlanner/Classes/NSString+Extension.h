//
//  NSString+Extension.h
//  TeacherPlanner
//
//  Created by Oliver on 12.10.14.
//
//

@interface NSString (Extension)

- (NSString *)capitalize;
- (NSString *)uncapitalize;
- (NSString *)validFilePath;
+ (NSString *)nilToEmpty:(id)value;

- (NSString *)truncateTailToWidth:(CGFloat)width font:(UIFont *)font lineBreakMode:(NSLineBreakMode)lineBreakMode;
- (NSString *)truncateHeadToWidth:(CGFloat)width font:(UIFont *)font lineBreakMode:(NSLineBreakMode)lineBreakMode;

@end