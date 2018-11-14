//
//  TileLayoutView.h
//  TeacherPlanner
//
//  Created by Oliver on 01.05.14.
//
//

#import "TileLayoutView.h"
#import "TileLayoutViewController.h"
#import "TileViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface TileLayoutView ()

@property (nonatomic) NSInteger minItemRow;
@property (nonatomic) NSInteger minItemColumn;
@property (nonatomic) NSInteger maxItemRow;
@property (nonatomic) NSInteger maxItemColumn;

@end

@implementation TileLayoutView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.tiles = [@[] mutableCopy];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setTileDataSources:(NSArray<TileViewControllerDataSource> *)tileDataSources {
    _tileDataSources = tileDataSources;
    [self revalidate];
}

- (void)revalidate {
    for (UIView *view in [self subviews]) {
        [view removeFromSuperview];
    }
    [self.tiles removeAllObjects];
    for (id<TileViewControllerDataSource> tileDelegate in self.tileDataSources) {
        TileViewController *tile = [[TileViewController alloc] initWithDataSource:tileDelegate];
        [self.tiles addObject:tile];
        [self addSubview:tile.view];
    }
    [self.tiles sortUsingComparator:^NSComparisonResult(TileViewController *tile1, TileViewController *tile2) {
        return [[tile1.dataSource tileName] compare:[tile2.dataSource tileName]];
    }];
    [self refresh:NO];
}

- (void)refresh:(BOOL)animated {
    if (animated) {
        [self calcContainerSize];
        [self adjustSize];
        [self.delegate didChange];
        [self setNeedsDisplay];
        [UIView animateWithDuration:0.5 animations:^{
            [self positionTiles];
        }];
    } else {
        [self calcContainerSize];
        [self adjustSize];
        [self.delegate didChange];
        [self setNeedsDisplay];
        [self positionTiles];
    }
}

- (void)calcContainerSize {
    self.columns = 0;
    self.rows = 0;

    self.itemColumns = 0;
    self.itemRows = 0;
    
    self.minItemRow = BORDER_CELLS;
    self.minItemColumn = BORDER_CELLS;
    self.maxItemRow = BORDER_CELLS;
    self.maxItemColumn = BORDER_CELLS;

    self.itemSplitRow = BORDER_CELLS;
    
    NSInteger positionedCount = 0;
    for (TileViewController *tile in self.tiles) {
        if (tile.positioned) {
            if (positionedCount == 0) {
                self.minItemRow = tile.row;
                self.minItemColumn = tile.column;
                self.maxItemRow = tile.row;
                self.maxItemColumn = tile.column;
            } else {
                self.minItemRow = MIN(tile.row, self.minItemRow);
                self.minItemColumn = MIN(tile.column, self.minItemColumn);
                self.maxItemRow = MAX(tile.row, self.maxItemRow);
                self.maxItemColumn = MAX(tile.column, self.maxItemColumn);
            }
            positionedCount++;
        }
    }
    
    NSInteger nonPositionedCount = 0;
    for (TileViewController *tile in self.tiles) {
        if (!tile.positioned) {
            nonPositionedCount++;
        }
    }
    
    if (positionedCount > 0) {
        self.itemColumns = self.maxItemColumn - self.minItemColumn + 1;
        self.itemRows = self.maxItemRow - self.minItemRow + 1;
        self.itemSplitRow += self.maxItemRow + 1;
    }

    if (nonPositionedCount > 0) {
        NSInteger nonPositionedColumns = (int)ceil(sqrt(nonPositionedCount));
        if (nonPositionedColumns > self.itemColumns) {
            self.itemColumns = nonPositionedColumns;
        }
        NSInteger nonPositionedMaxRow = (int)ceil((float)nonPositionedCount / self.itemColumns);
        if (nonPositionedMaxRow > 0) {
            self.itemRows += (self.itemRows > 0 ? BORDER_CELLS : 0) + nonPositionedMaxRow;
        }
    }

    self.columns = self.itemColumns + 2 * BORDER_CELLS;
    self.rows = self.itemRows + 2 * BORDER_CELLS;
    
    self.origin = CGPointMake((BORDER_CELLS - self.minItemColumn) * ITEM_WIDTH, (BORDER_CELLS - self.minItemRow) * ITEM_HEIGHT);
}

