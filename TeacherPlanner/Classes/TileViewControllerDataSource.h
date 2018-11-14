//
//  TileViewControllerDataSource.h
//  TeacherPlanner
//
//  Created by Oliver on 26.06.14.
//
//

#import <Foundation/Foundation.h>

@protocol TileViewControllerDataSource

- (NSString *)tileName;
- (BOOL)tileShowNameInitials;
- (UIImage *)tileImage;
- (BOOL)tilePositioned;
- (void)setTilePositioned:(BOOL)tilePositioned;
- (NSInteger)tileRow;
- (void)setTileRow:(NSInteger)tileRow;
- (NSInteger)tileColumn;
- (void)setTileColumn:(NSInteger)tileColumn;

@end

@interface TileViewControllerDataSource : NSObject
@end
