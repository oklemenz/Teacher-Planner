//
//  ExportCalendarActivity.m
//  TeacherPlanner
//
//  Created by Oliver on 20.06.14.
//
//

#import "ExportCalendarActivity.h"

static NSString * const ActivityCalendarExport = @"de.oklemenz.activity.calender.export";

@implementation ExportCalendarActivity

+ (UIActivityCategory)activityCategory {
    return UIActivityCategoryAction;
}

- (NSString *)activityType {
    return ActivityCalendarExport;
}

- (NSString *)activityTitle {
    return NSLocalizedString(@"Export to Calendar", @"");
}

- (UIImage *)activityImage {
    // TODO: Use correct icon...
    return [UIImage imageNamed:@"settings"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
}

- (UIViewController *)activityViewController {
    return nil;
}

- (void)performActivity {
    // TOOD: Export to Calendar, check for already existing calendar entries
    [self activityDidFinish:YES];
}

@end