- (void)positionTiles {
    for (TileViewController *tile in self.tiles) {
        if (tile.positioned) {
            [tile adjustPosition];
        }
    }
    NSInteger index = 0;
    for (TileViewController *tile in self.tiles) {
        if (!tile.positioned) {
            tile.row = self.itemSplitRow + index / self.itemColumns;
            tile.column = self.minItemColumn + index % self.itemColumns;
            [tile adjustPosition];
            index++;
        }
    }
}

- (void)scrollRectToVisibleCentered:(CGRect)visibleRect animated:(BOOL)animated {
    UIScrollView *scrollView = (UIScrollView *)self.superview;
    CGRect centeredRect = CGRectMake((visibleRect.origin.x - visibleRect.size.width / 2.0) * scrollView.zoomScale,
                                     (visibleRect.origin.y - visibleRect.size.height / 2.0) * scrollView.zoomScale,
                                     2 * visibleRect.size.width * scrollView.zoomScale,
                                     2 * visibleRect.size.height * scrollView.zoomScale);
    [scrollView scrollRectToVisible:centeredRect animated:animated];
}

- (void)didChange {
    [self refresh:YES];
}

- (BOOL)isPointValid:(CGPoint)point {
    return point.x >= 0 && point.y >= 0 && point.x < self.columns * ITEM_WIDTH && point.y < self.rows * ITEM_HEIGHT;
}

- (BOOL)isPointPositioned:(CGPoint)point {
    if ([self isPointValid:point]) {
        NSInteger row = [self rowForPoint:point];
        return row < self.itemSplitRow;
    }
    return NO;
}

- (NSInteger)columnForPoint:(CGPoint)point {
    return round((point.x - self.origin.x - 0.5 * ITEM_WIDTH) / ITEM_WIDTH);
}

- (NSInteger)rowForPoint:(CGPoint)point {
    return round((point.y - self.origin.y - 0.5 * ITEM_HEIGHT) / ITEM_HEIGHT);
}

- (UIScrollView *)scrollView {
    return (UIScrollView *)self.superview;
}

- (void)adjustSize {
    self.bounds = CGRectMake(0,
                             0,
                             MAX(self.columns * ITEM_WIDTH, self.superview.bounds.size.width),
                             MAX(self.rows * ITEM_HEIGHT, self.superview.bounds.size.height));
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetAllowsAntialiasing(context, NO);
    
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:0.75 alpha:1.0].CGColor);
    CGContextSetLineWidth(context, 2.5);
    CGFloat dashLengths[] = { 10, 5 };
    CGContextSetLineDash(context, 0, dashLengths, 2);
    
    for (int i = 0; i < self.columns - 1; i++) {
        CGContextMoveToPoint(context, (i+1) * ITEM_WIDTH, 0);
        CGContextAddLineToPoint(context, (i+1) * ITEM_WIDTH, rect.size.height);
        CGContextStrokePath(context);
    }
    for (int j = 0; j < self.rows - 1; j++) {
        CGContextMoveToPoint(context, 0, (j+1) * ITEM_HEIGHT);
        CGContextAddLineToPoint(context, rect.size.width, (j+1) * ITEM_HEIGHT);
        CGContextStrokePath(context);
    }
    
    CGContextSetLineWidth(context, 10);
    
    CGContextMoveToPoint(context, 0, self.origin.y + self.itemSplitRow * ITEM_HEIGHT);
    CGContextAddLineToPoint(context, rect.size.width, self.origin.y + self.itemSplitRow * ITEM_HEIGHT);
    CGContextStrokePath(context);
}

@end