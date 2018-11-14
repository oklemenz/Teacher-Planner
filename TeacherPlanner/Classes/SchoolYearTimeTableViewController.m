//
//  SchoolYearTimeTableViewController.m
//  TeacherPlanner
//
//  Created by Oliver on 04.05.14.
//
//

#import "SchoolYearTimeTableViewController.h"
#import "PDFTableViewController.h"
#import "Utilities.h"
#import "Model.h"
#import "Application.h"
#import "School.h"
#import "Lesson.h"
#import "SchoolTime.h"
#import "Codes.h"
#import "ShareUtilities.h"
#import "PDFTableCreator.h"
#import "NSString+Extension.h"
#import "UIBarButtonItem+Extension.h"
#import "Common.h"

@interface SchoolYearTimeTableViewController ()
@property (nonatomic, strong) UIBarButtonItem *actionButton;
@property (nonatomic, strong) UIBarButtonItem *warningButton;
@property (nonatomic, strong) PDFTableViewController *pdfTable;
@property (nonatomic, strong) NSMutableArray *conflicts;
@property (nonatomic) NSInteger schoolWeekdays;
@end

@implementation SchoolYearTimeTableViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.name = NSLocalizedString(@"Time Table", @"");
        self.subTitle = self.name;
        self.tabBarIcon = @"school_year_time_table";
        
        self.actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(didPressAction:)];
        self.navigationItem.rightBarButtonItem = self.actionButton;

        switch ([Model instance].application.settings.school.schoolWeekdays) {
            case CodeSchoolWeekDayMonFri: default:
                self.schoolWeekdays = 5;
                break;
            case CodeSchoolWeekDayMonSat:
                self.schoolWeekdays = 6;
                break;
            case CodeSchoolWeekDayMonSun:
                self.schoolWeekdays = 7;
                break;
        }
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [Utilities clearGeneratedFolder];
}

