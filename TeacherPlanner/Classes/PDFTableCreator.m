//
//  PDFTableCreator.m
//  TeacherPlanner
//
//  Created by Klemenz, Oliver on 27.05.14.
//  Copyright (c) 2014 Oliver Klemenz. All rights reserved.
//

#import "PDFTableCreator.h"
#import <CoreText/CoreText.h>
#import <math.h>

#define kPDFPageWidth        612
#define kPDFPageHeight       792

#define kPDFFontMin          10.0f
#define kPDFFontText         12.0f
#define kPDFFontHeader       20.0f
#define kPDFFontFooter       11.0f

#define kPDFPageBorder       50
#define kPDFImageBorder      5
#define kPDFCellPadding      0
#define kPDFTableBorderWidth 2

#define kPDFTableTextColor       [UIColor blackColor]
#define kPDFTableBorderColor     [UIColor blackColor]
#define kPDFTableFillColor       nil
#define kPDFTableHeaderFillColor [UIColor colorWithWhite:0.9 alpha:1.0f]

#define kPDFTableCellSpanNone   0
#define kPDFTableCellSpanRow    1
#define kPDFTableCellSpanColumn 2
#define kPDFTableCellSpanBoth   3

@interface PDFTableCreator();

@property(nonatomic) NSString *pdfFilePath;

@property(nonatomic) BOOL landscape;
@property(nonatomic) BOOL orientationSupport;
@property(nonatomic) BOOL optimalOrientation;
@property(nonatomic) BOOL supportCellSpan;

@property(nonatomic) NSInteger columns;
@property(nonatomic) NSInteger rows;

@property(nonatomic) NSString *headerText;
@property(nonatomic) NSString *horizontalAlignHeader;
@property(nonatomic) UIColor *headerTextColor;
@property(nonatomic) NSString *footerText;
@property(nonatomic) NSString *horizontalAlignFooter;
@property(nonatomic) UIColor *footerTextColor;
@property(nonatomic) NSString *footer2Text;
@property(nonatomic) NSString *horizontalAlignFooter2;
@property(nonatomic) UIColor *footer2TextColor;

@property(nonatomic) CGFloat cellRatio;
@property(nonatomic) CGFloat pageBorderX;
@property(nonatomic) CGFloat pageBorderY;
@property(nonatomic) CGFloat imageBorderX;
@property(nonatomic) CGFloat imageBorderY;
@property(nonatomic) CGFloat cellPaddingX;
@property(nonatomic) CGFloat cellPaddingY;
@property(nonatomic) CGFloat tableBorderWidth;
@property(nonatomic) CGFloat fontMin;

@property(nonatomic) CGPoint tableOffset;

@property(nonatomic) CGSize cellSize;
@property(nonatomic) CGSize tableSize;

@property(nonatomic) BOOL withTopHeaders;
@property(nonatomic) BOOL withLeftHeaders;

@property(nonatomic) UIColor *tableTextColor;
@property(nonatomic) UIColor *tableBorderColor;
@property(nonatomic) UIColor *tableFillColor;
@property(nonatomic) UIColor *tableTopHeaderFillColor;
@property(nonatomic) UIColor *tableLeftHeaderFillColor;

@property(nonatomic) NSString *tableBorderStyle;
@property(nonatomic) NSString *horizontalAlignText;
@property(nonatomic) NSString *verticalAlignText;
@property(nonatomic) NSString *horizontalAlignImage;
@property(nonatomic) NSString *verticalAlignImage;

@property(nonatomic) NSArray *topHeaders;
@property(nonatomic) NSArray *leftHeaders;
@property(nonatomic) NSArray *content;
@property(nonatomic) NSMutableArray *cellSpan;

@end

@implementation PDFTableCreator

- (instancetype)initWithSettings:(NSDictionary *)settings {
    self = [super init];
    if (self) {
        self.pdfFilePath = settings[kPDFTableCreatorFilePath];
        
        self.headerText = settings[kPDFTableCreatorHeader];
        self.headerTextColor = [UIColor blackColor];
        if (settings[kPDFTableCreatorHeaderTextColor]) {
            self.headerTextColor = (UIColor *)settings[kPDFTableCreatorHeaderTextColor];
        }
        self.horizontalAlignHeader = kPDFTableCreatorHorizontalAlignmentCenter;
        if (settings[kPDFTableCreatorHorizontalAlignmentHeader]) {
            self.horizontalAlignHeader = settings[kPDFTableCreatorHorizontalAlignmentHeader];
        }
        self.footerText = settings[kPDFTableCreatorFooter];
        self.footerTextColor = [UIColor blackColor];
        if (settings[kPDFTableCreatorFooterTextColor]) {
            self.footerTextColor = (UIColor *)settings[kPDFTableCreatorFooterTextColor];
        }
        self.horizontalAlignFooter = kPDFTableCreatorHorizontalAlignmentCenter;
        if (settings[kPDFTableCreatorHorizontalAlignmentFooter]) {
            self.horizontalAlignFooter = settings[kPDFTableCreatorHorizontalAlignmentFooter];
        }
        self.footer2Text = settings[kPDFTableCreatorFooter2];
        self.footer2TextColor = [UIColor blackColor];
        if (settings[kPDFTableCreatorFooter2TextColor]) {
            self.footer2TextColor = (UIColor *)settings[kPDFTableCreatorFooter2TextColor];
        }
        self.horizontalAlignFooter2 = kPDFTableCreatorHorizontalAlignmentCenter;
        if (settings[kPDFTableCreatorHorizontalAlignmentFooter]) {
            self.horizontalAlignFooter2 = settings[kPDFTableCreatorHorizontalAlignmentFooter2];
        }
        self.supportCellSpan = NO;
        if ([settings[kPDFTableCreatorSupportCellSpan] boolValue]) {
            self.supportCellSpan = YES;
        }
        
        self.pageBorderX = kPDFPageBorder;
        if (settings[kPDFTableCreatorPageBorderX]) {
            self.pageBorderX = [settings[kPDFTableCreatorPageBorderX] floatValue];
        }
        self.pageBorderY = kPDFPageBorder;
        if (settings[kPDFTableCreatorPageBorderY]) {
            self.pageBorderY = [settings[kPDFTableCreatorPageBorderY] floatValue];
        }
        self.imageBorderX = kPDFImageBorder;
        if (settings[kPDFTableCreatorImageBorderX]) {
            self.imageBorderX = [settings[kPDFTableCreatorImageBorderX] floatValue];
        }
        self.imageBorderY = kPDFImageBorder;
        if (settings[kPDFTableCreatorImageBorderY]) {
            self.imageBorderY = [settings[kPDFTableCreatorImageBorderY] floatValue];
        }
        self.cellPaddingX = kPDFCellPadding;
        if (settings[kPDFTableCreatorCellPaddingX]) {
            self.cellPaddingX = [settings[kPDFTableCreatorCellPaddingX] floatValue];
        }
        self.cellPaddingY = kPDFCellPadding;
        if (settings[kPDFTableCreatorCellPaddingY]) {
            self.cellPaddingY = [settings[kPDFTableCreatorCellPaddingY] floatValue];
        }
        self.fontMin = kPDFFontMin;
        if (settings[kPDFTableCreatorTableTextFontMin]) {
            self.fontMin = [settings[kPDFTableCreatorTableTextFontMin] floatValue];
        }
        self.tableTextColor = kPDFTableTextColor;
        if (settings[kPDFTableCreatorTableTextColor]) {
            self.tableTextColor = (UIColor *)settings[kPDFTableCreatorTableTextColor];
        }
        self.tableBorderStyle = kPDFTableCreatorTableBorderStyleSolid;
        if (settings[kPDFTableCreatorTableBorderStyle]) {
            self.tableBorderStyle = settings[kPDFTableCreatorTableBorderStyle];
        }
        self.tableBorderColor = kPDFTableBorderColor;
        if (settings[kPDFTableCreatorTableBorderColor]) {
            self.tableBorderColor = (UIColor *)settings[kPDFTableCreatorTableBorderColor];
        }
        self.tableFillColor = kPDFTableFillColor;
        if (settings[kPDFTableCreatorTableFillColor]) {
            self.tableFillColor = (UIColor *)settings[kPDFTableCreatorTableFillColor];
        }
        self.tableTopHeaderFillColor = kPDFTableHeaderFillColor;
        if (settings[kPDFTableCreatorTableTopHeaderFillColor]) {
            self.tableTopHeaderFillColor = (UIColor *)settings[kPDFTableCreatorTableTopHeaderFillColor];
        }
        self.tableLeftHeaderFillColor = kPDFTableHeaderFillColor;
        if (settings[kPDFTableCreatorTableLeftHeaderFillColor]) {
            self.tableLeftHeaderFillColor = (UIColor *)settings[kPDFTableCreatorTableLeftHeaderFillColor];
        }
        self.tableBorderWidth = kPDFTableBorderWidth;
        if (settings[kPDFTableCreatorTableBorderWidth]) {
            self.tableBorderWidth = [settings[kPDFTableCreatorTableBorderWidth] floatValue];
        }
        self.horizontalAlignText = kPDFTableCreatorHorizontalAlignmentCenter;
        if (settings[kPDFTableCreatorHorizontalAlignmentText]) {
            self.horizontalAlignText = settings[kPDFTableCreatorHorizontalAlignmentText];
        }
        self.verticalAlignText = kPDFTableCreatorVerticalAlignmentMiddle;
        if (settings[kPDFTableCreatorVerticalAlignmentText]) {
            self.verticalAlignText = settings[kPDFTableCreatorVerticalAlignmentText];
        }
        self.horizontalAlignImage = kPDFTableCreatorHorizontalAlignmentCenter;
        if (settings[kPDFTableCreatorHorizontalAlignmentImage]) {
            self.horizontalAlignImage = settings[kPDFTableCreatorHorizontalAlignmentImage];
        }
        self.verticalAlignImage = kPDFTableCreatorVerticalAlignmentMiddle;
        if (settings[kPDFTableCreatorVerticalAlignmentImage]) {
            self.verticalAlignImage = settings[kPDFTableCreatorVerticalAlignmentImage];
        }

        self.topHeaders = settings[kPDFTableCreatorTopHeaders];
        self.leftHeaders = settings[kPDFTableCreatorLeftHeaders];
        self.content = settings[kPDFTableCreatorContent];
        
        self.withTopHeaders = self.topHeaders != nil;
        self.withLeftHeaders = self.leftHeaders != nil;
        
        self.columns = [settings[kPDFTableCreatorColumns] integerValue];
        self.rows = [settings[kPDFTableCreatorRows] integerValue];
        
        self.landscape = NO;
        if (settings[kPDFTableCreatorDefaultOrientation] && UIDeviceOrientationIsLandscape([settings[kPDFTableCreatorDefaultOrientation] integerValue])) {
            self.landscape = YES;
        }
        self.optimalOrientation = NO;
        if ([settings[kPDFTableCreatorOptimalOrientation] boolValue]) {
            self.optimalOrientation = YES;
        }
        self.orientationSupport = NO;
        if ([settings[kPDFTableCreatorOrientationSupport] boolValue]) {
            self.orientationSupport = YES;
        }
        
        self.cellRatio = 0.0f;
        if (settings[kPDFTableCreatorCellRatio]) {
            self.cellRatio = [settings[kPDFTableCreatorCellRatio] floatValue];
        }
    }
    return self;
}

