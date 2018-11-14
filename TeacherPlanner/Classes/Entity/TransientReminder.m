//
//  TransientReminder.m
//  TeacherPlanner
//
//  Created by Oliver Klemenz on 01.05.15.
//
//

#import "TransientReminder.h"
#import "Utilities.h"
#import "Codes.h"

static NSArray *reminderOffsets;

@implementation TransientReminder

+ (void)initialize {
    reminderOffsets = @[@(-2880), @(-1440), @(-120), @(-90), @(-60), @(-45), @(-30), @(-15), @(-10), @(-5), @(0),
                        @(5), @(10), @(15), @(30), @(45), @(60), @(90), @(120), @(1440), @(2880)];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _lesson = 0;
        _date = [NSDate new];
        NSDateComponents *dateComponents = [NSDateComponents new];
        [dateComponents setDay:1];
        _date = [[Utilities calendar] dateByAddingComponents:dateComponents toDate:_date options:0];
        _offset = CodeReminderTimeOffset0Minutes;
        [self updateStatus];
    }
    return self;
}

- (void)setLesson:(NSInteger)lesson {
    _lesson = lesson;
    if (lesson > 0) {
        NSDate *date = [self.annotation dateForReminderLesson:lesson];
        if (date) {
            [self setProperty:@"date" value:date];
            [self setProperty:@"lesson" value:@(lesson)];
        } else {
            [self setProperty:@"lesson" value:@(0)];
        }
    }
    [self updateStatus];
}

- (void)setDate:(NSDate *)date {
    _date = date;
    [self setProperty:@"lesson" value:@(0)];
    [self updateStatus];
}

- (void)setOffset:(NSInteger)offset {
    _offset = offset;
    [self updateStatus];
}

- (void)setAnnotation:(Annotation *)annotation {
    _annotation = annotation;
    if (annotation.reminderDate) {
        [self setProperty:@"date" value:annotation.reminderDate];
        NSInteger offset = [reminderOffsets indexOfObject:@(annotation.reminderOffset.minute)];
        if (offset >= 0) {
            [self setProperty:@"offset" value:@(offset + 1)];
        }
    }
    [self updateStatus];
}

- (void)updateStatus {
    NSDateComponents *offsetDateComponents = [NSDateComponents new];
    [offsetDateComponents setMinute:[reminderOffsets[self.offset - 1] integerValue]];
    NSDate *fireDate = [self.annotation reminderFireDate:self.date offset:offsetDateComponents];
    NSString *status;
    if (fireDate) {
        status = [NSString stringWithFormat:NSLocalizedString(@"Remind on %@", @""), [[Utilities dateTimeFormatter] stringFromDate:fireDate]];
    } else {
        status = NSLocalizedString(@"Reminder date is in the past", @"");
    }
    [self setProperty:@"fireDate" value:fireDate];
    [self setProperty:@"offsetDateComponents" value:offsetDateComponents];
    [self setProperty:@"status" value:status];
}

@end