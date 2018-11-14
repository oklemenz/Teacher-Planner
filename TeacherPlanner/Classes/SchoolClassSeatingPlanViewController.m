//
//  SchoolClassSeatingPlanViewController.m
//  TeacherPlanner
//
//  Created by Oliver on 17.05.14.
//
//

#import "SchoolClassSeatingPlanViewController.h"
#import "TileLayoutViewController.h"
#import "SchoolYear.h"
#import "SchoolClass.h"
#import "Student.h"
#import "Person.h"
#import "Photo.h"
#import "Utilities.h"
#import "ShareUtilities.h"
#import "PDFTableCreator.h"
#import "UIImage+Extension.h"
#import "NSString+Extension.h"
#import "UIBarButtonItem+Extension.h"
#import "Common.h"

#define kPhotoResolution 200.0f

@interface SchoolClassSeatingPlanViewController ()
@property(nonatomic, strong) TileLayoutViewController *tileLayout;
@end

@implementation SchoolClassSeatingPlanViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.name = NSLocalizedString(@"Seating Plan", @"");
        self.tabBarIcon = @"school_class_seating_plan";
        
        UIBarButtonItem *clearButton = [UIBarButtonItem createCustomTintedTopBarButtonItem:@"clear"];
        [(UIButton *)clearButton.customView addTarget:self action:@selector(didPressClear:)
                                        forControlEvents:UIControlEventTouchUpInside];
        
        self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(didPressAction:)], clearButton];
    }
    return self;
}

- (NSString *)subTitle {
    return [NSString stringWithFormat:@"%@ - %@", self.name, self.schoolClass.parent.name];
}

- (void)viewDidLoad {
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.tileLayout = [TileLayoutViewController new];
    self.tileLayout.tileDataSources = (NSArray<TileViewControllerDataSource> *)self.schoolClass.student;
    
    [self addChildViewController:self.tileLayout];
    self.tileLayout.view.frame = self.view.bounds;
    [self.view addSubview:self.tileLayout.view];
}

- (void)viewDidDisappear:(BOOL)animated {
    [Utilities clearGeneratedFolder];
}

- (void)didPressAction:(id)sender {
    NSString *title = [SchoolClassSeatingPlanViewController documentTitle:self.schoolClass];
    NSString *filePath = [SchoolClassSeatingPlanViewController generatePDFSeatingPlan:self.schoolClass
                                                                               folder:[Utilities generatedFolder]];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:[fileURL path]]) {
        [ShareUtilities showPDFActivityView:title
                                        url:fileURL presenter:self.navigationController];
    }
}

- (void)didPressClear:(id)sender {
    [Common showConfirmation:self title:NSLocalizedString(@"Confirm Clearing", @"") message:NSLocalizedString(@"Do you irreversibly want to clear the seating plan?", @"") okButtonTitle:NSLocalizedString(@"Clear", @"") destructive:YES cancelButtonTitle:nil okHandler:^{
        [self.schoolClass clearStudentPositions];
        [self.tileLayout revalidate];
    } cancelHandler:nil];
}

+ (NSString *)generatePDFSeatingPlan:(SchoolClass *)schoolClass folder:(NSString *)folder {
    NSString *title = [SchoolClassSeatingPlanViewController documentTitle:schoolClass];
    NSString *filePath = [folder stringByAppendingPathComponent:[[title validFilePath] stringByAppendingPathExtension:kPDFExtension]];
    return [SchoolClassSeatingPlanViewController generatePDFSeatingPlan:schoolClass path:filePath];
}

+ (NSString *)generatePDFSeatingPlan:(SchoolClass *)schoolClass path:(NSString *)path {
    NSString *title = [SchoolClassSeatingPlanViewController documentTitle:schoolClass];
    NSString *dateString = [[Utilities shortDateTimeFormatter] stringFromDate:[NSDate date]];
    NSArray *content = [SchoolClassSeatingPlanViewController content:schoolClass];
    NSDictionary *settings = @{ kPDFTableCreatorFilePath : path,
                                kPDFTableCreatorHeader : title,
                                kPDFTableCreatorHorizontalAlignmentHeader : kPDFTableCreatorHorizontalAlignmentCenter,
                                kPDFTableCreatorFooter : dateString,
                                kPDFTableCreatorHorizontalAlignmentFooter : kPDFTableCreatorHorizontalAlignmentRight,
                                kPDFTableCreatorFooterTextColor : [UIColor grayColor],
                                kPDFTableCreatorColumns : content.count > 0 ? @([content[0] count]) : @(0),
                                kPDFTableCreatorRows : @(content.count),
                                kPDFTableCreatorImageBorderX : @(10),
                                kPDFTableCreatorImageBorderY : @(10),
                                kPDFTableCreatorCellPaddingX : @(5),
                                kPDFTableCreatorCellPaddingY : @(5),
                                kPDFTableCreatorCellRatio : @(1.2),
                                kPDFTableCreatorTableBorderStyle : kPDFTableCreatorTableBorderStyleDashed,
                                kPDFTableCreatorTableBorderColor : [UIColor grayColor],
                                kPDFTableCreatorTableTextColor : [UIColor blackColor],
                                kPDFTableCreatorTableBorderWidth : @(1),
                                kPDFTableCreatorHorizontalAlignmentText : kPDFTableCreatorHorizontalAlignmentCenter,
                                kPDFTableCreatorVerticalAlignmentText : kPDFTableCreatorVerticalAlignmentBottom,
                                kPDFTableCreatorHorizontalAlignmentImage : kPDFTableCreatorHorizontalAlignmentCenter,
                                kPDFTableCreatorVerticalAlignmentImage : kPDFTableCreatorVerticalAlignmentTop,
                                kPDFTableCreatorOrientationSupport : @(NO),
                                kPDFTableCreatorOptimalOrientation : @(YES),
                                kPDFTableCreatorContent : content
                                };
    PDFTableCreator *pdfTableCreator = [[PDFTableCreator alloc] initWithSettings:settings];
    [pdfTableCreator create];
    return path;
}