- (void)viewDidLoad {
    self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (void)viewWillAppear:(BOOL)animated {
    [self performSelector:@selector(generatePDF) withObject:nil afterDelay:0.1];
}

- (void)generatePDF {
    NSString *dateString = [[Utilities shortDateTimeFormatter] stringFromDate:[NSDate date]];
    NSString *identificationString = [self identification];
    NSString *title = [self documentTitle];
    NSString *filePath = [[Utilities generatedFolder] stringByAppendingPathComponent:[[title validFilePath]stringByAppendingPathExtension:kPDFExtension]];
    
    NSDictionary *settings = @{
        kPDFTableCreatorFilePath : filePath,
        kPDFTableCreatorHeader : title,
        kPDFTableCreatorHorizontalAlignmentHeader : kPDFTableCreatorHorizontalAlignmentCenter,
        kPDFTableCreatorFooter : dateString,
        kPDFTableCreatorHorizontalAlignmentFooter : kPDFTableCreatorHorizontalAlignmentRight,
        kPDFTableCreatorFooterTextColor : [UIColor grayColor],
        kPDFTableCreatorFooter2 : identificationString,
        kPDFTableCreatorHorizontalAlignmentFooter2 : kPDFTableCreatorHorizontalAlignmentLeft,
        kPDFTableCreatorFooter2TextColor : [UIColor grayColor],
        kPDFTableCreatorColumns : @(self.topHeaders.count),
        kPDFTableCreatorRows : @(self.leftHeaders.count+1),
        kPDFTableCreatorHorizontalAlignmentText : kPDFTableCreatorHorizontalAlignmentCenter,
        kPDFTableCreatorVerticalAlignmentText : kPDFTableCreatorVerticalAlignmentMiddle,
        kPDFTableCreatorTopHeaders : self.topHeaders,
        kPDFTableCreatorLeftHeaders : self.leftHeaders,
        kPDFTableCreatorContent : self.content,
        kPDFTableCreatorOrientationSupport : @(YES),
        kPDFTableCreatorSupportCellSpan : @([self.schoolYear.mergeLessonCells boolValue]),
        kPDFTableCreatorTableTextFontMin : @(12)
    };

    self.conflicts = [@[] mutableCopy];
    for (int i = 0; i < self.content.count; i++) {
        NSMutableArray *row = self.content[i];
        for (int j = 0; j < row.count; j++) {
            NSMutableArray *cell = row[j];
            BOOL conflict = NO;
            NSString *conflictText = @"";
            for (NSObject *object in cell) {
                if ([object isKindOfClass:NSAttributedString.class]) {
                    NSAttributedString *attributedString = (NSAttributedString *)object;
                    if ([attributedString attribute:kPDFTableCreatorCellConflict atIndex:0 effectiveRange:nil]) {
                        conflict = YES;
                    }
                } else if ([object isKindOfClass:SchoolClass.class]) {
                    SchoolClass *schoolClass = (SchoolClass *)object;
                    NSString *conflictItem = schoolClass.name;
                    if (schoolClass.subject.length > 0) {
                        conflictItem = [conflictItem stringByAppendingFormat:@" (%@)", schoolClass.subject];
                    }
                    if (conflictText.length == 0) {
                        conflictText = conflictItem;
                    } else {
                        conflictText = [conflictText stringByAppendingFormat:@" <-> %@", conflictItem];
                    }
                }
            }
            if (conflict) {
                [self.conflicts addObject:conflictText];
            }
        }
    }
    
    if (self.conflicts.count > 0) {
        
        NSMutableArray *uniqueConflicts = [NSMutableArray array];
        for (NSString *conflict in self.conflicts) {
            if (![uniqueConflicts containsObject:conflict]) {
                [uniqueConflicts addObject:conflict];
            }
        }
        self.conflicts = uniqueConflicts;
        
        if (!self.warningButton) {
            self.warningButton = [UIBarButtonItem createCustomTintedTopBarButtonItem:@"warning"];
            [(UIButton *)self.warningButton.customView addTarget:self action:@selector(didPressWarning:)
                                            forControlEvents:UIControlEventTouchUpInside];
        }
        self.navigationItem.rightBarButtonItems = @[self.actionButton, self.warningButton];
    } else {
        self.navigationItem.rightBarButtonItems = nil;
        self.navigationItem.rightBarButtonItem = self.actionButton;
    }
    
    if (!self.pdfTable) {
        self.pdfTable = [[PDFTableViewController alloc] initWithSettings:settings];
        [self addChildViewController:self.pdfTable];
        self.pdfTable.view.frame = self.view.bounds;
        [self.view addSubview:self.pdfTable.view];
    } else {
        [self.pdfTable updateSettings:settings];
    }
    [self.pdfTable show];
}

- (NSArray *)topHeaders {
    NSMutableArray *topHeaders = [@[NSLocalizedString(@"Times", @"")] mutableCopy];
    for (int i = 0; i < self.schoolWeekdays; i++) {
        NSString *weekday = [Codes textForCode:@"CodeWeekDay" value:i+1];
        [topHeaders addObject:weekday];
    }
    return topHeaders;
}

- (NSArray *)leftHeaders {
    NSMutableArray *leftHeaders = [@[] mutableCopy];
    NSInteger index = 1;
    for (SchoolTime *schoolTime in [Model instance].application.settings.school.schoolTime) {
        NSString *timeFromTo = [NSString stringWithFormat:@"%tu. %@ -\n %@", index, [[Utilities timeFormatter] stringFromDate:schoolTime.startTime], [[Utilities timeFormatter] stringFromDate:schoolTime.endTime]];
        [leftHeaders addObject:timeFromTo];
        index++;
    }
    return leftHeaders;
}

- (NSArray *)content {
    NSInteger schoolTimeCount = [Model instance].application.settings.school.schoolTime.count;
    NSMutableArray *rows = [@[] mutableCopy];
    for (int i = 0; i < schoolTimeCount; i++) {
        NSMutableArray *row = [@[] mutableCopy];
        for (int j = 0; j < self.schoolWeekdays; j++) {
            [row addObject:[@[] mutableCopy]];
        }
        [rows addObject:row];
    }
    for (int i = 0; i < schoolTimeCount; i++) {
        for (int j = 0; j < self.schoolWeekdays; j++) {
            NSMutableArray *cell = rows[i][j];
            for (SchoolClass *schoolClass in self.schoolYear.schoolClass) {
                for (Lesson *lesson in schoolClass.lesson) {
                    if ([lesson.weekDay integerValue] == j + 1) {
                        NSInteger found = NO;
                        NSInteger spanY = 0;
                        if ([self.schoolYear.mergeLessonCells boolValue]) {
                            if (i == [lesson.timeStart integerValue]) {
                                spanY = ([lesson.timeEnd integerValue] - [lesson.timeStart integerValue] + 1);
                                found = YES;
                            }
                        } else if (i >= [lesson.timeStart integerValue] && i <= [lesson.timeEnd integerValue]) {
                            found = YES;
                        }
                        if (found) {
                            if (cell.count > 0) {
                                NSAttributedString *conflict = [PDFTableCreator attributedStringConflict:@{}];
                                [cell addObject:conflict];
                            }
                            [cell addObject:schoolClass];
                            if (spanY > 0) {
                                [cell addObject:[PDFTableCreator attributedStringSpanX:1 spanY:spanY settings:@{}]];
                            }
                            if (schoolClass.color && ![schoolClass.color isEqual:kSchoolClassDefaultColor]) {
                                NSAttributedString *ribbon = [PDFTableCreator attributedStringRibbon:schoolClass.color relativeHeight:0.1 relativeToCell:YES settings:@{}];
                                [cell addObject:ribbon];
                            }
                            if (schoolClass.name.length > 0) {
                                [cell addObject:schoolClass.name];
                            }
                            if (schoolClass.subject.length > 0) {
                                [cell addObject:schoolClass.subject];
                            }
                            if (lesson.room.length > 0) {
                                [cell addObject:lesson.room];
                            }
                        }
                    }
                }
            }
        }
    }
    return rows;
}

- (NSString *)identification {
    NSString *identificationString = @"";
    if ([Model instance].application.settings.teacher.name.length > 0) {
        identificationString = [identificationString stringByAppendingString:[Model instance].application.settings.teacher.name];
    }
    if ([Model instance].application.settings.teacher.code.length > 0) {
        identificationString = [identificationString stringByAppendingFormat:@" (%@)", [Model instance].application.settings.teacher.code];
    }
    if ([Model instance].application.settings.school.name.length > 0) {
        identificationString = [identificationString stringByAppendingFormat:@"\n%@", [Model instance].application.settings.school.name];
    }
    identificationString = [identificationString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    return identificationString;
}

- (void)didPressAction:(id)sender {
    NSString *title = [self documentTitle];
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self.pdfTable.fileURL path]]) {
        [ShareUtilities showPDFActivityView:title
                                        url:self.pdfTable.fileURL presenter:self.navigationController];
    }
}
- (void)didPressWarning:(id)sender {
    NSString *message = NSLocalizedString(@"The following classes conflict in time:\n", @"");
    for (NSString *conflict in self.conflicts) {
        message = [message stringByAppendingFormat:@"\n%@", conflict];
    }
    [Common showMessage:self title:NSLocalizedString(@"Time Conflicts", @"") message:message okHandler:nil];
}

- (NSString *)documentTitle {
    return [[NSString alloc] initWithFormat:@"%@ - %@", NSLocalizedString(@"Time Table", @""), self.schoolYear.name];
}

- (SchoolYear *)schoolYear {
    return (SchoolYear *)self.entity;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

@end