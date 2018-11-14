//
//  Annotation.m
//  TeacherPlanner
//
//  Created by Klemenz, Oliver on 25.07.14.
//
//

#import "Annotation.h"
#import "Attachment.h"
#import "Model.h"
#import "Application.h"
#import "Utilities.h"
#import "Configuration.h"
#import "UIImage+Extension.h"

@implementation Annotation

- (instancetype)initWithType:(CodeAnnotationType)type data:(NSData *)data thumbnail:(NSData *)thumbnail length:(NSInteger)length {
    self = [self init];
    if (self) {
        _type = type;
        [self update:data thumbnail:thumbnail length:length];
    }
    return self;
}

- (NSData *)data {
    if (self.dataAttachmentUUID) {
        return [[Model instance].application attachmentByUUID:self.dataAttachmentUUID].data;
    }
    return nil;
}

- (NSData *)thumbnail {
    if (self.thumbnailAttachmentUUID) {
        return [[Model instance].application attachmentByUUID:self.thumbnailAttachmentUUID].data;
    }
    return nil;
}

- (void)update:(NSData *)data thumbnail:(NSData *)thumbnail length:(NSInteger)length {
    if (!self.dataAttachmentUUID && data) {
        [self setProperty:@"dataAttachmentUUID" value:
            [[[Model instance].application addAggregation:@"attachment" parameters:@{ @"data" : data}] uuid]];
    } else if (self.dataAttachmentUUID) {
        [[[Model instance].application attachmentByUUID:self.dataAttachmentUUID] setProperty:@"data" value:data];
    }
    if (!self.thumbnailAttachmentUUID && thumbnail) {
        [self setProperty:@"thumbnailAttachmentUUID" value:
            [[[Model instance].application addAggregation:@"attachment" parameters:@{ @"data" : thumbnail}] uuid]];
    } else if (self.thumbnailAttachmentUUID) {
        [[[Model instance].application attachmentByUUID:self.thumbnailAttachmentUUID] setProperty:@"data" value:data];
    }
    [self setProperty:@"length" value:@(length)];
}

- (void)cleanup {
    if (self.dataAttachmentUUID) {
        [[Model instance].application removeAggregation:@"attachment" uuid:self.dataAttachmentUUID];
    }
    if (self.thumbnailAttachmentUUID) {
        [[Model instance].application removeAggregation:@"attachment" uuid:self.thumbnailAttachmentUUID];
    }
}

- (NSString *)text {
    if (self.type == CodeAnnotationTypeText) {
        return [[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding];
    }
    return nil;
}

- (UIImage *)image {
    if (self.type == CodeAnnotationTypePhoto ||
        self.type == CodeAnnotationTypeImage) {
        return [UIImage imageWithData:self.data];
    }
    return nil;
}

- (UIImage *)iconImage {
    UIImage *iconImage = nil;
    if (self.type == CodeAnnotationTypeImage || self.type == CodeAnnotationTypePhoto) {
        iconImage = [UIImage imageWithData:self.thumbnail];
    } else if (self.type == CodeAnnotationTypeAudio) {
        iconImage = [[UIImage imageNamed:@"audio"] tintImageWithColor:[Configuration instance].highlightColor];
    } else if (self.type == CodeAnnotationTypeText) {
        iconImage = [[UIImage imageNamed:@"text"] tintImageWithColor:[Configuration instance].highlightColor];
    } else if (self.type == CodeAnnotationTypeVideo) {
        iconImage = [[UIImage imageWithData:self.thumbnail] blendImage:[UIImage imageNamed:@"text"] alpha:0.8];
    }
    return iconImage;
}

- (NSString *)title {
    NSString *title = @"";
    if (self.type == CodeAnnotationTypeImage || self.type == CodeAnnotationTypePhoto) {
        title = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"File Size", @""), [Utilities formatFileSize:@(self.length)]];
    } else if (self.type == CodeAnnotationTypeAudio) {
        title = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Duration", @""), [Utilities formatSecondsText:(long)self.length]];
    } else if (self.type == CodeAnnotationTypeText) {
        title = [self.text stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    } else if (self.type == CodeAnnotationTypeVideo) {
        title = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Duration", @""), [Utilities formatSeconds:(long)self.length]];
    }
    return title;
}

