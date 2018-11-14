//
//  ColorPicker.m
//  TeacherPlanner
//
//  Created by Klemenz, Oliver on 05.08.14.
//

#import "ColorPicker.h"
#import "UIImage+Extension.h"

#define kPickerViewGradientViewHeight        40
#define kPickerViewGradientTopMargin         20
#define kPickerViewDefaultMargin              5
#define kPickerViewBrightnessIndicatorWidth  16
#define kPickerViewBrightnessIndicatorHeight 48
#define kPickerViewCrossHairWidthAndHeight   40

#define kPickerViewTouchNone       0
#define kPickerViewTouchHueSat     1
#define kPickerViewTouchBrightness 2

@interface BrightnessView : UIView
@property (nonatomic, strong) UIColor *color;
@end

@interface ColorPicker() {
	CGFloat currentBrightness;
	CGFloat currentHue;
	CGFloat currentSaturation;
}

@property (nonatomic, strong) BrightnessView *gradientView;
@property (nonatomic, strong) UIImageView *brightnessIndicator;
@property (nonatomic, strong) UIImageView *hueSatImage;
@property (nonatomic, strong) UIView *crossHair;
@property (nonatomic) NSInteger touchPosition;

@end

@implementation ColorPicker

- (instancetype)initWithFrame:(CGRect)frame color:(UIColor *)color {
    self = [super initWithFrame:frame];
    if (self){
        self.color = color;
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    [self.crossHair setHidden:NO];
    [self.brightnessIndicator setHidden:NO];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.hueSatImage.frame = CGRectMake(kPickerViewDefaultMargin,
                                        kPickerViewDefaultMargin,
                                        CGRectGetWidth(self.frame) - (kPickerViewDefaultMargin * 2),
                                        CGRectGetHeight(self.frame) - kPickerViewGradientViewHeight - kPickerViewDefaultMargin - kPickerViewGradientTopMargin);
    self.gradientView.frame = CGRectMake(kPickerViewDefaultMargin,
                                         CGRectGetHeight(self.frame) - kPickerViewGradientViewHeight - kPickerViewDefaultMargin,
                                         CGRectGetWidth(self.frame) - (kPickerViewDefaultMargin * 2),
                                         kPickerViewGradientViewHeight);
    [self _updateBrightnessPosition];
    [self _updateCrosshairPosition];
}

- (void)setColor:(UIColor *)newColor {
    if (newColor && self.color != newColor) {
        CGFloat hue, saturation;
        [newColor getHue:&hue saturation:&saturation brightness:nil alpha:nil];

        currentHue = hue;
        currentSaturation = saturation;
        [self _setColor:newColor];
        [self _updateGradientColor];
        [self _updateBrightnessPosition];
        [self _updateCrosshairPosition];
    }
}

- (void)_setColor:(UIColor *)newColor {
    if (![_color isEqual:newColor]){
        CGFloat brightness;
        [newColor getHue:NULL saturation:NULL brightness:&brightness alpha:NULL];
        CGColorSpaceModel colorSpaceModel = CGColorSpaceGetModel(CGColorGetColorSpace(newColor.CGColor));
        if (colorSpaceModel == kCGColorSpaceModelMonochrome) {
            const CGFloat *c = CGColorGetComponents(newColor.CGColor);
            _color = [UIColor colorWithHue:0
                                saturation:0
                                brightness:c[0]
                                     alpha:1.0];
        } else {
            _color = [newColor copy];
        }
        [self.delegate didPickColor:self.color sender:self];
    }
}

- (void)_updateBrightnessPosition {
    [self.color getHue:nil saturation:nil brightness:&currentBrightness alpha:nil];
    CGPoint brightnessPosition;
    brightnessPosition.x = (1.0 - currentBrightness) * self.gradientView.frame.size.width + self.gradientView.frame.origin.x;
    brightnessPosition.y = self.gradientView.center.y;
    self.brightnessIndicator.center = brightnessPosition;
}

- (void)_updateCrosshairPosition {
    CGPoint hueSatPosition;
    hueSatPosition.x = (currentHue * self.hueSatImage.frame.size.width) + self.hueSatImage.frame.origin.x;
    hueSatPosition.y = (1.0 - currentSaturation) * self.hueSatImage.frame.size.height + self.hueSatImage.frame.origin.y;
    self.crossHair.center = hueSatPosition;
    [self _updateGradientColor];
}

- (void)_updateGradientColor {
    UIColor *gradientColor = [UIColor colorWithHue:currentHue
                                        saturation:currentSaturation
                                        brightness:1.0
                                             alpha:1.0];
    self.crossHair.layer.backgroundColor = gradientColor.CGColor;
	[self.gradientView setColor:gradientColor];
}

- (void)_updateHueSatWithMovement:(CGPoint)position {
	currentHue = (position.x - self.hueSatImage.frame.origin.x) / self.hueSatImage.frame.size.width;
	currentSaturation = 1.0 -  (position.y - self.hueSatImage.frame.origin.y) / self.hueSatImage.frame.size.height;
	UIColor *_tcolor = [UIColor colorWithHue:currentHue
                                  saturation:currentSaturation
                                  brightness:currentBrightness
                                       alpha:1.0];
    UIColor *gradientColor = [UIColor colorWithHue:currentHue
                                        saturation:currentSaturation
                                        brightness:1.0
                                             alpha:1.0];
    self.crossHair.layer.backgroundColor = gradientColor.CGColor;
    [self _updateGradientColor];
    [self _setColor:_tcolor];
}

- (void)_updateBrightnessWithMovement:(CGPoint)position {
	currentBrightness = 1.0 - ((position.x - self.gradientView.frame.origin.x)/self.gradientView.frame.size.width) ;
	UIColor *_tcolor = [UIColor colorWithHue:currentHue
                                  saturation:currentSaturation
                                  brightness:currentBrightness
                                       alpha:1.0];
    [self _setColor:_tcolor];
}

- (void)handleHueSatMove:(UIPanGestureRecognizer *)gesture {
    self.touchPosition = kPickerViewTouchHueSat;
    CGPoint point = [gesture locationInView:self.hueSatImage];
    if (gesture.state == UIGestureRecognizerStateBegan) {
        [self dispatchTouchEvent:point];
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        [self dispatchTouchEvent:point];
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        [self dispatchTouchEvent:point];
    }
}

- (void)handleBrightnessMove:(UIPanGestureRecognizer *)gesture {
    self.touchPosition = kPickerViewTouchBrightness;
    CGPoint point = [gesture locationInView:self.gradientView];
    if (gesture.state == UIGestureRecognizerStateBegan) {
        [self dispatchTouchEvent:point];
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        [self dispatchTouchEvent:point];
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        [self dispatchTouchEvent:point];
    }
}

/*- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    self.touchPosition = kPickerViewTouchNone;
    if (touches.count > 0) {
        UITouch *touch = [touches anyObject];
        CGPoint position = [touch locationInView:self];
        if (CGRectContainsPoint(self.hueSatImage.frame, position) || CGRectContainsPoint(self.crossHair.frame, position)){
            self.touchPosition = kPickerViewTouchHueSat;
        }
        else if (CGRectContainsPoint(self.gradientView.frame, position) || CGRectContainsPoint(self.brightnessIndicator.frame, position)) {
            self.touchPosition = kPickerViewTouchBrightness;
        }
        [self dispatchTouchEvent:position];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (touches.count > 0) {
        UITouch *touch = [touches anyObject];
        CGPoint position = [touch locationInView:self];
        [self dispatchTouchEvent:position];
    }
}*/

- (void)dispatchTouchEvent:(CGPoint)position {
	if (self.touchPosition == kPickerViewTouchHueSat){
        self.crossHair.center = CGPointMake(MIN(MAX(position.x, self.hueSatImage.frame.origin.x), self.hueSatImage.frame.size.width + self.hueSatImage.frame.origin.x),
                                            MIN(MAX(position.y, self.hueSatImage.frame.origin.y), self.hueSatImage.frame.size.height + self.hueSatImage.frame.origin.y));
		[self _updateHueSatWithMovement:position];
	} else if (self.touchPosition == kPickerViewTouchBrightness) {
        self.brightnessIndicator.center = CGPointMake(MIN(MAX(position.x, self.gradientView.frame.origin.x), self.gradientView.frame.size.width + self.gradientView.frame.origin.x),
                                            self.gradientView.center.y);
		[self _updateBrightnessWithMovement:position];
	}
}

- (BrightnessView *)gradientView {
    if (!_gradientView){
        _gradientView = [BrightnessView new];
        _gradientView.frame = CGRectMake(kPickerViewDefaultMargin,
                                         CGRectGetHeight(self.frame) - kPickerViewGradientViewHeight - kPickerViewDefaultMargin,
                                         CGRectGetWidth(self.frame) - (kPickerViewDefaultMargin * 2),
                                         kPickerViewGradientViewHeight);
        _gradientView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        _gradientView.layer.borderWidth = 1.0f;
        _gradientView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        _gradientView.layer.cornerRadius = 5.0;
        _gradientView.layer.masksToBounds = YES;
        [self addSubview:_gradientView];
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handleBrightnessMove:)];
        panGesture.minimumNumberOfTouches = 1;
        panGesture.maximumNumberOfTouches = 1;
        [_gradientView addGestureRecognizer:panGesture];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleBrightnessMove:)];
        [_gradientView addGestureRecognizer:tapGesture];
    }
    return _gradientView;
}

