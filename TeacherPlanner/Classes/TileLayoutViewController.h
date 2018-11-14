//
//  TileLayoutViewController.h
//  TeacherPlanner
//
//  Created by Oliver on 01.05.14.
//
//

#import <UIKit/UIKit.h>
#import "TileLayoutView.h"
#import "TileViewController.h"

// TODO: Make this configurable
#define ITEM_WIDTH          200.0f
#define ITEM_HEIGHT         240.0f
#define ITEM_WIDTH_PADDING   15.0f
#define ITEM_HEIGHT_PADDING  15.0f
#define ITEM_IMAGE_PADDING    5.0f
#define BORDER_CELLS 2

@interface TileLayoutViewController : UIViewController<UIScrollViewDelegate, TileLayoutViewDelegate>

@property (nonatomic, strong) NSArray<TileViewControllerDataSource> *tileDataSources;

- (NSArray *)positionedTiles;

- (void)revalidate;

@end