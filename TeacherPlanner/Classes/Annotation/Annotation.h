//
//  Annotation.h
//  TeacherPlanner
//
//  Created by Klemenz, Oliver on 25.07.14.
//
//

#import "JSONChildEntity.h"
#import "Codes.h"

@class AnnotationContainer;

@protocol AnnotationReminderLesson
- (NSDate *)dateForReminderLesson:(CodeReminderLesson)reminderLesson;
@end

@protocol Annotation
@end

@interface Annotation : JSONChildEntity <AnnotationReminderLesson>

@property (nonatomic) NSInteger type;
@property (nonatomic, strong) NSString *dataAttachmentUUID;
@property (nonatomic, strong) NSString *thumbnailAttachmentUUID;
@property (nonatomic) long long length;

@property (nonatomic, strong) NSDate *reminderDate;
@property (nonatomic, strong) NSDateComponents *reminderOffset;

@property (nonatomic, strong) NSDate *reminderFireDate;
@property (nonatomic, strong) UILocalNotification *reminder;

- (instancetype)initWithType:(CodeAnnotationType)type data:(NSData *)data thumbnail:(NSData *)thumbnail length:(NSInteger)length;

- (NSData *)data;
- (NSData *)thumbnail;

- (void)update:(NSData *)data thumbnail:(NSData *)thumbnail length:(NSInteger)length;

- (NSString *)text;
- (UIImage *)image;

- (UIImage *)iconImage;
- (NSString *)title;
- (NSString *)subTitle;

- (NSDate *)reminderFireDate:(NSDate *)date offset:(NSDateComponents *)offset;
- (void)scheduleReminder:(NSDate *)date offset:(NSDateComponents *)offset;
- (void)unscheduleReminder;
- (BOOL)isReminderActive;

- (void)cleanup;

- (AnnotationContainer *)annotationContainer;
- (JSONEntity *)entity;

@end