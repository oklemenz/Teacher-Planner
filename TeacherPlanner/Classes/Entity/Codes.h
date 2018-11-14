//
//  Codes.h
//  TeacherPlanner
//
//  Created by Oliver on 25.05.14.
//
//

#import "CodesBase.h"

#define kCodeSchoolYearType     @"CodeSchoolYearType"
#define kCodePersonTitle        @"CodePersonTitle"
#define kCodeGermanyState       @"CodeGermanyState"
#define kCodeWeekDay            @"CodeWeekDay"
#define kCodeSchoolWeekDay      @"CodeSchoolWeekDay"
#define kCodeAnnotationType     @"CodeAnnotationType"
#define kCodeRating             @"CodeRating"
#define kCodeRequestPasscode    @"CodeRequestPasscode"
#define kCodeReminderLesson     @"CodeReminderLesson"
#define kCodeReminderTimeOffset @"CodeReminderTimeOffset"

typedef enum CodeSchoolYearType : NSUInteger {
    CodeSchoolYearTypeActive    = 1,
    CodeSchoolYearTypePlanned   = 2,
    CodeSchoolYearTypeCompleted = 3,
} CodeSchoolYearType;

typedef enum CodePersonTitle : NSUInteger {
    CodePersonTitleMr  = 1,
    CodePersonTitleMrs = 2,
} CodePersonTitle;

typedef enum CodeGermanyState : NSUInteger {
    CodeGermanyStateBadenWuerttemberg = 1,
    CodeGermanyStateBayern = 2,
    CodeGermanyStateBerlin = 3,
    CodeGermanyStateBrandenburg = 4,
    CodeGermanyStateBremen = 5,
    CodeGermanyStateHamburg = 6,
    CodeGermanyStateHessen = 7,
    CodeGermanyStateMecklenburgVorpommern = 8,
    CodeGermanyStateNiedersachsen = 9,
    CodeGermanyStateNordrheinWestfalen = 10,
    CodeGermanyStateRheinlandPfalz = 11,
    CodeGermanyStateSaarland = 12,
    CodeGermanyStateSachsen = 13,
    CodeGermanyStateSachsenAnhalt = 14,
    CodeGermanyStateSchleswigHolstein = 15,
    CodeGermanyStateThueringen = 16
} CodeGermanyState;

typedef enum CodeWeekDay : NSUInteger {
    CodeWeekDayMonday = 1,
    CodeWeekDayTuesday = 2,
    CodeWeekDayWednesday = 3,
    CodeWeekDayThursday = 4,
    CodeWeekDayFriday = 5,
    CodeWeekDaySaturday = 6,
    CodeWeekDaySunday = 7
} CodeWeekDay;

typedef enum CodeSchoolWeekDay : NSUInteger {
    CodeSchoolWeekDayMonFri = 1,
    CodeSchoolWeekDayMonSat = 2,
    CodeSchoolWeekDayMonSun = 3,
} CodeSchoolWeekDay;

typedef enum CodeAnnotationType : NSUInteger {
    CodeAnnotationTypeText = 1,
    CodeAnnotationTypePhoto = 2,
    CodeAnnotationTypeImage = 3,
    CodeAnnotationTypeAudio = 4,
    CodeAnnotationTypeVideo = 5,
} CodeAnnotationType;

typedef enum CodeRating : NSUInteger {
    CodeRating1 = 1,
    CodeRating2 = 2,
    CodeRating3 = 3,
    CodeRating4 = 4,
    CodeRating5 = 5,
    CodeRating6 = 6
} CodeRating;

typedef enum CodeRequestPasscode : NSUInteger {
    CodeRequestPasscodeImmediately = 1,
    CodeRequestPasscodeAfter1Minute = 2,
    CodeRequestPasscodeAfter5Minute = 3,
    CodeRequestPasscodeAfter10Minute = 4
} CodeRequestPasscode;

typedef enum CodeReminderLesson : NSUInteger {
    CodeReminderLessonNext = 1,
    CodeReminderLessonAfterNext = 2,
    CodeReminderLessonLastThisWeek = 3,
    CodeReminderLessonFirstNextWeek = 4,
    CodeReminderLessonLastNextWeek = 5,
    CodeReminderLessonFirstWeekAfterNext = 6,
    CodeReminderLessonLastWeekAfterNext = 7
} CodeReminderLesson;

typedef enum CodeReminderTimeOffset : NSUInteger {
    CodeReminderTimeOffsetBefore2Days = 1,
    CodeReminderTimeOffsetBefore1Day = 2,
    CodeReminderTimeOffsetBefore2Hours = 3,
    CodeReminderTimeOffsetBefore1_5Hours = 4,
    CodeReminderTimeOffsetBefore1Hour = 5,
    CodeReminderTimeOffsetBefore45Minutes = 6,
    CodeReminderTimeOffsetBefore30Minutes = 7,
    CodeReminderTimeOffsetBefore15Minutes = 8,
    CodeReminderTimeOffsetBefore10Minutes = 9,
    CodeReminderTimeOffsetBefore5Minutes = 10,
    CodeReminderTimeOffset0Minutes = 11,
    CodeReminderTimeOffsetAfter5Minutes = 12,
    CodeReminderTimeOffsetAfter10Minutes = 13,
    CodeReminderTimeOffsetAfter15Minutes = 14,
    CodeReminderTimeOffsetAfter30Minutes = 15,
    CodeReminderTimeOffsetAfter45Minutes = 16,
    CodeReminderTimeOffsetAfter1Hour = 17,
    CodeReminderTimeOffsetAfter1_5Hour = 18,
    CodeReminderTimeOffsetAfter2Hours = 19,
    CodeReminderTimeOffsetAfter1Day = 20,
    CodeReminderTimeOffsetAfter2Days = 21
} CodeReminderTimeOffset;

@interface Codes : CodesBase
@end