- (void)create {
    if (self.orientationSupport) {
        self.landscape = UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation]);
    }
    
    // Determine layouting
    self.cellSize = [self cellSize:self.columns rows:self.rows ratio:self.cellRatio];
    self.tableSize = [self tableSize:self.columns rows:self.rows ratio:self.cellRatio];
    self.tableOffset = [self tableOffset:self.columns rows:self.rows ratio:self.cellRatio];
    
    if (self.optimalOrientation) {
        if (self.tableSize.width > self.tableSize.height) {
            self.landscape = YES;
            self.cellSize = [self cellSize:self.columns rows:self.rows ratio:self.cellRatio];
            self.tableSize = [self tableSize:self.columns rows:self.rows ratio:self.cellRatio];
            self.tableOffset = [self tableOffset:self.columns rows:self.rows ratio:self.cellRatio];
        }
    }
    
    // Start PDF Rendering
    [self startPDF:self.pdfFilePath];
    [self newPDFPage];

    UIFont *headerFont = [UIFont boldSystemFontOfSize:kPDFFontHeader];
    UIFont *footerFont = [UIFont italicSystemFontOfSize:kPDFFontFooter];
    
    [self drawTableHeader:self.headerText font:headerFont color:self.headerTextColor horizontalAlign:self.horizontalAlignHeader];
    
    if (self.columns > 0 && self.rows > 0) {
        
        [self determineCellSpan:self.columns rows:self.rows content:self.content];
        
        //[self logCellSpan];
        
        [self drawTableBackground:self.columns rows:self.rows content:self.content];
        
        if (self.supportCellSpan) {
            [self drawTableSpan:self.columns rows:self.rows width:self.tableBorderWidth color:self.tableBorderColor fillColor:self.tableFillColor
                topHeaderFillColor:self.tableTopHeaderFillColor leftHeaderFillColor:self.tableLeftHeaderFillColor style:self.tableBorderStyle content:self.content];
        } else {
            [self drawTable:self.columns rows:self.rows width:self.tableBorderWidth color:self.tableBorderColor fillColor:self.tableFillColor
                topHeaderFillColor:self.tableTopHeaderFillColor leftHeaderFillColor:self.tableLeftHeaderFillColor style:self.tableBorderStyle];
        }
        
        CGFloat actualSize = kPDFFontText; //[UIFont systemFontSize];
        CGFloat actualMinSize = kPDFFontText; //[UIFont systemFontSize];
        UIFont *font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
        
        if (self.withTopHeaders) {
            for (NSString *header in self.topHeaders) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                [header sizeWithFont:[UIFont systemFontOfSize:actualSize] minFontSize:self.fontMin actualFontSize:&actualSize forWidth:self.cellSize.width - 20 lineBreakMode:NSLineBreakByWordWrapping];
#pragma clang diagnostic pop
                if (actualSize < actualMinSize) {
                    actualMinSize = actualSize;
                }
            }
            UIFont *font = [UIFont boldSystemFontOfSize:actualMinSize];
            [self drawTableTopHeaders:self.columns rows:self.rows headers:self.topHeaders font:font color:self.tableTextColor];
        }

        if (self.withLeftHeaders) {
            for (NSString *header in self.leftHeaders) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                [header sizeWithFont:[UIFont systemFontOfSize:actualSize] minFontSize:self.fontMin
                      actualFontSize:&actualSize forWidth:self.cellSize.width - 20
                       lineBreakMode:NSLineBreakByWordWrapping];
#pragma clang diagnostic pop
                if (actualSize < actualMinSize) {
                    actualMinSize = actualSize;
                }
            }
            font = [UIFont boldSystemFontOfSize:actualMinSize];
            [self drawTableLeftHeaders:self.columns rows:self.rows headers:self.leftHeaders font:font color:self.tableTextColor];
        }
        
        font = [UIFont systemFontOfSize:actualMinSize];

        CGRect imageRect = [self drawTableContentImage:self.columns rows:self.rows content:self.content
                    horizontalAlign:self.horizontalAlignImage
                      verticalAlign:self.verticalAlignImage];
        
        CGFloat maxTextHeight = 0;
        if (!CGRectIsEmpty(imageRect)) {
            maxTextHeight = MAX(self.cellSize.height - imageRect.size.height - 2 * self.imageBorderY - 2 * self.cellPaddingY, 0);
        }
       
        [self drawTableContentText:self.columns rows:self.rows content:self.content font:font color:self.tableTextColor
                   horizontalAlign:self.horizontalAlignText
                     verticalAlign:self.verticalAlignText
                         maxSize:CGSizeMake(0, maxTextHeight)];
     
        [self drawTableForeground:self.columns rows:self.rows content:self.content];
    }
    
    [self drawTableFooter:self.footerText font:footerFont color:self.footerTextColor horizontalAlign:self.horizontalAlignFooter];
    [self drawTableFooter:self.footer2Text font:footerFont color:self.footer2TextColor horizontalAlign:self.horizontalAlignFooter2];
    
    [self finishPDF];
}

- (void)startPDF:(NSString *)filename {
     UIGraphicsBeginPDFContextToFile(filename, CGRectZero, nil);
}

- (void)newPDFPage {
    CGRect pageRect = CGRectMake(0, 0, kPDFPageWidth, kPDFPageHeight);
    UIGraphicsBeginPDFPageWithInfo(pageRect, nil);
}

- (void)finishPDF {
    UIGraphicsEndPDFContext();
}

- (void)drawRect:(CGRect)rect width:(CGFloat)width dashed:(BOOL)dashed color:(UIColor *)color {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, width);
    CGContextSetLineDash(context, 0, NULL, 0);
    if (dashed) {
        CGFloat dash[] = { 5.0, 2.0 };
        CGContextSetLineDash(context, 0.0, dash, 2);
    }
    if (color) {
        CGContextSetStrokeColorWithColor(context, color.CGColor);
    }
    CGContextStrokeRect(context, rect);
}

- (void)drawFilledRect:(CGRect)rect fillColor:(UIColor *)fillColor {
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    if (fillColor) {
        CGContextSetFillColorWithColor(currentContext, fillColor.CGColor);
    }
    CGContextFillRect(currentContext, rect);
}