- (UIImageView *)hueSatImage {
    if (!_hueSatImage){
        _hueSatImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"colormap.png"]];
        _hueSatImage.frame = CGRectMake(kPickerViewDefaultMargin,
                                        kPickerViewDefaultMargin,
                                        CGRectGetWidth(self.frame) - (kPickerViewDefaultMargin * 2),
                                        CGRectGetHeight(self.frame) - kPickerViewGradientViewHeight - kPickerViewDefaultMargin - kPickerViewGradientTopMargin);
        _hueSatImage.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _hueSatImage.layer.borderWidth = 1.0f;
        _hueSatImage.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        _hueSatImage.layer.cornerRadius = 5.0;
        _hueSatImage.layer.masksToBounds = YES;
        _hueSatImage.userInteractionEnabled = YES;
        [self insertSubview:_hueSatImage aboveSubview:self.gradientView];
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handleHueSatMove:)];
        panGesture.minimumNumberOfTouches = 1;
        panGesture.maximumNumberOfTouches = 1;
        [_hueSatImage addGestureRecognizer:panGesture];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleHueSatMove:)];
        [_hueSatImage addGestureRecognizer:tapGesture];
    }
    return _hueSatImage;
}

- (UIView *)crossHair {
    if (!_crossHair){
        _crossHair = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) * 0.5,
                                                                     CGRectGetHeight(self.frame) * 0.5,
                                                                     kPickerViewCrossHairWidthAndHeight,
                                                                     kPickerViewCrossHairWidthAndHeight)];
        _crossHair.autoresizingMask = UIViewAutoresizingNone;
        UIColor *edgeColor = [UIColor colorWithWhite:0.9 alpha:0.8];
        _crossHair.layer.cornerRadius = kPickerViewCrossHairWidthAndHeight / 2.0f;
        _crossHair.layer.borderColor = edgeColor.CGColor;
        _crossHair.layer.borderWidth = 1;
        _crossHair.layer.shadowColor = [UIColor blackColor].CGColor;
        _crossHair.layer.shadowOffset = CGSizeZero;
        _crossHair.layer.shadowRadius = 1.0;
        _crossHair.layer.shadowOpacity = 0.5f;
        [self insertSubview:_crossHair aboveSubview:self.hueSatImage];
        [self addSubview:_gradientView];
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handleHueSatMove:)];
        panGesture.minimumNumberOfTouches = 1;
        panGesture.maximumNumberOfTouches = 1;
        [_crossHair addGestureRecognizer:panGesture];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleHueSatMove:)];
        [_crossHair addGestureRecognizer:tapGesture];
    }
    return _crossHair;
}

