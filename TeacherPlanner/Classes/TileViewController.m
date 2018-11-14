//
//  TileViewController.h
//  TeacherPlanner
//
//  Created by Oliver on 01.05.14.
//
//

#import "TileViewController.h"
#import "TileLayoutViewController.h"
#import "TileLayoutView.h"
#import <QuartzCore/QuartzCore.h>
#import "Utilities.h"

@interface TileViewController ()

@property (nonatomic, strong) TileLayoutView *tileLayoutView;

@property (nonatomic, strong) UIImageView *image;
@property (nonatomic, retain) UILabel *initialsTextLabel;
@property (nonatomic, strong) UILabel *label;

@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGestureRecognizer;
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;

@property (nonatomic) BOOL inMove;
@property (nonatomic) CGPoint refPoint;

@end

@implementation TileViewController

- (instancetype)initWithDataSource:(id<TileViewControllerDataSource>)dataSource {
    self = [super init];
    if (self) {
        self.dataSource = dataSource;
        self.positioned = [self.dataSource tilePositioned];
        self.row = [self.dataSource tileRow];
        self.column = [self.dataSource tileColumn];
        CGRect contentRect = CGRectMake(ITEM_WIDTH_PADDING,
                                        ITEM_HEIGHT_PADDING,
                                        ITEM_WIDTH - 2 * ITEM_WIDTH_PADDING,
                                        ITEM_HEIGHT - 2 * ITEM_HEIGHT_PADDING);

        self.image = [[UIImageView alloc] initWithImage:[self.dataSource tileImage]];
        self.image.layer.cornerRadius = contentRect.size.width / 2.0;
        self.image.layer.masksToBounds = YES;
        self.image.frame = CGRectMake(contentRect.origin.x + ITEM_IMAGE_PADDING,
                                      contentRect.origin.y + ITEM_IMAGE_PADDING,
                                      contentRect.size.width - 2 * ITEM_IMAGE_PADDING,
                                      contentRect.size.width - 2 * ITEM_IMAGE_PADDING);
        [self.view addSubview:self.image];

        if ([self.dataSource tileShowNameInitials]) {
            if (!self.initialsTextLabel) {
                self.initialsTextLabel = [[UILabel alloc] initWithFrame:CGRectZero];
                self.initialsTextLabel.textAlignment = NSTextAlignmentCenter;
                self.initialsTextLabel.backgroundColor = [UIColor clearColor];
                self.initialsTextLabel.numberOfLines = 1;
                self.initialsTextLabel.textColor = [UIColor whiteColor];
                self.initialsTextLabel.font = [UIFont systemFontOfSize:65.0f];
                self.initialsTextLabel.frame = self.image.frame;
            }
            self.initialsTextLabel.text = [Utilities nameInitials:[self.dataSource tileName]];
            [self.view addSubview:self.initialsTextLabel];
        }
        
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(contentRect.origin.x,
                                                               ITEM_WIDTH - 1.5 * ITEM_WIDTH_PADDING,
                                                               contentRect.size.width,
                                                               60)];
        self.label.text = [self.dataSource tileName];
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.numberOfLines = 2;
        self.label.font = [UIFont boldSystemFontOfSize:25.0f];
        self.label.backgroundColor = [UIColor clearColor];
        [self.view addSubview:self.label];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleMove:)];
    [self.view addGestureRecognizer:self.longPressGestureRecognizer];
}

- (TileLayoutView *)tileLayoutView {
    return (TileLayoutView *)self.view.superview;
}

- (void)mark:(BOOL)mark duration:(CGFloat)duration completion:(void (^)(BOOL finished))completion {
    if (mark && !self.marked) {
        self.marked = YES;
        self.view.layer.zPosition = 1.0;
        [UIView animateWithDuration:duration / 3.0 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            self.view.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
            self.view.alpha = 0.5;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:duration / 1.5 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                self.view.transform = CGAffineTransformMakeScale(1.05f, 1.05f);
            } completion:^(BOOL finished) {
                if (completion) {
                    completion(YES);
                }
            }];
        }];
    } else if (!mark && self.marked) {
        self.marked = NO;
        [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            self.view.transform = CGAffineTransformIdentity;
            self.view.alpha = 1.0;
            [self adjustPosition];
        } completion:^(BOOL finished) {
            self.view.layer.zPosition = 0.0;
            if (completion) {
                completion(YES);
            }
        }];
    }
}

