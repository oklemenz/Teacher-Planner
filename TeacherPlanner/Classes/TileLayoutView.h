//
//  TileLayoutView.h
//  TeacherPlanner
//
//  Created by Oliver on 01.05.14.
//
//

#import <UIKit/UIKit.h>
#import "TileViewController.h"

@protocol TileLayoutViewDelegate <NSObject>
- (void)didChange;
@end

@interface TileLayoutView : UIView

@property (nonatomic) NSInteger rows;
@property (nonatomic) NSInteger columns;
@property (nonatomic) NSInteger itemRows;
@property (nonatomic) NSInteger itemColumns;
@property (nonatomic) NSInteger itemSplitRow;

@property (nonatomic) CGPoint origin;

@property (nonatomic, strong) NSMutableArray *tiles;

@property (nonatomic, weak) id<TileLayoutViewDelegate> delegate;
@property (nonatomic, strong) NSArray<TileViewControllerDataSource> *tileDataSources;

- (BOOL)isPointValid:(CGPoint)point;
- (BOOL)isPointPositioned:(CGPoint)point;
- (NSInteger)rowForPoint:(CGPoint)point;
- (NSInteger)columnForPoint:(CGPoint)point;

- (void)scrollRectToVisibleCentered:(CGRect)visibleRect animated:(BOOL)animated;
- (void)revalidate;
- (void)didChange;

@end