- (void)drawFilledCircle:(CGRect)rect fillColor:(UIColor *)fillColor {
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    if (fillColor) {
        CGContextSetFillColorWithColor(currentContext, fillColor.CGColor);
    }
    CGContextFillEllipseInRect(currentContext, rect);
}

- (void)drawLine:(CGPoint)from toPoint:(CGPoint)to width:(CGFloat)width dashed:(BOOL)dashed color:(UIColor *)color {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, width);
    CGContextSetLineDash(context, 0, NULL, 0);
    if (dashed) {
        CGFloat dash[] = { 5.0, 2.0 };
        CGContextSetLineDash(context, 0.0, dash, 2);
    }
    if (color) {
        CGContextSetStrokeColorWithColor(context, color.CGColor);
    }
    CGContextMoveToPoint(context, from.x, from.y);
    CGContextAddLineToPoint(context, to.x, to.y);
    CGContextStrokePath(context);
}

- (void)setDrawOrientation:(CGContextRef)currentContext rect:(CGRect)rect offset:(CGPoint)offset {
    [self setDrawOrientation:currentContext rect:rect offset:offset inCell:YES];
}

- (void)setDrawOrientation:(CGContextRef)currentContext rect:(CGRect)rect offset:(CGPoint)offset inCell:(BOOL)inCell {
    if (self.landscape) {
        CGContextSetTextMatrix(currentContext, CGAffineTransformIdentity);
        CGContextRotateCTM(currentContext, M_PI_2);
        CGContextTranslateCTM(currentContext,
                              kPDFPageHeight - rect.size.width - 2 * (self.pageBorderX + (inCell ? self.cellPaddingX : 0) + offset.x) - self.tableOffset.x - self.tableOffset.y,
                              0 - rect.size.height - 2 * (self.pageBorderY + (inCell ? self.cellPaddingY : 0) + offset.y) - self.tableOffset.x - self.tableOffset.y);
        CGContextTranslateCTM(currentContext, rect.size.width + 2 * rect.origin.x, 0);
        CGContextScaleCTM(currentContext, -1.0, 1.0);
    } else {
        CGContextSetTextMatrix(currentContext, CGAffineTransformIdentity);
        CGContextTranslateCTM(currentContext, 0, rect.size.height + 2 * rect.origin.y);
        CGContextScaleCTM(currentContext, 1.0, -1.0);
    }
}

- (void)drawOrientedText:(NSString *)text inRect:(CGRect)rect font:(UIFont *)font color:(UIColor *)color horizontalAlign:(NSString *)horizontalAlign verticalAlign:(NSString *)verticalAlign offset:(CGPoint)offset {
    [self drawOrientedText:text inRect:rect font:font color:color horizontalAlign:horizontalAlign verticalAlign:verticalAlign offset:offset inCell:YES];
}

- (void)drawOrientedText:(NSString *)text inRect:(CGRect)rect font:(UIFont *)font color:(UIColor *)color horizontalAlign:(NSString *)horizontalAlign verticalAlign:(NSString *)verticalAlign offset:(CGPoint)offset inCell:(BOOL)inCell {
    NSMutableDictionary *attributes = [@{} mutableCopy];
    CTFontRef fontRef = nil;
    if (font) {
        fontRef = CTFontCreateWithName((__bridge CFStringRef)font.fontName, font.pointSize, nil);
        attributes[(__bridge id)kCTFontAttributeName] = (__bridge id)fontRef;
    }
    if (color) {
        attributes[(__bridge id)kCTForegroundColorAttributeName] = (__bridge id)color.CGColor;
    }
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text attributes:attributes];
    [self drawOrientedAttributedText:attributedText inRect:rect horizontalAlign:horizontalAlign verticalAlign:verticalAlign offset:offset inCell:inCell];
    CFRelease(fontRef);
}

- (void)drawOrientedAttributedText:(NSAttributedString *)attributedText inRect:(CGRect)rect horizontalAlign:(NSString *)horizontalAlign verticalAlign:(NSString *)verticalAlign offset:(CGPoint)offset {
    [self drawOrientedAttributedText:attributedText inRect:rect horizontalAlign:horizontalAlign verticalAlign:verticalAlign offset:offset inCell:YES];
}

- (void)drawOrientedAttributedText:(NSAttributedString *)attributedText inRect:(CGRect)rect horizontalAlign:(NSString *)horizontalAlign verticalAlign:(NSString *)verticalAlign offset:(CGPoint)offset inCell:(BOOL)inCell {
    // Horizontal Alignment
    CTTextAlignment alignment = kCTLeftTextAlignment;
    if ([horizontalAlign isEqualToString:kPDFTableCreatorHorizontalAlignmentCenter]) {
        alignment = kCTCenterTextAlignment;
    } else if ([horizontalAlign isEqualToString:kPDFTableCreatorHorizontalAlignmentRight]) {
        alignment = kCTRightTextAlignment;
    }
    CTParagraphStyleSetting alignmentSetting;
    alignmentSetting.spec = kCTParagraphStyleSpecifierAlignment;
    alignmentSetting.valueSize = sizeof(CTTextAlignment);
    alignmentSetting.value = &alignment;

    attributedText = [attributedText mutableCopy];
    CTFontRef fontRef = (__bridge CTFontRef)[attributedText attribute:(__bridge NSString*)kCTFontAttributeName atIndex:0 effectiveRange:nil];
    CGFloat lineHeight = CTFontGetSize(fontRef) + 4.0f;
    CTParagraphStyleSetting settings[2] = {alignmentSetting, {kCTParagraphStyleSpecifierMaximumLineHeight, sizeof(CGFloat), &lineHeight} };
    CTParagraphStyleRef paragraphRef = CTParagraphStyleCreate(settings, 2);
    [(NSMutableAttributedString *)attributedText addAttribute:(__bridge id)kCTParagraphStyleAttributeName value:(__bridge id)paragraphRef range:(NSRange){0,[attributedText length]}];
    
    NSDictionary *attributes = [attributedText attributesAtIndex:0 effectiveRange:nil];
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attributedText);
    
    // Vertical Alignment
    CGFloat biasY = 0;
    CGFloat factor = self.landscape ? -1 : 1;
    if ([verticalAlign isEqualToString:kPDFTableCreatorVerticalAlignmentMiddle]) {
        CGSize suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, attributedText.length),
                                                                            (__bridge CFDictionaryRef)attributes,
                                                                            CGSizeMake(rect.size.width, CGFLOAT_MAX), NULL);
        biasY = (rect.size.height - suggestedSize.height) / 2.0f;
    } else if ([verticalAlign isEqualToString:kPDFTableCreatorVerticalAlignmentBottom]) {
        CGSize suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, attributedText.length),
                                                                            (__bridge CFDictionaryRef)attributes,
                                                                            CGSizeMake(rect.size.width, CGFLOAT_MAX), NULL);
        biasY = rect.size.height - suggestedSize.height;
    }
    
    if (biasY > 0) {
        rect = CGRectMake(rect.origin.x, rect.origin.y + factor * biasY, rect.size.width, rect.size.height);
    }
    
    CGMutablePathRef framePath = CGPathCreateMutable();
    CGPathAddRect(framePath, NULL, rect);
    CFRange currentRange = CFRangeMake(0, 0);
    CTFrameRef frameRef = CTFramesetterCreateFrame(framesetter, currentRange, framePath, NULL);
    CGPathRelease(framePath);

    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextSaveGState(currentContext);
    [self setDrawOrientation:currentContext rect:rect offset:offset inCell:inCell];
    CTFrameDraw(frameRef, currentContext);
    CGContextRestoreGState(currentContext);

    CFRelease(paragraphRef);
    CFRelease(frameRef);
    CFRelease(framesetter);
}

- (void)drawOrientedFilledCircle:(CGRect)rect fillColor:(UIColor *)fillColor offset:(CGPoint)offset {
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextSaveGState(currentContext);
    if (fillColor) {
        CGContextSetFillColorWithColor(currentContext, fillColor.CGColor);
    }
    [self setDrawOrientation:currentContext rect:rect offset:offset];
    CGContextFillEllipseInRect(currentContext, rect);
    CGContextRestoreGState(currentContext);
}

- (void)drawOrientedFilledRect:(CGRect)rect fillColor:(UIColor *)fillColor offset:(CGPoint)offset {
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextSaveGState(currentContext);
    if (fillColor) {
        CGContextSetFillColorWithColor(currentContext, fillColor.CGColor);
    }
    [self setDrawOrientation:currentContext rect:rect offset:offset];
    CGContextFillRect(currentContext, rect);
    CGContextRestoreGState(currentContext);
}

