//
//  PDFTableCreator.h
//  TeacherPlanner
//
//  Created by Klemenz, Oliver on 27.05.14.
//  Copyright (c) 2014 Oliver Klemenz. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kPDFTableCreatorFilePath                             @"kPDFTableCreatorFilePath"
#define kPDFTableCreatorHeader                               @"kPDFTableCreatorHeader"
#define kPDFTableCreatorHeaderTextColor                      @"kPDFTableCreatorHeaderTextColor"
#define kPDFTableCreatorHorizontalAlignmentHeader            @"kPDFTableCreatorHorizontalAlignmentHeader"
#define kPDFTableCreatorFooter                               @"kPDFTableCreatorFooter"
#define kPDFTableCreatorFooterTextColor                      @"kPDFTableCreatorFooterTextColor"
#define kPDFTableCreatorHorizontalAlignmentFooter            @"kPDFTableCreatorHorizontalAlignmentFooter"
#define kPDFTableCreatorFooter2                              @"kPDFTableCreatorFooter2"
#define kPDFTableCreatorFooter2TextColor                     @"kPDFTableCreatorFooter2TextColor"
#define kPDFTableCreatorHorizontalAlignmentFooter2           @"kPDFTableCreatorHorizontalAlignmentFooter2"
#define kPDFTableCreatorSupportCellSpan                      @"kPDFTableCreatorSupportCellSpan"
#define kPDFTableCreatorColumns                              @"kPDFTableCreatorColumns"
#define kPDFTableCreatorRows                                 @"kPDFTableCreatorRows"
#define kPDFTableCreatorTopHeaders                           @"kPDFTableCreatorTopHeaders"
#define kPDFTableCreatorLeftHeaders                          @"kPDFTableCreatorLeftHeaders"
#define kPDFTableCreatorContent                              @"kPDFTableCreatorContent"
#define kPDFTableCreatorDefaultOrientation                   @"kPDFTableCreatorDefaultOrientation"
#define kPDFTableCreatorOrientationSupport                   @"kPDFTableCreatorOrientationSupport"
#define kPDFTableCreatorOptimalOrientation                   @"kPDFTableCreatorOptimalOrientation"
#define kPDFTableCreatorPageBorderX                          @"kPDFTableCreatorPageBorderX"
#define kPDFTableCreatorPageBorderY                          @"kPDFTableCreatorPageBorderY"
#define kPDFTableCreatorImageBorderX                         @"kPDFTableCreatorImageBorderX"
#define kPDFTableCreatorImageBorderY                         @"kPDFTableCreatorImageBorderY"
#define kPDFTableCreatorAttributedStringScale                @"kPDFTableCreatorAttributedStringScale"
#define kPDFTableCreatorAttributedStringFill                 @"kPDFTableCreatorAttributedStringFill"
#define kPDFTableCreatorAttributedStringFillRect             @"kPDFTableCreatorAttributedStringFillRect"
#define kPDFTableCreatorAttributedStringFillCircle           @"kPDFTableCreatorAttributedStringFillCircle"
#define kPDFTableCreatorAttributedStringAspectMode           @"kPDFTableCreatorAttributedStringAspectMode"
#define kPDFTableCreatorAttributedStringAspectModeSquare     @"kPDFTableCreatorAttributedStringAspectModeSquare"
#define kPDFTableCreatorAttributedStringText                 @"kPDFTableCreatorAttributedStringText"
#define kPDFTableCreatorAttributedStringIcon                 @"kPDFTableCreatorAttributedStringIcon"
#define kPDFTableCreatorAttributedStringRibbon               @"kPDFTableCreatorAttributedStringRibbon"
#define kPDFTableCreatorAttributedStringRibbonRelativeHeight @"kPDFTableCreatorAttributedStringRibbonRelativeHeight"
#define kPDFTableCreatorAttributedStringRibbonRelativeToCell @"kPDFTableCreatorAttributedStringRibbonRelativeToCell"
#define kPDFTableCreatorAttributedStringRibbonAbsoluteHeight @"kPDFTableCreatorAttributedStringRibbonAbsoluteHeight"
#define kPDFTableCreatorAttributedStringSettings             @"kPDFTableCreatorAttributedStringSettings"
#define kPDFTableCreatorTableBorderStyle                     @"kPDFTableCreatorTableBorderStyle"
#define kPDFTableCreatorTableBorderStyleSolid                @"kPDFTableCreatorTableBorderStyleSolid"
#define kPDFTableCreatorTableBorderStyleDashed               @"kPDFTableCreatorTableBorderStyleDashed"
#define kPDFTableCreatorTableBorderWidth                     @"kPDFTableCreatorTableBorderWidth"
#define kPDFTableCreatorTableBorderColor                     @"kPDFTableCreatorTableBorderColor"
#define kPDFTableCreatorTableFillColor                       @"kPDFTableCreatorTableFillColor"
#define kPDFTableCreatorTableTopHeaderFillColor              @"kPDFTableCreatorTableTopHeaderFillColor"
#define kPDFTableCreatorTableLeftHeaderFillColor             @"kPDFTableCreatorTableLeftHeaderFillColor"
#define kPDFTableCreatorTableTextColor                       @"kPDFTableCreatorTableTextColor"
#define kPDFTableCreatorTableTextFontMin                     @"kPDFTableCreatorTableTextFontMin"
#define kPDFTableCreatorCellRatio                            @"kPDFTableCreatorCellRatio"
#define kPDFTableCreatorCellPaddingX                         @"kPDFTableCreatorCellPaddingX"
#define kPDFTableCreatorCellPaddingY                         @"kPDFTableCreatorCellPaddingY"
#define kPDFTableCreatorCellSpanX                            @"kPDFTableCreatorCellSpanX"
#define kPDFTableCreatorCellSpanY                            @"kPDFTableCreatorCellSpanY"
#define kPDFTableCreatorCellConflict                         @"kPDFTableCreatorCellConflict"
#define kPDFTableCreatorHorizontalAlignmentText              @"kPDFTableCreatorHorizontalAlignmentText"
#define kPDFTableCreatorHorizontalAlignmentImage             @"kPDFTableCreatorHorizontalAlignmentImage"
#define kPDFTableCreatorHorizontalAlignmentLeft              @"kPDFTableCreatorHorizontalAlignmentLeft"
#define kPDFTableCreatorHorizontalAlignmentCenter            @"kPDFTableCreatorHorizontalAlignmentCenter"
#define kPDFTableCreatorHorizontalAlignmentRight             @"kPDFTableCreatorHorizontalAlignmentRight"
#define kPDFTableCreatorVerticalAlignmentText                @"kPDFTableCreatorVerticalAlignmentText"
#define kPDFTableCreatorVerticalAlignmentImage               @"kPDFTableCreatorVerticalAlignmentImage"
#define kPDFTableCreatorVerticalAlignmentTop                 @"kPDFTableCreatorVerticalAlignmentTop"
#define kPDFTableCreatorVerticalAlignmentMiddle              @"kPDFTableCreatorVerticalAlignmentMiddle"
#define kPDFTableCreatorVerticalAlignmentBottom              @"kPDFTableCreatorVerticalAlignmentBottom"