+ (NSString *)documentTitle:(SchoolClass *)schoolClass {
    return[[NSString alloc] initWithFormat:@"%@ - %@ - %@", NSLocalizedString(@"Seating Plan", @""), schoolClass.name, ((SchoolYear *)schoolClass.parent).name];
}

+ (NSArray *)content:(SchoolClass *)schoolClass {
    NSMutableArray *content = [@[] mutableCopy];
    
    NSArray *students = schoolClass.student;
    if (students.count > 0) {
        NSInteger minRow = INT_MAX;
        NSInteger maxRow = INT_MIN;
        NSInteger minColumn = INT_MAX;
        NSInteger maxColumn = INT_MIN;
        for (Student *student in students) {
            if (![student.positioned boolValue]) {
                continue;
            }
            minRow = MIN(minRow, [student.row integerValue]);
            maxRow = MAX(maxRow, [student.row integerValue]);
            minColumn = MIN(minColumn, [student.column integerValue]);
            maxColumn = MAX(maxColumn, [student.column integerValue]);
        }
        NSInteger columns = maxColumn - minColumn + 1;
        NSInteger rows = maxRow - minRow + 1;
        for (int j = 0; j < rows; j++) {
            NSMutableArray *row = [@[] mutableCopy];
            for (int i = 0; i < columns; i++) {
                [row addObject:@[]];
            }
            [content addObject:row];
        }
        for (Student *student in students) {
            if (![student.positioned boolValue]) {
                continue;
            }
            NSMutableArray *cellContent = [@[student.person.name] mutableCopy];
            if (student.photoUUID) {
                UIImage *photo = [student.photo.image resizeImage:
                                  CGSizeMake(kPhotoResolution, kPhotoResolution) scale:1.0f];
                [cellContent addObject:[photo roundImageClip]];
            } else {
                NSAttributedString *imageFill =
                    [PDFTableCreator attributedStringFill:kPDFTableCreatorAttributedStringFillCircle
                                               aspectMode:kPDFTableCreatorAttributedStringAspectModeSquare
                                                          scale:1.0f
                                                          fillColor:[UIColor lightGrayColor]
                                                          settings:@{}];
                [cellContent addObject:imageFill];
                if (student.person.nameInitials) {
                    NSAttributedString *initialsImage =
                        [PDFTableCreator attributedStringText:student.person.nameInitials fontSize:30.0f scale:1.0f color:[UIColor whiteColor] settings:@{}];
                    [cellContent addObject:initialsImage];
                } else {
                    // TODO: Add real icon (only icon, no background)
                    UIImage *personIcon = [UIImage imageNamed:@"initials_icon_person"];
                    NSAttributedString *imageIcon = [PDFTableCreator attributedStringIcon:personIcon scale:0.5f settings:@{}];
                    [cellContent addObject:imageIcon];
                }
            }
            content[[student.row integerValue]  - minRow][[student.column integerValue] - minColumn] = cellContent;
        }
    }
    return content;
}

- (void)createPDFFromUIView:(UIView *)view saveToFilPath:(NSString *)filePath {
    NSMutableData *pdfData = [NSMutableData data];
    UIGraphicsBeginPDFContextToData(pdfData, view.bounds, nil);
    UIGraphicsBeginPDFPage();
    CGContextRef pdfContext = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:pdfContext];
    UIGraphicsEndPDFContext();
    [pdfData writeToFile:filePath atomically:YES];
}

- (SchoolClass *)schoolClass {
    return (SchoolClass *)self.entity;
}

- (void)dealloc {
    [Utilities clearGeneratedFolder];
}

@end