- (void)drawOrientedImage:(UIImage *)image inRect:(CGRect)rect horizontalAlign:(NSString *)horizontalAlign verticalAlign:(NSString *)verticalAlign {
    CGPoint offset = CGPointZero;
    rect = [self positionRect:rect size:image.size horizontalAlign:horizontalAlign verticalAlign:verticalAlign offset:&offset];
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextSaveGState(currentContext);
    offset = CGPointMake(self.imageBorderX + offset.x, self.imageBorderY + offset.y);
    [self setDrawOrientation:currentContext rect:rect offset:offset];
    CGContextDrawImage(currentContext, rect, image.CGImage);
    CGContextRestoreGState(currentContext);
}

- (void)drawOrientedIcon:(UIImage *)iconImage inRect:(CGRect)rect horizontalAlign:(NSString *)horizontalAlign verticalAlign:(NSString *)verticalAlign offset:(CGPoint)offset {
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextSaveGState(currentContext);
    [self setDrawOrientation:currentContext rect:rect offset:offset];
    CGContextDrawImage(currentContext, rect, iconImage.CGImage);
    CGContextRestoreGState(currentContext);
}

- (CGRect)positionRect:(CGRect)rect size:(CGSize)size horizontalAlign:(NSString *)horizontalAlign verticalAlign:(NSString *)verticalAlign offset:(CGPoint *)offset {
    CGSize contentRect = CGSizeMake(rect.size.width - 2 * self.imageBorderX, rect.size.height - 2 * self.imageBorderY);
    CGFloat ratio = fmin(contentRect.width / size.width, contentRect.height / size.height);
    rect = CGRectMake(rect.origin.x + self.imageBorderX, rect.origin.y + self.imageBorderY, size.width * ratio, size.height * ratio);
    
    // Horizontal Alignment
    CGFloat offsetX = 0;
    CGFloat offsetY = 0;
    
    if ([horizontalAlign isEqualToString:kPDFTableCreatorHorizontalAlignmentCenter]) {
        offsetX = (contentRect.width - rect.size.width) / 2.0;
    } else if ([horizontalAlign isEqualToString:kPDFTableCreatorHorizontalAlignmentRight]) {
        offsetX = (contentRect.width - rect.size.width);
    }
    
    // Vertical Alignment
    if ([verticalAlign isEqualToString:kPDFTableCreatorVerticalAlignmentMiddle]) {
        offsetY = (contentRect.height - rect.size.height) / 2.0;
    } else if ([verticalAlign isEqualToString:kPDFTableCreatorVerticalAlignmentBottom]) {
        offsetY = contentRect.height - rect.size.height;
    }
    if (offset) {
        offset->x = offsetX;
        offset->y = offsetY;
    }
    return CGRectMake(rect.origin.x + offsetX, rect.origin.y + offsetY, rect.size.width, rect.size.height);
}

- (CGSize)cellSize:(NSInteger)columns rows:(NSInteger)rows ratio:(CGFloat)ratio {
    CGFloat cellWidth;
    CGFloat cellHeight;
    if (self.landscape) {
        cellWidth = 1.0 * (kPDFPageHeight - 2 * self.pageBorderX) / columns;
        cellHeight = 1.0 * (kPDFPageWidth - 2 * self.pageBorderY) / rows;
    } else {
        cellWidth = 1.0 * (kPDFPageWidth - 2 * self.pageBorderX) / columns;
        cellHeight = 1.0 * (kPDFPageHeight - 2 * self.pageBorderY) / rows;
    }
    if (ratio > 0) {
        if (cellWidth * ratio < cellHeight) {
            cellHeight = cellWidth * ratio;
        } else {
            cellWidth = cellHeight / ratio;
        }
    }
    return CGSizeMake(cellWidth, cellHeight);
}

- (CGSize)tableSize:(NSInteger)columns rows:(NSInteger)rows ratio:(CGFloat)ratio {
    if (rows > 0 && columns > 0) {
        return CGSizeMake(columns * self.cellSize.width, rows * self.cellSize.height);
    } else {
        CGFloat cellWidth;
        CGFloat cellHeight;
        if (self.landscape) {
            cellWidth = 1.0 * (kPDFPageHeight - 2 * self.pageBorderX);
            cellHeight = 1.0 * (kPDFPageWidth - 2 * self.pageBorderY);
        } else {
            cellWidth = 1.0 * (kPDFPageWidth - 2 * self.pageBorderX);
            cellHeight = 1.0 * (kPDFPageHeight - 2 * self.pageBorderY);
        }
        return CGSizeMake(cellWidth, cellHeight);
    }
}

- (CGPoint)tableOffset:(NSInteger)columns rows:(NSInteger)rows ratio:(CGFloat)ratio {
    CGFloat tableOffsetX = 0;
    CGFloat tableOffsetY = 0;
    CGFloat cellWidth;
    CGFloat cellHeight;
    if (rows > 0 && columns > 0) {
        if (self.landscape) {
            cellWidth = 1.0 * (kPDFPageHeight - 2 * self.pageBorderX) / columns;
            cellHeight = 1.0 * (kPDFPageWidth - 2 * self.pageBorderY) / rows;
        } else {
            cellWidth = 1.0 * (kPDFPageWidth - 2 * self.pageBorderX) / columns;
            cellHeight = 1.0 * (kPDFPageHeight - 2 * self.pageBorderY) / rows;
        }
        if (ratio > 0) {
            if (cellWidth * ratio < cellHeight) {
                if (self.landscape) {
                    tableOffsetX = rows * (cellHeight - cellWidth * ratio) / 2.0;
                } else {
                    tableOffsetY = rows * (cellHeight - cellWidth * ratio) / 2.0;
                }
                cellHeight = cellWidth * ratio;
            } else {
                if (self.landscape) {
                    tableOffsetY = columns * (cellWidth - cellHeight / ratio) / 2.0;
                } else {
                    tableOffsetX = columns * (cellWidth - cellHeight / ratio) / 2.0;
                }
                cellWidth = cellHeight / ratio;
            }
        }
    }
    return CGPointMake(tableOffsetX, tableOffsetY);
}

- (CGRect)cellRect:(NSInteger)x y:(NSInteger)y {
    return [self cellRect:x spanX:1 y:y spanY:1];
}

- (CGRect)cellRect:(NSInteger)x spanX:(NSInteger)spanX y:(NSInteger)y spanY:(NSInteger)spanY {
    CGFloat factor = self.landscape ? -1 : 1;
    spanX = x + spanX < self.columns ? spanX : self.columns - x;
    if (spanX < 1) {
        spanX = 1;
    }
    spanY = y + spanY < self.rows ? spanY : self.rows - y;
    if (spanY < 1) {
        spanY = 1;
    }
    return CGRectMake(self.pageBorderX + self.tableOffset.x + self.cellPaddingX + factor * x * self.cellSize.width,
                      self.pageBorderY + self.tableOffset.y + self.cellPaddingY + factor * y * self.cellSize.height,
                      self.cellSize.width * spanX - 2 * self.cellPaddingX,
                      self.cellSize.height * spanY - 2 * self.cellPaddingY);
}

- (CGRect)headerRect {
    CGFloat factor = self.landscape ? -1 : 1;
    CGFloat tableOffset = self.landscape ? self.tableOffset.x : self.tableOffset.y;
    CGFloat tableOffsetY = self.landscape ? self.tableOffset.y + self.tableOffset.x : 0;
    return CGRectMake(self.pageBorderX + self.tableOffset.x,
                      self.pageBorderY - factor * (self.pageBorderY + tableOffsetY),
                      self.tableSize.width,
                      self.pageBorderY + tableOffset);
}

- (CGRect)footerRect {
    CGFloat factor = self.landscape ? -1 : 1;
    CGFloat tableOffset = self.landscape ? self.tableOffset.x : self.tableOffset.y;
    CGFloat tableOffsetY = self.landscape ? self.tableOffset.y + self.tableOffset.x : 0;
    return CGRectMake(self.pageBorderX + self.tableOffset.x,
                      self.pageBorderY + factor * (self.tableSize.height + tableOffset - tableOffsetY),
                      self.tableSize.width,
                      self.pageBorderY + tableOffset);
}