- (NSString *)subTitle {
    NSString *subTitle = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Created", @""), [[Utilities timeFormatter] stringFromDate:self.createdAt]];
    NSTimeInterval timeDifference = [self.changedAt timeIntervalSinceDate:self.createdAt];
    if (fabs(timeDifference) > 1) {
        if ([[Utilities calendar] isDate:self.createdAt inSameDayAsDate:self.changedAt]) {
            subTitle = [subTitle stringByAppendingFormat:@" - %@: %@", NSLocalizedString(@"Changed", @""),
                        [[Utilities timeFormatter] stringFromDate:self.changedAt]];
        } else {
            subTitle = [subTitle stringByAppendingFormat:@" - %@: %@", NSLocalizedString(@"Changed", @""),
                        [[Utilities relativeDateTimeFormatter] stringFromDate:self.changedAt]];
        }
    }
    return subTitle;
}

- (void)scheduleReminder:(NSDate *)reminderDate offset:(NSDateComponents *)reminderOffset {
    [self unscheduleReminder];
    [self setProperty:@"reminderDate" value:reminderDate];
    [self setProperty:@"reminderOffset" value:reminderOffset];
    NSDate *fireDate = [self reminderFireDate:reminderDate offset:reminderOffset];
    if (fireDate) {
        UILocalNotification *localNotification = [UILocalNotification new];
        localNotification.fireDate = fireDate;
        localNotification.timeZone = [NSTimeZone defaultTimeZone];
        localNotification.alertBody = NSLocalizedString(@"You have set a reminder for an annotation.", @"");
        localNotification.alertAction = NSLocalizedString(@"View", @"");
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        localNotification.applicationIconBadgeNumber = 1;
        localNotification.userInfo = @{ @"entityPath" : self.entityPath };
        
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        
        [self setProperty:@"reminderFireDate" value:fireDate];
        [self setProperty:@"reminder" value:localNotification];
    }
}

- (NSDate *)reminderFireDate:(NSDate *)date offset:(NSDateComponents *)offset {
    NSCalendar *calendar = [Utilities calendar];
    NSDateComponents *dateComponents = [calendar components:( NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay ) fromDate:date];
    NSDateComponents *timeComponents = [calendar components:( NSCalendarUnitHour | NSCalendarUnitMinute )
                                                   fromDate:date];
    NSDateComponents *components = [NSDateComponents new];
    [components setDay:[dateComponents day]];
    [components setMonth:[dateComponents month]];
    [components setYear:[dateComponents year]];
    [components setHour:[timeComponents hour]];
    [components setMinute:[timeComponents minute]];
    
    NSDate *fireDate = [calendar dateFromComponents:components];
    if (offset) {
        fireDate = [calendar dateByAddingComponents:offset toDate:fireDate options:0];
    }
    if ([[NSDate date] compare:fireDate] == NSOrderedAscending) {
        return fireDate;
    }
    return nil;
}

- (void)unscheduleReminder {
    [self setProperty:@"reminderFireDate" value:nil];
    [self setProperty:@"reminderDate" value:nil];
    [self setProperty:@"reminderOffset" value:nil];
    if (self.reminder) {
        [[UIApplication sharedApplication] cancelLocalNotification:self.reminder];
    }
    [self setProperty:@"reminder" value:nil];
}

- (BOOL)isReminderActive {
    return [self reminderFireDate:self.reminderDate offset:self.reminderOffset] != nil;
}

- (NSDate *)dateForReminderLesson:(CodeReminderLesson)reminderLesson {
    if ([self.parent conformsToProtocol:@protocol(AnnotationReminderLesson)]) {
        return [(JSONEntity<AnnotationReminderLesson> *)self.parent dateForReminderLesson:reminderLesson];
    }
    return nil;
}

- (AnnotationContainer *)annotationContainer {
    return (AnnotationContainer *)self.parent;
}

- (JSONEntity *)entity {
    return self.parent.parent;
}

@end