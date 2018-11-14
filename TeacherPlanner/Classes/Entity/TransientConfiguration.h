//
//  TransientConfiguration.h
//  TeacherPlanner
//
//  Created by Oliver Klemenz on 27.12.14.
//
//

#import "JSONTransientEntity.h"

@interface TransientConfiguration : JSONTransientEntity

@property (nonatomic, strong) NSNumber *brandingActive;

@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) UIColor *highlightColor;
@property (nonatomic, strong) UIColor *topBackgroundColor;
@property (nonatomic, strong) UIColor *topButtonColor;
@property (nonatomic, strong) UIColor *bottomBackgroundColor;
@property (nonatomic, strong) UIColor *bottomButtonColor;
@property (nonatomic, strong) NSNumber *lightStatusBar;

@property (nonatomic, strong) NSNumber *requestPasscode;

@end