- (void)drawTableBase:(NSInteger)columns rows:(NSInteger)rows width:(CGFloat)width color:(UIColor *)color fillColor:(UIColor *)fillColor topHeaderFillColor:(UIColor *)topHeaderFillColor leftHeaderFillColor:(UIColor *)leftHeaderFillColor style:(NSString *)borderStyle {
    BOOL dashed = NO;
    if ([borderStyle isEqualToString:kPDFTableCreatorTableBorderStyleDashed]) {
        dashed = YES;
    }
    if (self.landscape) {
        if (fillColor) {
            [self drawFilledRect:CGRectMake(self.pageBorderY + self.tableOffset.x, self.pageBorderX + self.tableOffset.y,
                                            rows * self.cellSize.height, columns * self.cellSize.width) fillColor:fillColor];
        }
        if (self.withTopHeaders) {
            [self drawFilledRect:CGRectMake(self.pageBorderY + self.tableOffset.x, self.pageBorderX + self.tableOffset.y,
                                            self.cellSize.height, columns * self.cellSize.width) fillColor:topHeaderFillColor];
        }
        if (self.withLeftHeaders) {
            [self drawFilledRect:CGRectMake(self.pageBorderY + self.tableOffset.x + self.cellSize.height, self.pageBorderX + self.tableOffset.y + (columns-1) * self.cellSize.width,
                                            (rows-1) * self.cellSize.height, self.cellSize.width) fillColor:leftHeaderFillColor];
        }
        [self drawRect:CGRectMake(self.pageBorderY + self.tableOffset.x, self.pageBorderX + self.tableOffset.y,
                                  rows * self.cellSize.height, columns * self.cellSize.width) width:width dashed:dashed color:color];
    } else {
        if (fillColor) {
            [self drawFilledRect:CGRectMake(self.pageBorderX + self.tableOffset.x, self.pageBorderY + self.tableOffset.y,
                                            columns * self.cellSize.width, rows * self.cellSize.height) fillColor:fillColor];
        }
        if (self.withTopHeaders) {
            [self drawFilledRect:CGRectMake(self.pageBorderX + self.tableOffset.x, self.pageBorderY + self.tableOffset.y,
                                            columns * self.cellSize.width, self.cellSize.height) fillColor:topHeaderFillColor];
        }
        if (self.withLeftHeaders) {
            [self drawFilledRect:CGRectMake(self.pageBorderX + self.tableOffset.x, self.pageBorderY + self.tableOffset.y + self.cellSize.height,
                                            self.cellSize.width, (rows-1) * self.cellSize.height) fillColor:leftHeaderFillColor];
        }
        [self drawRect:CGRectMake(self.pageBorderX + self.tableOffset.x, self.pageBorderY + self.tableOffset.y,
                                  columns * self.cellSize.width, rows * self.cellSize.height) width:width dashed:dashed color:color];
    }
}
    
- (void)drawTable:(NSInteger)columns rows:(NSInteger)rows width:(CGFloat)width color:(UIColor *)color fillColor:(UIColor *)fillColor topHeaderFillColor:(UIColor *)topHeaderFillColor leftHeaderFillColor:(UIColor *)leftHeaderFillColor style:(NSString *)borderStyle {
    [self drawTableBase:columns rows:rows width:width color:color fillColor:fillColor topHeaderFillColor:topHeaderFillColor leftHeaderFillColor:leftHeaderFillColor style:borderStyle];
    BOOL dashed = NO;
    if ([borderStyle isEqualToString:kPDFTableCreatorTableBorderStyleDashed]) {
        dashed = YES;
    }
    if (self.landscape) {
        for (NSInteger i = 1; i <= columns - 1; i++) {
            CGPoint start = CGPointMake(self.pageBorderY + self.tableOffset.x, self.pageBorderX + self.tableOffset.y + i * self.cellSize.width);
            CGPoint end = CGPointMake(self.pageBorderY + self.tableOffset.x + rows * self.cellSize.height, self.pageBorderX + self.tableOffset.y + i * self.cellSize.width);
            [self drawLine:start toPoint:end width:width dashed:dashed color:color];
        }
        for (NSInteger j = 1; j <= rows - 1; j++) {
            CGPoint start = CGPointMake(self.pageBorderY + self.tableOffset.x + j * self.cellSize.height, self.pageBorderX + self.tableOffset.y);
            CGPoint end = CGPointMake(self.pageBorderY + self.tableOffset.x + j * self.cellSize.height, self.pageBorderX + self.tableOffset.y + columns * self.cellSize.width);
            [self drawLine:start toPoint:end width:width dashed:dashed color:color];
        }
    } else {
        for (NSInteger i = 1; i <= columns - 1; i++) {
            CGPoint start = CGPointMake(self.pageBorderX + self.tableOffset.x + i * self.cellSize.width, self.pageBorderY + self.tableOffset.y);
            CGPoint end = CGPointMake(self.pageBorderX + self.tableOffset.x + i * self.cellSize.width, self.pageBorderY + self.tableOffset.y + rows * self.cellSize.height);
            [self drawLine:start toPoint:end width:width dashed:dashed color:color];
        }
        for (NSInteger j = 1; j <= rows - 1; j++) {
            CGPoint start = CGPointMake(self.pageBorderX + self.tableOffset.x, self.pageBorderY + self.tableOffset.y + j * self.cellSize.height);
            CGPoint end = CGPointMake(self.pageBorderX + self.tableOffset.x + columns * self.cellSize.width, self.pageBorderY + self.tableOffset.y + j * self.cellSize.height);
            [self drawLine:start toPoint:end width:width dashed:dashed color:color];
        }
    }
}

- (void)drawTableSpan:(NSInteger)columns rows:(NSInteger)rows width:(CGFloat)width color:(UIColor *)color fillColor:(UIColor *)fillColor topHeaderFillColor:(UIColor *)topHeaderFillColor leftHeaderFillColor:(UIColor *)leftHeaderFillColor style:(NSString *)borderStyle content:(NSArray *)content {
    [self drawTableBase:columns rows:rows width:width color:color fillColor:fillColor topHeaderFillColor:topHeaderFillColor leftHeaderFillColor:leftHeaderFillColor style:borderStyle];
    BOOL dashed = NO;
    if ([borderStyle isEqualToString:kPDFTableCreatorTableBorderStyleDashed]) {
        dashed = YES;
    }
    if (self.landscape) {
        [self drawSpanCellGrid:columns rows:rows rowBased:NO content:content handler:^(NSInteger column, NSInteger row, BOOL cellSpan, NSInteger last) {
            if (cellSpan) {
                CGPoint start = CGPointMake(self.pageBorderY + self.tableOffset.x + last * self.cellSize.height, self.pageBorderX + self.tableOffset.y + (columns - column) * self.cellSize.width);
                CGPoint end = CGPointMake(self.pageBorderY + self.tableOffset.x + row * self.cellSize.height, self.pageBorderX + self.tableOffset.y + (columns - column) * self.cellSize.width);
                [self drawLine:start toPoint:end width:width dashed:dashed color:color];
            }
        }];
        [self drawSpanCellGrid:columns rows:rows rowBased:YES content:content handler:^(NSInteger column, NSInteger row, BOOL cellSpan, NSInteger last) {
            if (cellSpan) {
                CGPoint start = CGPointMake(self.pageBorderY + self.tableOffset.x + row * self.cellSize.height, self.pageBorderX + self.tableOffset.y + (columns - last) * self.cellSize.width);
                CGPoint end = CGPointMake(self.pageBorderY + self.tableOffset.x + row * self.cellSize.height, self.pageBorderX + self.tableOffset.y + (columns - column) * self.cellSize.width);
                [self drawLine:start toPoint:end width:width dashed:dashed color:color];
            }
        }];
    } else {
        [self drawSpanCellGrid:columns rows:rows rowBased:NO content:content handler:^(NSInteger column, NSInteger row, BOOL cellSpan, NSInteger last) {
            if (cellSpan) {
                CGPoint start = CGPointMake(self.pageBorderX + self.tableOffset.x + column * self.cellSize.width, self.pageBorderY + self.tableOffset.y + last * self.cellSize.height);
                CGPoint end = CGPointMake(self.pageBorderX + self.tableOffset.x + column * self.cellSize.width, self.pageBorderY + self.tableOffset.y + row * self.cellSize.height);
                [self drawLine:start toPoint:end width:width dashed:dashed color:color];
            }
        }];
        [self drawSpanCellGrid:columns rows:rows rowBased:YES content:content handler:^(NSInteger column, NSInteger row, BOOL cellSpan, NSInteger last) {
            if (cellSpan) {
                CGPoint start = CGPointMake(self.pageBorderX + self.tableOffset.x + last * self.cellSize.width, self.pageBorderY + self.tableOffset.y + row * self.cellSize.height);
                CGPoint end = CGPointMake(self.pageBorderX + self.tableOffset.x + column * self.cellSize.width, self.pageBorderY + self.tableOffset.y + row * self.cellSize.height);
                [self drawLine:start toPoint:end width:width dashed:dashed color:color];
            }
        }];
    }
}