- (UIImageView *)brightnessIndicator {
    if (!_brightnessIndicator){
        _brightnessIndicator = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.gradientView.frame) * 0.5f,
                                                                                   CGRectGetMinY(self.gradientView.frame) - 4,
                                                                                   kPickerViewBrightnessIndicatorWidth,
                                                                                   kPickerViewBrightnessIndicatorHeight)];
        _brightnessIndicator.image = [[UIImage imageNamed:@"brightness_guide"] tintImageWithColor:[UIColor lightGrayColor]];
        _brightnessIndicator.backgroundColor = [UIColor clearColor];
        _brightnessIndicator.autoresizingMask = UIViewAutoresizingNone;
        [self insertSubview:_brightnessIndicator aboveSubview:self.gradientView];
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handleBrightnessMove:)];
        panGesture.minimumNumberOfTouches = 1;
        panGesture.maximumNumberOfTouches = 1;
        [_brightnessIndicator addGestureRecognizer:panGesture];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleBrightnessMove:)];
        [_brightnessIndicator addGestureRecognizer:tapGesture];
    }
    return _brightnessIndicator;
}

@end

@interface BrightnessView() {
    CGGradientRef gradient;
}
@end

@implementation BrightnessView

- (void)setColor:(UIColor*)color {
    if (_color != color){
        _color = [color copy];
        [self setupGradient];
        [self setNeedsDisplay];
    }
}

- (void)setupGradient {
	const CGFloat *c = CGColorGetComponents(self.color.CGColor);
	CGFloat colors[] = { c[0], c[1], c[2], 1.0f, 0.0f, 0.0f, 0.0f, 1.0f };
	CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
    if (gradient) {
        CGGradientRelease(gradient);
    }
	gradient = CGGradientCreateWithColorComponents(rgb, colors, NULL, sizeof(colors)/(sizeof(colors[0])*4));
	CGColorSpaceRelease(rgb);
}

- (void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGRect clippingRect = CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height);
	CGPoint endPoints[] = {
		CGPointMake(0,0),
		CGPointMake(self.frame.size.width,0),
	};
	CGContextSaveGState(context);
	CGContextClipToRect(context, clippingRect);
	CGContextDrawLinearGradient(context, gradient, endPoints[0], endPoints[1], 0);
	CGContextRestoreGState(context);
}

- (void)dealloc {
    CGGradientRelease(gradient);
}

@end