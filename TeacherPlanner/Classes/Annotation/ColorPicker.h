//
//  ColorPicker.h
//  TeacherPlanner
//
//  Created by Klemenz, Oliver on 05.08.14.
//

#import <UIKit/UIKit.h>

@protocol ColorPickerDelegate <NSObject>
- (void)didPickColor:(UIColor *)color sender:(id)sender;
@end

@interface ColorPicker : UIView

@property (nonatomic, strong) UIColor *color;
@property (nonatomic, weak) id<ColorPickerDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame color:(UIColor *)color;

@end

