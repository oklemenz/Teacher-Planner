//
//  PencilStyle.h
//  TeacherPlanner
//
//  Created by Klemenz, Oliver on 05.08.14.
//

#import "JSONChildEntity.h"

@protocol PencilStyle
@end

@interface PencilStyle : JSONChildEntity <NSCopying>

@property (nonatomic, strong) UIColor *color;
@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat alpha;

- (instancetype)initWithColor:(UIColor *)color width:(CGFloat)width alpha:(CGFloat)alpha;
- (UIColor *)colorWithAlpha;

@end