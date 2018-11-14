//
//  TileViewController.h
//  TeacherPlanner
//
//  Created by Oliver on 01.05.14.
//
//

#import <UIKit/UIKit.h>
#import "TileViewControllerDataSource.h"

@interface TileViewController : UIViewController

@property (nonatomic) BOOL positioned;
@property (nonatomic) NSInteger row;
@property (nonatomic) NSInteger column;

@property (nonatomic) BOOL marked;

@property (nonatomic, weak) id<TileViewControllerDataSource> dataSource;

- (instancetype)initWithDataSource:(id<TileViewControllerDataSource>)dataSource;

- (UIImage *)tileImage;
- (void)adjustPosition;

@end