- (void)drawSpanCellGrid:(NSInteger)columns rows:(NSInteger)rows rowBased:(BOOL)rowBased content:(NSArray *)content handler:(void (^)(NSInteger column, NSInteger row, BOOL cellSpan, NSInteger lastCell))handler {
    if (self.supportCellSpan) {
        NSInteger columnBias = 0;
        if (self.withLeftHeaders) {
            columnBias = 1;
        }
        NSInteger rowBias = 0;
        if (self.withTopHeaders) {
            rowBias = 1;
        }
        for (NSInteger j = 0; j < (rowBased ? rows - rowBias : columns - columnBias); j++) {
            NSInteger lastCell = 0;
            for (NSInteger i = 0; i < (rowBased ? columns - columnBias : rows - rowBias); i++) {
                NSInteger row = rowBased ? j : i;
                NSInteger column = rowBased ? i : j;
                NSInteger cellSpanCode = [self.cellSpan[row][column] integerValue];
                BOOL cellSpan = NO;
                if (rowBased) {
                    cellSpan = (cellSpanCode == kPDFTableCellSpanRow || cellSpanCode == kPDFTableCellSpanBoth);
                } else {
                    cellSpan = (cellSpanCode == kPDFTableCellSpanColumn || cellSpanCode == kPDFTableCellSpanBoth);
                }
                handler(column + 1, row + 1, cellSpan, lastCell);
                if (cellSpan) {
                    lastCell = i + 2;
                }
            }
            handler(rowBased ? columns : (j + 1), rowBased ? (j + 1) : rows,
                    rowBased ? lastCell < columns : lastCell < rows, lastCell);
        }
    }
}

- (void)drawTableTopHeaders:(NSInteger)columns rows:(NSInteger)rows headers:(NSArray *)headers font:(UIFont *)font color:(UIColor *)color {
    for (NSInteger i = 0; i < columns; i++) {
        if (i < headers.count) {
            CGRect cellRect = [self cellRect:i y:0];
            [self drawOrientedText:[headers objectAtIndex:i] inRect:cellRect font:font color:color horizontalAlign:kPDFTableCreatorHorizontalAlignmentCenter verticalAlign:kPDFTableCreatorVerticalAlignmentMiddle offset:CGPointZero];
        }
    }
}

- (void)drawTableLeftHeaders:(NSInteger)columns rows:(NSInteger)rows headers:(NSArray *)headers font:(UIFont *)font color:(UIColor *)color {
    for (NSInteger j = 0; j < rows - 1; j++) {
        if (j < headers.count) {
            CGRect cellRect = [self cellRect:0 y:j+1];
            [self drawOrientedText:[headers objectAtIndex:j] inRect:cellRect font:font color:color horizontalAlign:kPDFTableCreatorHorizontalAlignmentCenter verticalAlign:kPDFTableCreatorVerticalAlignmentMiddle offset:CGPointZero];
        }
    }
}

- (void)drawTableHeader:(NSString *)headerText font:(UIFont *)font color:(UIColor *)color horizontalAlign:(NSString *)horizontalAlign {
    if (headerText.length > 0) {
        [self drawOrientedText:headerText inRect:[self headerRect] font:font color:color horizontalAlign:horizontalAlign verticalAlign:kPDFTableCreatorVerticalAlignmentMiddle offset:CGPointZero inCell:NO];
    }
}

- (void)drawTableFooter:(NSString *)footerText font:(UIFont *)font color:(UIColor *)color horizontalAlign:(NSString *)horizontalAlign {
    if (footerText.length > 0) {
        [self drawOrientedText:footerText inRect:[self footerRect] font:font color:color horizontalAlign:horizontalAlign verticalAlign:kPDFTableCreatorVerticalAlignmentMiddle offset:CGPointZero inCell:NO];
    }
}

- (void)drawTableBackground:(NSInteger)columns rows:(NSInteger)rows content:(NSArray *)content {
    [self iterateContentCells:columns rows:rows content:content handler:^(NSString *contentText, UIImage *image, NSArray *attributedStrings, CGRect cellRect, NSInteger spanX, NSInteger spanY, BOOL spanned) {
        if (spanned) {
            return;
        }
        for (NSAttributedString *attributedString in attributedStrings) {
            if ([attributedString attribute:kPDFTableCreatorAttributedStringRibbon atIndex:0 effectiveRange:nil]) {
                UIColor *fillColor = (UIColor *)[attributedString attribute:kPDFTableCreatorAttributedStringRibbon atIndex:0 effectiveRange:nil];
                CGFloat height = 0;
                if ([attributedString attribute:kPDFTableCreatorAttributedStringRibbonRelativeHeight atIndex:0 effectiveRange:nil]) {
                    CGFloat relativeHeight = [[attributedString attribute:kPDFTableCreatorAttributedStringRibbonRelativeHeight atIndex:0 effectiveRange:nil] floatValue];
                    BOOL relativeToCell = [[attributedString attribute:kPDFTableCreatorAttributedStringRibbonRelativeToCell atIndex:0 effectiveRange:nil] boolValue];
                    CGFloat refHeight = relativeToCell ? self.cellSize.height : cellRect.size.height;
                    height = refHeight * relativeHeight;
                } else if ([attributedString attribute:kPDFTableCreatorAttributedStringRibbonAbsoluteHeight atIndex:0 effectiveRange:nil]) {
                    height = [[attributedString attribute:kPDFTableCreatorAttributedStringRibbonAbsoluteHeight atIndex:0 effectiveRange:nil] floatValue];
                }
                if (height > 0) {
                    CGRect fillRect = CGRectMake(cellRect.origin.x, cellRect.origin.y, cellRect.size.width, height);
                    [self drawOrientedFilledRect:fillRect fillColor:fillColor offset:CGPointZero];
                }
            }
        }
    }];
}

- (void)drawTableForeground:(NSInteger)columns rows:(NSInteger)rows content:(NSArray *)content {
    /*[self iterateContentCells:columns rows:rows content:content handler:^(NSString *contentText, UIImage *image, NSArray *attributedStrings, CGRect cellRect, NSInteger spanX, NSInteger spanY, BOOL spanned) {
        if (spanned) {
            return;
        }
    }];*/
}

- (void)drawTableContentText:(NSInteger)columns rows:(NSInteger)rows content:(NSArray *)content font:(UIFont *)font color:(UIColor *)color horizontalAlign:(NSString *)horizontalAlign verticalAlign:(NSString *)verticalAlign {
    [self drawTableContentText:columns rows:rows content:content font:font color:color horizontalAlign:horizontalAlign verticalAlign:verticalAlign maxSize:CGSizeZero];
}

- (void)drawTableContentText:(NSInteger)columns rows:(NSInteger)rows content:(NSArray *)content font:(UIFont *)font color:(UIColor *)color horizontalAlign:(NSString *)horizontalAlign verticalAlign:(NSString *)verticalAlign maxSize:(CGSize)maxSize {
    [self iterateContentCells:columns rows:rows content:content handler:^(NSString *contentText, UIImage *image, NSArray *attributedStrings, CGRect cellRect, NSInteger spanX, NSInteger spanY, BOOL spanned) {
        if (spanned) {
            return;
        }
        CGPoint cellOffset = CGPointZero;
        if (maxSize.height > 0) {
            if ([verticalAlign isEqualToString:kPDFTableCreatorVerticalAlignmentTop]) {
                cellRect = CGRectMake(cellRect.origin.x, cellRect.origin.y, cellRect.size.width, MIN(cellRect.size.height, maxSize.height));
            } else if ([verticalAlign isEqualToString:kPDFTableCreatorVerticalAlignmentBottom]) {
                CGFloat textHeight = MAX(0, cellRect.size.height - maxSize.height);
                cellOffset = CGPointMake(0, textHeight);
                cellRect = CGRectMake(cellRect.origin.x, cellRect.origin.y + textHeight, cellRect.size.width, MIN(cellRect.size.height, maxSize.height));
            }
        }
        if (contentText.length > 0) {
            [self drawOrientedText:contentText inRect:cellRect font:font color:color horizontalAlign:horizontalAlign verticalAlign:verticalAlign offset:cellOffset];
        }
    }];
}

