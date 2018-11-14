//
//  PencilStyle.m
//  TeacherPlanner
//
//  Created by Klemenz, Oliver on 05.08.14.
//

#import "PencilStyle.h"

@implementation PencilStyle

- (instancetype)initWithColor:(UIColor *)color width:(CGFloat)width alpha:(CGFloat)alpha {
    self = [self init];
    if (self) {
        self.color = color;
        self.width = width;
        self.alpha = alpha;
    }
    return self;
}

- (UIColor *)colorWithAlpha {
    const CGFloat *components = CGColorGetComponents(self.color.CGColor);
    CGFloat red = components[0];
    CGFloat green = components[1];
    CGFloat blue = components[2];
    return [UIColor colorWithRed:red green:green blue:blue alpha:self.alpha];
}

- (id)copyWithZone:(NSZone *)zone {
    PencilStyle *pencilStyle = [PencilStyle new];
    [pencilStyle setup:YES];
    pencilStyle.color = self.color;
    pencilStyle.width = self.width;
    pencilStyle.alpha = self.alpha;
    return pencilStyle;
}

@end