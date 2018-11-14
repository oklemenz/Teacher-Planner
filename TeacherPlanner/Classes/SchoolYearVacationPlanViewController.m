//
//  SchoolYearVacationPlanViewController.m
//  TeacherPlanner
//
//  Created by Oliver on 04.05.14.
//
//

#import "SchoolYearVacationPlanViewController.h"
#import "RSDFDatePickerDetailView.h"
#import "Model.h"
#import "Application.h"
#import "School.h"
#import "TransientCustomData.h"
#import "ShareUtilities.h"
#import "Utilities.h"
#import "Common.h"
#import "AnnotationViewController.h"
#import "TransientAnnotationContainer.h"

@interface SchoolYearVacationPlanViewController ()

@property (strong, nonatomic) NSCalendar *calendar;
@property (strong, nonatomic) NSDate *today;
@property (nonatomic, strong) RSDFDatePickerView *datePickerView;
@property (nonatomic, strong) RSDFDatePickerDetailView *datePickerDetailView;
@property (nonatomic, strong) AnnotationViewController *vacationAnnotationViewController;

@end

@implementation SchoolYearVacationPlanViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.name = NSLocalizedString(@"Vacation", @"");
        self.subTitle = self.name;        
        self.tabBarIcon = @"school_year_vacation_plan";
        
        self.vacationAnnotationViewController = [AnnotationViewController new];
        
        UIBarButtonItem *todayButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Today", @"") style:UIBarButtonItemStylePlain target:self action:@selector(didPressToday)];
        UIBarButtonItem *actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(didPressAction:)];
        self.navigationItem.rightBarButtonItems = @[actionButton, todayButton];
        
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    return self;
}

- (void)viewDidLoad {
    self.calendar = [Utilities calendar];
    [self setToday];
    
    [self.view addSubview:self.datePickerView];
    [self.view addSubview:self.datePickerDetailView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.datePickerDetailView hide];
    [self.datePickerView refreshData];
}

- (void)setToday {
    NSDateComponents *todayComponents = [self.calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:[NSDate date]];
    self.today = [self.calendar dateFromComponents:todayComponents];
    [self.datePickerView selectDate:self.today];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.datePickerDetailView hide];
}

- (void)datePickerViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.datePickerDetailView hide];
}

// OK: Add cell long press
- (void)didLongPressCell:(RSDFDatePickerDayCell *)cell {
}