- (CGRect)drawTableContentImage:(NSInteger)columns rows:(NSInteger)rows content:(NSArray *)content horizontalAlign:(NSString *)horizontalAlign verticalAlign:(NSString *)verticalAlign {
    __block CGRect placedImageRect = CGRectZero;
    [self iterateContentCells:columns rows:rows content:content handler:^(NSString *contentText, UIImage *image, NSArray *attributedStrings, CGRect cellRect, NSInteger spanX, NSInteger spanY, BOOL spanned) {
        if (spanned) {
            return;
        }
        CGPoint imageOffset = CGPointZero;
        CGRect imageRect = cellRect;
        if (image) {
            imageRect = [self positionRect:cellRect size:image.size horizontalAlign:horizontalAlign verticalAlign:verticalAlign offset:&imageOffset];
            placedImageRect = imageRect;
            imageOffset = CGPointMake(self.imageBorderX + imageOffset.x, self.imageBorderY + imageOffset.y);
            [self drawOrientedImage:image inRect:cellRect horizontalAlign:horizontalAlign verticalAlign:verticalAlign];
        }
        for (NSAttributedString *attributedString in attributedStrings) {
            if ([attributedString attribute:kPDFTableCreatorAttributedStringFill atIndex:0 effectiveRange:nil]) {
                NSString *fill = [attributedString attribute:kPDFTableCreatorAttributedStringFill atIndex:0 effectiveRange:nil];
                UIColor *fillColor = nil;
                if ([attributedString attribute:(__bridge id)kCTForegroundColorAttributeName atIndex:0 effectiveRange:nil]) {
                    CGColorRef colorRef = (__bridge CGColorRef)[attributedString attribute:(__bridge id)kCTForegroundColorAttributeName atIndex:0 effectiveRange:nil];
                    fillColor = [UIColor colorWithCGColor:colorRef];
                }
                NSString *aspectMode = [attributedString attribute:kPDFTableCreatorAttributedStringAspectMode atIndex:0 effectiveRange:nil];
                if ([aspectMode isEqualToString:kPDFTableCreatorAttributedStringAspectModeSquare]) {
                    CGFloat minSide = fmin(cellRect.size.width, cellRect.size.height);
                    CGSize squareSize = CGSizeMake(minSide, minSide);
                    imageRect = [self positionRect:cellRect size:squareSize horizontalAlign:horizontalAlign verticalAlign:verticalAlign offset:&imageOffset];
                    imageOffset = CGPointMake(self.imageBorderX + imageOffset.x, self.imageBorderY + imageOffset.y);
                }
                CGFloat scale = [[attributedString attribute:kPDFTableCreatorAttributedStringScale atIndex:0 effectiveRange:nil] floatValue];
                CGPoint fillOffset = imageOffset;
                CGRect fillRect = [PDFTableCreator scaleRect:imageRect scale:scale offset:&fillOffset];
                if ([fill isEqualToString:kPDFTableCreatorAttributedStringFillRect]) {
                    [self drawOrientedFilledRect:fillRect fillColor:fillColor offset:fillOffset];
                } else if ([fill isEqualToString:kPDFTableCreatorAttributedStringFillCircle]) {
                    [self drawOrientedFilledCircle:fillRect fillColor:fillColor offset:fillOffset];
                }
            } else if ([attributedString attribute:kPDFTableCreatorAttributedStringIcon atIndex:0 effectiveRange:nil]) {
                UIImage *iconImage = (UIImage *)[attributedString attribute:kPDFTableCreatorAttributedStringIcon atIndex:0 effectiveRange:nil];
                CGFloat scale = [[attributedString attribute:kPDFTableCreatorAttributedStringScale atIndex:0 effectiveRange:nil] floatValue];
                CGPoint iconOffset = imageOffset;
                CGRect iconRect = [PDFTableCreator scaleRect:imageRect scale:scale offset:&iconOffset];
                [self drawOrientedIcon:iconImage inRect:iconRect horizontalAlign:horizontalAlign verticalAlign:verticalAlign offset:iconOffset];
            } else if ([attributedString attribute:kPDFTableCreatorAttributedStringText atIndex:0 effectiveRange:nil]) {
                NSAttributedString *attributedText = attributedString;
                CGFloat scale = [[attributedString attribute:kPDFTableCreatorAttributedStringScale atIndex:0 effectiveRange:nil] floatValue];
                CGPoint textOffset = imageOffset;
                CGRect textRect = imageRect;
                if (scale > 0) {
                    CTFontRef fontRef = (__bridge CTFontRef)[attributedString attribute:(__bridge id)kCTFontAttributeName atIndex:0 effectiveRange:nil];
                    CGFloat fontSize = CTFontGetSize(fontRef);
                    CGFloat minSide = fmin(imageRect.size.width, imageRect.size.height);
                    CGFloat scaledFontSize = minSide / 100.0f * fontSize * scale;
                    NSString *fontName = CFBridgingRelease(CTFontCopyPostScriptName(fontRef));
                    fontRef = CTFontCreateWithName((__bridge CFStringRef)fontName, scaledFontSize, nil);
                    attributedText = [attributedString mutableCopy];
                    [(NSMutableAttributedString *)attributedText removeAttribute:(__bridge id)kCTFontAttributeName range:NSMakeRange(0, attributedText.length)];
                    [(NSMutableAttributedString *)attributedText addAttribute:(__bridge id)kCTFontAttributeName value:(__bridge id)(fontRef) range:NSMakeRange(0, attributedText.length)];
                    CGFloat offsetY = scaledFontSize * 0.15;
                    textRect = CGRectMake(textRect.origin.x, textRect.origin.y + offsetY, textRect.size.width, textRect.size.height - offsetY);
                    textOffset = CGPointMake(textOffset.x, textOffset.y + offsetY);
                }
                [self drawOrientedAttributedText:attributedText inRect:textRect horizontalAlign:kPDFTableCreatorHorizontalAlignmentCenter verticalAlign:kPDFTableCreatorVerticalAlignmentMiddle offset:textOffset];
            }
        }
    }];
    return placedImageRect;
}

- (void)iterateContentCells:(NSInteger)columns rows:(NSInteger)rows content:(NSArray *)content handler:(void (^)(NSString *contentText, UIImage *image, NSArray *attributedStrings, CGRect cellRect, NSInteger spanX, NSInteger spanY, BOOL spanned))handler {
    NSInteger columnBias = 0;
    if (self.withLeftHeaders) {
        columnBias = 1;
    }
    NSInteger rowBias = 0;
    if (self.withTopHeaders) {
        rowBias = 1;
    }
    for (NSInteger j = 0; j < rows - rowBias; j++) {
        if (j < content.count) {
            NSArray *rowData = (NSArray *)content[j];
            for (NSInteger i = 0; i < columns - columnBias; i++) {
                if (i < rowData.count) {
                    NSInteger spanX = 1;
                    NSInteger spanY = 1;
                    UIImage *image = nil;
                    NSString *contentText = @"";
                    NSMutableArray *attributedStrings = [@[] mutableCopy];
                    NSArray *cellData = (NSArray *)rowData[i];
                    for (NSObject *object in cellData) {
                        if ([object isKindOfClass:NSString.class]) {
                            if (contentText.length == 0) {
                                contentText = (NSString *)object;
                            } else {
                                contentText = [contentText stringByAppendingFormat:@"\n%@", object];
                            }
                        } else if ([object isKindOfClass:UIImage.class] && !image) {
                            image = (UIImage *)object;
                        } else if ([object isKindOfClass:NSAttributedString.class]) {
                            NSAttributedString *attributedString = (NSAttributedString *)object;
                            [attributedStrings addObject:attributedString];
                            if (self.supportCellSpan) {
                                if ([attributedString attribute:kPDFTableCreatorCellSpanX atIndex:0 effectiveRange:nil]) {
                                    spanX = [[attributedString attribute:kPDFTableCreatorCellSpanX atIndex:0 effectiveRange:nil] integerValue];
                                }
                                if ([attributedString attribute:kPDFTableCreatorCellSpanY atIndex:0 effectiveRange:nil]) {
                                    spanY = [[attributedString attribute:kPDFTableCreatorCellSpanY atIndex:0 effectiveRange:nil] integerValue];
                                }
                            }
                            if ([attributedString attribute:kPDFTableCreatorCellConflict atIndex:0 effectiveRange:nil]) {
                                contentText = [contentText stringByAppendingFormat:@"\n"];
                            }
                        }
                    }
                    NSInteger column = i;
                    if (self.withLeftHeaders) {
                        column++;
                    }
                    NSInteger row = j;
                    if (self.withTopHeaders) {
                        row++;
                    }

                    CGRect cellRect = [self cellRect:column spanX:spanX y:row spanY:spanY];
                    BOOL cellSpan = NO;
                    if (self.cellSpan) {
                        cellSpan = [self.cellSpan[j][i] integerValue];
                    }
                    handler(contentText, image, attributedStrings, cellRect, spanX, spanY, cellSpan);
                }
            }
        }
    }
}

