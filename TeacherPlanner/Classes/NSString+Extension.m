//
//  NSString+Extension.m
//  TeacherPlanner
//
//  Created by Oliver on 12.10.14.
//
//

#import "NSString+Extension.h"

@implementation NSString (Extension)

- (NSString *)capitalize {
    if (self.length > 0) {
        return [self stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[[self substringToIndex:1] uppercaseString]];
    }
    return self;
}

- (NSString *)uncapitalize {
    if (self.length > 0) {
        return [self stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[[self substringToIndex:1] lowercaseString]];
    }
    return self;
}

- (NSString *)validFilePath {
    NSString *path = [[self componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@""];
    path = [[path componentsSeparatedByCharactersInSet:[NSCharacterSet illegalCharacterSet]] componentsJoinedByString:@"" ];
    path = [[path componentsSeparatedByCharactersInSet:[NSCharacterSet symbolCharacterSet]] componentsJoinedByString:@"" ];
    path = [[path componentsSeparatedByString:@"/"] componentsJoinedByString:@"-" ];
    return path;
}

+ (NSString *)nilToEmpty:(id)value {
    return (!value || [value isEqual:[NSNull null]]) ? @"" : [NSString stringWithFormat:@"%@", value];
}

- (NSString *)truncateTailToWidth:(CGFloat)width font:(UIFont *)font lineBreakMode:(NSLineBreakMode)lineBreakMode {
    NSMutableString *result = [self mutableCopy];
    BOOL truncated = NO;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    while ([result sizeWithFont:font forWidth:FLT_MAX lineBreakMode:lineBreakMode].width > width) {
#pragma clang diagnostic pop
        NSRange range = {result.length-1, 1};
        [result deleteCharactersInRange:range];
        truncated = YES;
    }
    return truncated ? [NSString stringWithFormat:@"%@...", result] : result;
}

- (NSString *)truncateHeadToWidth:(CGFloat)width font:(UIFont *)font lineBreakMode:(NSLineBreakMode)lineBreakMode {
    NSMutableString *result = [self mutableCopy];
    BOOL truncated = NO;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    while ([result sizeWithFont:font forWidth:FLT_MAX lineBreakMode:lineBreakMode].width > width) {
#pragma clang diagnostic pop
        NSRange range = {0, 1};
        [result deleteCharactersInRange:range];
        truncated = YES;
    }
    return truncated ? [NSString stringWithFormat:@"...%@", result] : result;
}

@end