- (RSDFDatePickerView *)datePickerView {
    if (!_datePickerView) {
        _datePickerView = [[RSDFDatePickerView alloc] initWithFrame:self.view.bounds calendar:self.calendar];
        _datePickerView.delegate = self;
        _datePickerView.dataSource = self;
        _datePickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _datePickerView;
}

- (RSDFDatePickerDetailView *)datePickerDetailView {
    if (!_datePickerDetailView) {
        _datePickerDetailView = [[RSDFDatePickerDetailView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 75, self.view.bounds.size.width, 75)];
        _datePickerDetailView.datePickerView = self.datePickerView;
        _datePickerDetailView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    }
    return _datePickerDetailView;
}

- (BOOL)datePickerView:(RSDFDatePickerView *)view isWeekDayOffDate:(NSInteger)weekday {
    NSInteger schoolWeekDays = [Model instance].application.settings.school.schoolWeekdays;
    switch (schoolWeekDays) {
        default:
        case CodeSchoolWeekDayMonFri:
            return weekday == 1 || weekday == 7;
        case CodeSchoolWeekDayMonSat:
            return weekday == 1;
        case CodeSchoolWeekDayMonSun:
            return NO;
    }
}

- (BOOL)datePickerView:(RSDFDatePickerView *)view shouldMarkDate:(NSDate *)date {
    NSArray *dateInfo = [[[Model instance] transientCustomData] infoForDate:date inDatePickerView:self.datePickerView];
    return (dateInfo && dateInfo.count > 0) || [self manualAnnotationReminderOnDate:date].count > 0;
}

- (BOOL)datePickerView:(RSDFDatePickerView *)view isCompletedAllTasksOnDate:(NSDate *)date {
    NSArray *dateInfo = [[[Model instance] transientCustomData] infoForDate:date inDatePickerView:self.datePickerView];
    if (dateInfo) {
        for (NSDictionary *info in dateInfo) {
            if ([info[@"mark"] boolValue]) {
                return YES;
            }
        }
    }
    return NO;
}

- (NSArray *)manualAnnotationReminderOnDate:(NSDate *)date {
    NSMutableArray *annotations = [@[] mutableCopy];
    for (Annotation *annotation in self.schoolYear.annotation.annotation) {
        if (annotation.reminderDate && [[Utilities calendar] isDate:annotation.reminderDate inSameDayAsDate:date]) {
            if (![annotations containsObject:annotation]) {
                [annotations addObject:annotation];
            }
        }
    }
    for (SchoolClass *schoolClass in self.schoolYear.schoolClass) {
        for (Annotation *annotation in schoolClass.annotation.annotation) {
            if (annotation.reminderDate && [[Utilities calendar] isDate:annotation.reminderDate inSameDayAsDate:date]) {
                if (![annotations containsObject:annotation]) {
                    [annotations addObject:annotation];
                }
            }
        }
        for (Student *student in schoolClass.student) {
            for (Annotation *annotation in student.annotation.annotation) {
                if (annotation.reminderDate && [[Utilities calendar] isDate:annotation.reminderDate inSameDayAsDate:date]) {
                    if (![annotations containsObject:annotation]) {
                        [annotations addObject:annotation];
                    }
                }
            }
            for (Annotation *annotation in student.person.annotation.annotation) {
                if (annotation.reminderDate && [[Utilities calendar] isDate:annotation.reminderDate inSameDayAsDate:date]) {
                    if (![annotations containsObject:annotation]) {
                        [annotations addObject:annotation];
                    }
                }
            }
        }
    }
    return annotations;
}

- (BOOL)datePickerView:(RSDFDatePickerView *)view isManualTasksOnDate:(NSDate *)date {
    if ([self manualAnnotationReminderOnDate:date].count > 0) {
        return YES;
    }
    return NO;
}

- (BOOL)datePickerView:(RSDFDatePickerView *)view isInactiveManualTasksOnDate:(NSDate *)date {
    NSArray *annotations = [self manualAnnotationReminderOnDate:date];
    if (annotations.count > 0) {
        for (Annotation *annotation in annotations) {
            if ([annotation isReminderActive]) {
                return NO;
            }
        }
    }
    return YES;
}

- (BOOL)datePickerView:(RSDFDatePickerView *)view shouldHighlightDate:(NSDate *)date {
    return YES;
}


- (BOOL)datePickerView:(RSDFDatePickerView *)view shouldSelectDate:(NSDate *)date {
    return YES;
}

- (void)datePickerView:(RSDFDatePickerView *)view didSelectDate:(NSDate *)date {
    [self.datePickerDetailView setHeaderDate:date];
    NSArray *dateInfo = [[[Model instance] transientCustomData] infoForDate:date inDatePickerView:self.datePickerView];
    NSMutableArray *data = [dateInfo mutableCopy];
    for (Annotation *annotation in [self manualAnnotationReminderOnDate:date]) {
        if (annotation.type == CodeAnnotationTypeText) {
            [data addObject:@{ @"name" : annotation.text,
                               @"annotation" : annotation }];
        }
    }
    [self.datePickerDetailView setDescriptionInfo:data];
    [self.datePickerDetailView show];
}

- (void)datePickerView:(RSDFDatePickerView *)view didLongPressDate:(NSDate *)date {
    [self.datePickerView selectDate:date];
    TransientAnnotationContainer *annotationContainer = [TransientAnnotationContainer new];
    annotationContainer.delegate = self.schoolYear.annotation;
    annotationContainer.date = date;
    annotationContainer.annotation = (NSMutableArray<Annotation> *)[[self manualAnnotationReminderOnDate:date] mutableCopy];
    self.vacationAnnotationViewController.dataSource = annotationContainer;
    self.vacationAnnotationViewController.imageDataSource = [[Model instance] application];
    
    [self.navigationController pushViewController:self.vacationAnnotationViewController animated:YES];

    if (annotationContainer.annotation.count == 0) {
        self.vacationAnnotationViewController.showNewDialog = YES;
    }
}

- (void)didPressToday {
    [self.datePickerView selectDate:self.today];
    [self.datePickerView scrollToToday:YES];
}

- (void)didPressAction:(id)sender {
    // TODO: Pass calendar entries (only future, how long, only loaded?, duplicates...)
    [ShareUtilities showExportCalendarActivityView:@[] presenter:self.navigationController];
}

- (SchoolYear *)schoolYear {
    return (SchoolYear *)self.entity;
}

@end