- (void)determineCellSpan:(NSInteger)columns rows:(NSInteger)rows content:(NSArray *)content {
    if (self.supportCellSpan) {
        self.cellSpan = [@[] mutableCopy];
        
        NSInteger columnBias = 0;
        if (self.withLeftHeaders) {
            columnBias = 1;
        }
        NSInteger rowBias = 0;
        if (self.withTopHeaders) {
            rowBias = 1;
        }
        for (NSInteger j = 0; j < rows - rowBias; j++) {
            NSMutableArray *rowCellSpan = [@[] mutableCopy];
            for (NSInteger i = 0; i < columns - columnBias; i++) {
                NSInteger cellSpan = kPDFTableCellSpanNone;
                for (NSInteger k = j; k >= 0; k--) {
                    for (NSInteger l = i; l >= 0; l--) {
                        if (k == j && l == i) {
                            continue;
                        }
                        NSInteger spanX = 0;
                        NSInteger spanY = 0;
                        NSArray *cellData = [PDFTableCreator cellData:content row:k column:l];
                        if (cellData) {
                            for (NSObject *object in cellData) {
                                if ([object isKindOfClass:NSAttributedString.class]) {
                                    NSAttributedString *attributedString = (NSAttributedString *)object;
                                    if ([attributedString attribute:kPDFTableCreatorCellSpanX atIndex:0 effectiveRange:nil]) {
                                        spanX = [[attributedString attribute:kPDFTableCreatorCellSpanX atIndex:0 effectiveRange:nil] integerValue];
                                    }
                                    if ([attributedString attribute:kPDFTableCreatorCellSpanY atIndex:0 effectiveRange:nil]) {
                                        spanY = [[attributedString attribute:kPDFTableCreatorCellSpanY atIndex:0 effectiveRange:nil] integerValue];
                                    }
                                }
                            }
                        }
                        
                        if (spanY <= 1) {
                            spanY = 0;
                        }
                        if (spanX <= 1) {
                            spanX = 0;
                        }
                        
                        if (spanY > 1 && k + spanY > j && l == i) {
                            cellSpan = kPDFTableCellSpanRow;
                        }
                        if (spanX > 1 && l + spanX > i && k == j) {
                            cellSpan = kPDFTableCellSpanColumn;
                        }
                        if (spanY > 1 && k + spanY > j && l != i &&
                            spanX > 1 && l + spanX > i && k != j) {
                            cellSpan = kPDFTableCellSpanBoth;
                        }
                    }
                }
                [rowCellSpan addObject:@(cellSpan)];
            }
            [self.cellSpan addObject:rowCellSpan];
        }
    }
}

- (void)logCellSpan {
    for (NSInteger i = 0; i < self.cellSpan.count; i++) {
        NSString *row = [NSString stringWithFormat:@"%02tu. ", i+1];
        for (NSInteger j = 0; j < [self.cellSpan[i] count]; j++) {
            row = [row stringByAppendingFormat:@",%@", self.cellSpan[i][j]];
        }
        NSLog(@"%@", row);
    }
}

+ (NSArray *)cellData:(NSArray *)content row:(NSInteger)row column:(NSInteger)column {
    if (row >= 0 && row < content.count) {
        NSArray *rowData = (NSArray *)content[row];
        if (column >= 0 && column < rowData.count) {
            return (NSArray *)rowData[column];
        }
    }
    return nil;
}

+ (CGRect)scaleRect:(CGRect)rect scale:(CGFloat)scale offset:(CGPoint *)offset {
    if (scale > 0) {
        CGFloat offsetX = (rect.size.width - rect.size.width * scale) / 2.0;
        CGFloat offsetY = (rect.size.height - rect.size.height * scale) / 2.0;
        CGRect scaledRect = CGRectMake(rect.origin.x + offsetX, rect.origin.y + offsetY,
                                       rect.size.width * scale, rect.size.height * scale);
        offset->x = offset->x + offsetX;
        offset->y = offset->y + offsetY;
        return scaledRect;
    }
    return rect;
}

+ (NSAttributedString *)attributedStringIcon:(UIImage *)icon scale:(CGFloat)scale settings:(NSDictionary *)settings {
    NSMutableDictionary *attributes = [@{} mutableCopy];
    attributes[(__bridge id)(__bridge CFStringRef)kPDFTableCreatorAttributedStringIcon] = icon;
    attributes[(__bridge id)(__bridge CFStringRef)kPDFTableCreatorAttributedStringScale] = @(scale);
    if (settings) {
        attributes[(__bridge id)(__bridge CFStringRef)kPDFTableCreatorAttributedStringSettings] = settings;
    }
    return [[NSAttributedString alloc] initWithString:@" " attributes:attributes];
}

+ (NSAttributedString *)attributedStringText:(NSString *)text fontSize:(CGFloat)fontSize scale:(CGFloat)scale color:(UIColor *)color settings:(NSDictionary *)settings {
    NSMutableDictionary *attributes = [@{} mutableCopy];
    UIFont *font = [UIFont systemFontOfSize:fontSize];
    CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)font.fontName, font.pointSize, nil);
    attributes[(__bridge id)kCTFontAttributeName] = (__bridge id)fontRef;
    attributes[(__bridge id)kCTForegroundColorAttributeName] = (__bridge id)color.CGColor;
    attributes[(__bridge id)(__bridge CFStringRef)kPDFTableCreatorAttributedStringText] = @"";
    attributes[(__bridge id)(__bridge CFStringRef)kPDFTableCreatorAttributedStringScale] = @(scale);
    if (settings) {
        attributes[(__bridge id)(__bridge CFStringRef)kPDFTableCreatorAttributedStringSettings] = settings;
    }
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

+ (NSAttributedString *)attributedStringFill:(NSString *)fillMode aspectMode:(NSString *)aspectMode scale:(CGFloat)scale fillColor:(UIColor *)fillColor settings:(NSDictionary *)settings {
    NSMutableDictionary *attributes = [@{} mutableCopy];
    attributes[(__bridge id)kCTForegroundColorAttributeName] = (__bridge id)fillColor.CGColor;
    attributes[(__bridge id)(__bridge CFStringRef)kPDFTableCreatorAttributedStringFill] = fillMode;
    attributes[(__bridge id)(__bridge CFStringRef)kPDFTableCreatorAttributedStringAspectMode] = aspectMode;
    attributes[(__bridge id)(__bridge CFStringRef)kPDFTableCreatorAttributedStringScale] = @(scale);
    if (settings) {
        attributes[(__bridge id)(__bridge CFStringRef)kPDFTableCreatorAttributedStringSettings] = settings;
    }
    return [[NSAttributedString alloc] initWithString:@" " attributes:attributes];
}

+ (NSAttributedString *)attributedStringRibbon:(UIColor *)fillColor relativeHeight:(CGFloat)relativeHeight relativeToCell:(BOOL)relativeToCell settings:(NSDictionary *)settings {
    NSMutableDictionary *attributes = [@{} mutableCopy];
    attributes[(__bridge id)(__bridge CFStringRef)kPDFTableCreatorAttributedStringRibbon] = fillColor;
    attributes[(__bridge id)(__bridge CFStringRef)kPDFTableCreatorAttributedStringRibbonRelativeHeight] = @(relativeHeight);
    attributes[(__bridge id)(__bridge CFStringRef)kPDFTableCreatorAttributedStringRibbonRelativeToCell] = @(relativeToCell);
    if (settings) {
        attributes[(__bridge id)(__bridge CFStringRef)kPDFTableCreatorAttributedStringSettings] = settings;
    }
    return [[NSAttributedString alloc] initWithString:@" " attributes:attributes];
}

+ (NSAttributedString *)attributedStringRibbon:(UIColor *)fillColor absoluteHeight:(CGFloat)absoluteHeight settings:(NSDictionary *)settings {
    NSMutableDictionary *attributes = [@{} mutableCopy];
    attributes[(__bridge id)(__bridge CFStringRef)kPDFTableCreatorAttributedStringRibbon] = fillColor;
    attributes[(__bridge id)(__bridge CFStringRef)kPDFTableCreatorAttributedStringRibbonAbsoluteHeight] = @(absoluteHeight);
    if (settings) {
        attributes[(__bridge id)(__bridge CFStringRef)kPDFTableCreatorAttributedStringSettings] = settings;
    }
    return [[NSAttributedString alloc] initWithString:@" " attributes:attributes];
}

+ (NSAttributedString *)attributedStringSpanX:(NSInteger)spanX spanY:(NSInteger)spanY settings:(NSDictionary *)settings {
    NSMutableDictionary *attributes = [@{} mutableCopy];
    attributes[(__bridge id)(__bridge CFStringRef)kPDFTableCreatorCellSpanX] = @(spanX);
    attributes[(__bridge id)(__bridge CFStringRef)kPDFTableCreatorCellSpanY] = @(spanY);
    if (settings) {
        attributes[(__bridge id)(__bridge CFStringRef)kPDFTableCreatorAttributedStringSettings] = settings;
    }
    return [[NSAttributedString alloc] initWithString:@" " attributes:attributes];
}

+ (NSAttributedString *)attributedStringConflict:(NSDictionary *)settings {
    NSMutableDictionary *attributes = [@{} mutableCopy];
    attributes[(__bridge id)(__bridge CFStringRef)kPDFTableCreatorCellConflict] = @(YES);
    if (settings) {
        attributes[(__bridge id)(__bridge CFStringRef)kPDFTableCreatorAttributedStringSettings] = settings;
    }
    return [[NSAttributedString alloc] initWithString:@" " attributes:attributes];
}

@end