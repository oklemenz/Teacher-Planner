//
//  PencilStyleView.h
//  TeacherPlanner
//
//  Created by Klemenz, Oliver on 05.08.14.
//

#define kPencilStyleMaxWidth 30
#define kPencilStyleBorder   5
#define kPencilStyleGrid     (kPencilStyleMaxWidth + 2 * kPencilStyleBorder)

@class PencilStyle;
@class PencilStyleView;

@protocol PencilStyleViewDelegate <NSObject>
- (void)didSelectPencilStyle:(PencilStyleView *)pencilStyle;
- (void)didMarkPencilStyle:(PencilStyleView *)pencilStyle;
@end

@interface PencilStyleView : UIView

@property (nonatomic, strong, readonly) PencilStyle *pencilStyle;
@property (nonatomic, weak) id<PencilStyleViewDelegate> delegate;

- (instancetype)initWithPencilStyle:(PencilStyle *)pencilStyle;

- (UIImage *)image;
- (UIImage *)icon;

- (void)refresh;
- (void)position:(NSInteger)row column:(NSInteger)column offset:(CGPoint)offset;

@end