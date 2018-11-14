//
//  InlineColorPreviewTableViewCell.m
//  TeacherPlanner
//
//  Created by Oliver Klemenz on 12.03.15.
//
//

#import "InlineColorPreviewTableViewCell.h"
#import "PencilStyle.h"
#import "PencilStyleView.h"

@interface InlineColorPreviewTableViewCell()

@property (nonatomic, strong) UIView *pencilPreviewView;
@property (nonatomic, strong) PencilStyleView *pencilStyleView;
@property (nonatomic, strong) PencilStyle *pencilStyle;

@end

@implementation InlineColorPreviewTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (void)setColor:(UIColor *)color {
    _color = color;
    [self updateContent:NO];
}

- (void)setWidth:(CGFloat)width {
    _width = width;
    [self updateContent:NO];
}

- (void)setAlphaValue:(CGFloat)alphaValue {
    _alphaValue = alphaValue;
    [self updateContent:NO];
}

- (PencilStyle *)pencilStyle {
    if (!_pencilStyle) {
        _pencilStyle = [[PencilStyle alloc] initWithColor:self.color width:self.width alpha:self.alphaValue];
    }
    return _pencilStyle;
}

- (UIView *)pencilPreviewView {
    if (!_pencilPreviewView) {
        _pencilPreviewView = [[UIView alloc] initWithFrame:CGRectZero];
        _pencilPreviewView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"raster"]];
        _pencilPreviewView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        _pencilPreviewView.layer.borderWidth = 1.0;
        _pencilPreviewView.layer.cornerRadius = 10.0;
        _pencilPreviewView.layer.masksToBounds = YES;
        _pencilPreviewView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        [_pencilPreviewView addSubview:self.pencilStyleView];
        self.pencilStyleView.frame =
            CGRectMake((self.pencilPreviewView.frame.size.width - self.pencilStyleView.frame.size.width) / 2,
                       (self.pencilPreviewView.frame.size.height - self.pencilStyleView.frame.size.height) / 2,
                       self.pencilStyleView.frame.size.width,
                       self.pencilStyleView.frame.size.height);
    }
    return _pencilPreviewView;
}

- (PencilStyleView *)pencilStyleView {
    if (!_pencilStyleView) {
        _pencilStyleView = [[PencilStyleView alloc] initWithPencilStyle:self.pencilStyle];
        _pencilStyleView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
        UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        [self.pencilPreviewView addSubview:_pencilStyleView];
    }
    return _pencilStyleView;
}

- (void)updateContent:(BOOL)animated editing:(BOOL)editing height:(CGFloat)height offsetX:(CGFloat)offsetX offsetY:(CGFloat)offsetY duration:(CGFloat)duration {
    self.pencilStyle.color = self.color;
    self.pencilStyle.width = self.width;
    self.pencilStyle.alpha = self.alphaValue;
    CGFloat previewHeight = height - 2 * offsetY - self.offsetTitle;
    self.pencilPreviewView.frame = CGRectMake(offsetX + (self.bounds.size.width - previewHeight) / 2,
                                              offsetY + self.offsetTitle,
                                              previewHeight,
                                              previewHeight);
    [self.pencilStyleView refresh];
    [self setViews:@[self.pencilPreviewView] editing:editing animated:YES duration:duration];
}

- (void)reset {
    [super reset];
    _color = nil;
    _width = 0;
    _alphaValue = 0;
}

@end