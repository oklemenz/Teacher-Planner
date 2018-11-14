//
//  TileLayoutViewController.h
//  TeacherPlanner
//
//  Created by Oliver on 01.05.14.
//
//

#import "TileLayoutViewController.h"
#import "TileLayoutView.h"
#import "TileViewController.h"

@interface TileLayoutViewController ()

@property (nonatomic, strong) TileLayoutView *tileLayoutView;
@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation TileLayoutViewController

- (void)centerScrollViewContents {
    CGSize boundsSize = self.scrollView.bounds.size;
    CGRect contentsFrame = self.tileLayoutView.frame;
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    self.tileLayoutView.frame = contentsFrame;
}

- (void)revalidate {
    [self.tileLayoutView revalidate];
    [self centerScrollViewContents];
}

- (void)refresh {
    CGRect scrollViewFrame = self.scrollView.frame;
    CGFloat scaleWidth = scrollViewFrame.size.width / self.tileLayoutView.bounds.size.width;
    CGFloat scaleHeight = scrollViewFrame.size.height / self.tileLayoutView.bounds.size.height;
    CGFloat minScale = MIN(scaleWidth, scaleHeight);
    self.scrollView.minimumZoomScale = minScale;
    self.scrollView.maximumZoomScale = 5.0f;
}

- (void)didChange {
    self.scrollView.contentSize = self.tileLayoutView.frame.size;
    [self refresh];
    [self centerScrollViewContents];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.scrollView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.scrollView];
    self.tileLayoutView = [[TileLayoutView alloc] initWithFrame:CGRectZero];
    self.tileLayoutView.delegate = self;
    self.tileLayoutView.tileDataSources = self.tileDataSources;
    [self.scrollView addSubview:self.tileLayoutView];
    self.scrollView.contentSize = self.tileLayoutView.bounds.size;
    self.scrollView.delegate = self;
    self.scrollView.delaysContentTouches = NO;
    self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self revalidate];
}

- (void)viewDidAppear:(BOOL)animated {
    [self centerScrollViewContents];
}

- (NSArray *)positionedTiles {
    NSMutableArray *tiles = [@[] mutableCopy];
    for (TileViewController *tile in self.tileLayoutView.tiles) {
        if (tile.positioned) {
            [tiles addObject:tile];
        }
    }
    return tiles;
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self centerScrollViewContents];
}

#pragma mark - UIScrollViewDelegate

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.tileLayoutView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self centerScrollViewContents];
}

@end
