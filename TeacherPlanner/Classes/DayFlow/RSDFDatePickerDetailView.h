//
//  RSDFDatePickerDetailView.h
//  TeacherPlanner
//
//  Created by Oliver on 25.05.14.
//
//

#import <UIKit/UIKit.h>

@class RSDFDatePickerView;

@interface RSDFDatePickerDetailView : UIView

@property (nonatomic, weak) RSDFDatePickerView *datePickerView;
@property (nonatomic, strong) UILabel *header;
@property (nonatomic, strong) UILabel *headerDescription;

- (void)show;
- (void)hide;

- (void)setHeaderDate:(NSDate *)date;
- (void)setDescriptionInfo:(NSArray *)info;

@end