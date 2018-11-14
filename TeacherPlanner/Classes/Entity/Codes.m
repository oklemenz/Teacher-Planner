//
//  Codes.m
//  TeacherPlanner
//
//  Created by Oliver on 25.05.14.
//
//

#import "Codes.h"

@implementation Codes

+ (NSInteger)codeCount:(NSString *)code {
    if ([code isEqualToString:kCodeSchoolYearType]) {
        return 3;
    } else if ([code isEqualToString:kCodePersonTitle]) {
        return 2;
    } else if ([code isEqualToString:kCodeGermanyState]) {
        return 16;
    } else if ([code isEqualToString:kCodeWeekDay]) {
        return 7;
    } else if ([code isEqualToString:kCodeSchoolWeekDay]) {
        return 3;
    } else if ([code isEqualToString:kCodeAnnotationType]) {
        return 5;
    } else if ([code isEqualToString:kCodeRating]) {
        return 6;
    } else if ([code isEqualToString:kCodeRequestPasscode]) {
        return 4;
    } else if ([code isEqualToString:kCodeReminderLesson]) {
        return 7;
    } else if ([code isEqualToString:kCodeReminderTimeOffset]) {
        return 21;
    }
    return [super codeCount:code];
}

@end