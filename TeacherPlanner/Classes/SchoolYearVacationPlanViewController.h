//
//  SchoolYearVacationPlanViewController.h
//  TeacherPlanner
//
//  Created by Oliver on 04.05.14.
//
//

#import <UIKit/UIKit.h>
#import "AbstractBaseViewController.h"
#import "RSDFDatePickerView.h"

@interface SchoolYearVacationPlanViewController : AbstractBaseViewController<RSDFDatePickerViewDelegate, RSDFDatePickerViewDataSource>
@end