@interface PDFTableCreator : NSObject

- (instancetype)initWithSettings:(NSDictionary *)settings;
- (void)create;

+ (NSAttributedString *)attributedStringIcon:(UIImage *)icon scale:(CGFloat)scale settings:(NSDictionary *)settings;
+ (NSAttributedString *)attributedStringText:(NSString *)text fontSize:(CGFloat)fontSize scale:(CGFloat)scale color:(UIColor *)color settings:(NSDictionary *)settings;
+ (NSAttributedString *)attributedStringFill:(NSString *)fillMode aspectMode:(NSString *)aspectMode scale:(CGFloat)scale fillColor:(UIColor *)fillColor settings:(NSDictionary *)settings;
+ (NSAttributedString *)attributedStringRibbon:(UIColor *)fillColor relativeHeight:(CGFloat)relativeHeight relativeToCell:(BOOL)relativeToCell settings:(NSDictionary *)settings;
+ (NSAttributedString *)attributedStringRibbon:(UIColor *)fillColor absoluteHeight:(CGFloat)absoluteHeight settings:(NSDictionary *)settings;
+ (NSAttributedString *)attributedStringSpanX:(NSInteger)spanX spanY:(NSInteger)spanY settings:(NSDictionary *)settings;
+ (NSAttributedString *)attributedStringConflict:(NSDictionary *)settings;

@end