- (void)handleMove:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [self startMove:gestureRecognizer];
    } else if (gestureRecognizer.state == UIGestureRecognizerStateChanged && self.inMove) {
        [self changeMove:gestureRecognizer];
    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded && self.inMove) {
        [self endMove:gestureRecognizer];
    }
}

- (void)startMove:(UIGestureRecognizer *)gestureRecognizer {
    self.inMove = YES;
    self.refPoint = [gestureRecognizer locationInView:self.view.superview];
    [self mark:YES duration:0.3 completion:nil];
}

- (void)changeMove:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint point = [gestureRecognizer locationInView:self.view.superview];
    CGPoint moveCenter = self.view.center;
    moveCenter.x += point.x - self.refPoint.x;
    moveCenter.y += point.y - self.refPoint.y;
    self.view.center = moveCenter;
    self.refPoint = point;

    [self.tileLayoutView scrollRectToVisibleCentered:self.view.frame animated:YES];
    
    for (TileViewController *tile in self.tileLayoutView.tiles) {
        if (!CGRectContainsPoint(tile.view.frame, self.refPoint) && tile != self) {
            [tile mark:NO duration:0.2 completion:nil];
        }
    }
    for (TileViewController *tile in self.tileLayoutView.tiles) {
        if (CGRectContainsPoint(tile.view.frame, self.refPoint) && tile != self && tile.positioned) {
            [tile mark:YES duration:0.5 completion:^(BOOL finished) {
                if (CGRectContainsPoint(tile.view.frame, self.refPoint) && self.inMove) {
                    NSInteger tmpColumn = self.column;
                    NSInteger tmpRow = self.row;
                    BOOL tmpPositioned = self.positioned;
                    self.column = tile.column;
                    self.row = tile.row;
                    self.positioned = tile.positioned;
                    tile.column = tmpColumn;
                    tile.row = tmpRow;
                    tile.positioned = tmpPositioned;
                    [tile mark:NO duration:0.1 completion:nil];
                    [UIView animateWithDuration:1.0 animations:^{
                        [tile adjustPosition];
                    }];
                } else {
                    [tile mark:NO duration:0.2 completion:nil];
                }
            }];
            break;
        }
    }
}

- (void)endMove:(UIGestureRecognizer *)gestureRecognizer {
    self.inMove = NO;
    self.refPoint = [gestureRecognizer locationInView:self.view.superview];
    BOOL found = NO;
    for (TileViewController *tile in self.tileLayoutView.tiles) {
        if (CGRectContainsPoint(tile.view.frame, self.refPoint) && tile != self) {
            found = YES;
        }
    }
    if (!found) {
        if ([self.tileLayoutView isPointValid:self.refPoint]) {
            self.positioned = [self.tileLayoutView isPointPositioned:self.refPoint];
            self.row = [self.tileLayoutView rowForPoint:self.refPoint];
            self.column = [self.tileLayoutView columnForPoint:self.refPoint];
        }
    }
    [self mark:NO duration:0.2 completion:nil];
    [self.tileLayoutView scrollRectToVisibleCentered:self.view.frame animated:YES];
    [self.tileLayoutView didChange];
}

- (void)adjustPosition {
   self.view.frame = CGRectMake(self.tileLayoutView.origin.x + self.column * ITEM_WIDTH,
                                self.tileLayoutView.origin.y + self.row * ITEM_HEIGHT,
                                ITEM_WIDTH,
                                ITEM_HEIGHT);
}

- (void)setPositioned:(BOOL)positioned {
    _positioned = positioned;
    [self.dataSource setTilePositioned:self.positioned];
}

- (void)setRow:(NSInteger)row {
    _row = row;
    [self.dataSource setTileRow:self.row];
}

- (void)setColumn:(NSInteger)column {
    _column = column;
    [self.dataSource setTileColumn:self.column];
}

- (UIImage *)tileImage {
    return [self.dataSource tileImage];
}

@end