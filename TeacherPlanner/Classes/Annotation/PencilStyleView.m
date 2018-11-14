//
//  PencilStyleView.m
//  TeacherPlanner
//
//  Created by Klemenz, Oliver on 05.08.14.
//

#import "PencilStyleView.h"
#import "PencilStyle.h"
#import <QuartzCore/QuartzCore.h>

@implementation PencilStyleView

- (instancetype)initWithPencilStyle:(PencilStyle *)pencilStyle {
    self = [self initWithFrame:CGRectMake(0, 0, kPencilStyleMaxWidth, kPencilStyleMaxWidth)];
    if (self) {
        _pencilStyle = pencilStyle;
        self.backgroundColor = [UIColor clearColor];
        self.layer.contentsScale = [UIScreen mainScreen].scale;
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
        [self addGestureRecognizer:tap];
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPress:)];
        [self addGestureRecognizer:longPress];
        [self refresh];
    }
    return self;
}

- (void)didTap:(UITapGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        [self.delegate didSelectPencilStyle:self];
    }
}

- (void)didLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [self.delegate didMarkPencilStyle:self];
    }
}

- (void)refresh {
    self.alpha = self.pencilStyle.alpha;
    [self setNeedsDisplay];
}

- (void)setPencilStyle:(PencilStyle *)pencilStyle {
    _pencilStyle = pencilStyle;
    [self refresh];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextAddEllipseInRect(ctx, self.pencilStyleRect);
    CGContextSetFillColorWithColor(ctx, [self.pencilStyle.color CGColor]);
    CGContextFillPath(ctx);
}

- (UIImage *)image {
    UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, 0);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)icon {
    UIView *view = [[UIImageView alloc] initWithFrame:self.frame];
    view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"raster"]];
    UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, 0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    [self.image drawInRect:self.frame blendMode:kCGBlendModeNormal alpha:1.0];
    UIImage *icon = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return icon;
}

- (CGRect)pencilStyleRect {
    return CGRectMake((kPencilStyleMaxWidth - self.pencilStyle.width) / 2.0,
                      (kPencilStyleMaxWidth - self.pencilStyle.width) / 2.0,
                      self.pencilStyle.width,
                      self.pencilStyle.width);
}

- (void)position:(NSInteger)row column:(NSInteger)column offset:(CGPoint)offset {
    self.frame = CGRectMake(offset.x + column * kPencilStyleGrid + kPencilStyleBorder,
                            offset.y + row * kPencilStyleGrid + kPencilStyleBorder,
                            self.bounds.size.width,
                            self.bounds.size.height);
}

@end