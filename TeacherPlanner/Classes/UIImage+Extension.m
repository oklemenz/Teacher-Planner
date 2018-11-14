//
//  UIImage+Extension.m
//  TeacherPlanner
//
//  Created by Oliver on 30.03.14.
//
//

#import "UIImage+Extension.h"

@implementation UIImage (Tint)

- (UIImage *)tintImage:(UIColor *)color {
    if (color) {
        UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
        CGRect drawRect = CGRectMake(0, 0, self.size.width, self.size.height);
        [self drawInRect:drawRect];
        [color set];
        UIRectFillUsingBlendMode(drawRect, kCGBlendModeSourceAtop);
        UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return tintedImage;
    }
    return self;
}

- (UIImageView *)roundImageView {
    UIImageView *imageView = [[UIImageView alloc] initWithImage:self];
    imageView.frame = CGRectMake(0, 0, self.size.width, self.size.height);
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.layer.cornerRadius = self.size.width / 2.0f;
    imageView.layer.masksToBounds = YES;
    imageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    imageView.layer.borderWidth = 1.0f;
    return imageView;
}

- (UIImage *)roundImageClip {
    CGFloat size = self.size.width < self.size.height ? self.size.width : self.size.height;
    CGFloat posX = self.size.width < self.size.height ? 0 : -(self.size.width - self.size.height) / 2.0;
    CGFloat posY = self.size.width < self.size.height ? -(self.size.height - self.size.width) / 2.0 : 0;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(size, size), NO, 0.0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetAllowsAntialiasing(ctx, YES);
    [[UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, size, size)] addClip];
    [self drawInRect:CGRectMake(posX, posY, self.size.width, self.size.height)];
    UIImage *squareImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return squareImage;
}

- (UIImage *)squareImage {
    CGFloat size = self.size.width < self.size.height ? self.size.width : self.size.height;
    CGFloat posX = self.size.width < self.size.height ? 0 : -(self.size.width - self.size.height) / 2.0;
    CGFloat posY = self.size.width < self.size.height ? -(self.size.height - self.size.width) / 2.0 : 0;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(size, size), NO, 0.0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetAllowsAntialiasing(ctx, YES);
    [self drawInRect:CGRectMake(posX, posY, self.size.width, self.size.height)];
    UIImage *squareImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return squareImage;
}

- (UIImage *)resizeImage:(CGSize)size {
    return [self resizeImage:size scale:0.0];
}

- (UIImage *)resizeImage:(CGSize)size scale:(CGFloat)scale {
    UIGraphicsBeginImageContextWithOptions(size, NO, scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetAllowsAntialiasing(ctx, YES);
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)tintImageWithColor:(UIColor *)tintColor {
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextScaleCTM(context, 1, -1);
    CGContextTranslateCTM(context, 0, -rect.size.height);
    CGContextSaveGState(context);
    CGContextClipToMask(context, rect, self.CGImage);
    [tintColor set];
    CGContextFillRect(context, rect);
    CGContextRestoreGState(context);
    CGContextSetBlendMode(context, kCGBlendModeMultiply);
    CGContextDrawImage(context, rect, self.CGImage);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)scaledImage:(CGFloat)width {
    CGSize size = CGSizeMake(width, self.size.height * width / self.size.width);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

- (UIImage *)blendImage:(UIImage *)blendImage alpha:(CGFloat)alpha {
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0);
    [self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    [blendImage drawInRect:CGRectMake((self.size.width - blendImage.size.width) / 2.0,
                                      (self.size.height - blendImage.size.height) / 2.0,
                                      blendImage.size.width,
                                      blendImage.size.height) blendMode:kCGBlendModeNormal alpha:alpha];
    UIImage *blendedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return blendedImage;
}

@end