//
//  UIImage+Extension.h
//  TeacherPlanner
//
//  Created by Oliver on 30.03.14.
//
//

#import <UIKit/UIKit.h>

@interface UIImage (Extension)

- (UIImage *)tintImage:(UIColor *)color;
- (UIImageView *)roundImageView;
- (UIImage *)roundImageClip;
- (UIImage *)squareImage;
- (UIImage *)resizeImage:(CGSize)size;
- (UIImage *)resizeImage:(CGSize)size scale:(CGFloat)scale;

- (UIImage *)tintImageWithColor:(UIColor *)tintColor;
- (UIImage *)scaledImage:(CGFloat)width;
- (UIImage *)blendImage:(UIImage *)blendImage alpha:(CGFloat)alpha;

@end
