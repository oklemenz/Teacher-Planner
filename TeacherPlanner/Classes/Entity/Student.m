//
//  Student.m
//  TeacherPlanner
//
//  Created by Oliver on 29.12.13.
//
//

#import "Student.h"
#import "Model.h"
#import "Person.h"
#import "Application.h"
#import "NSString+Extension.h"

@implementation Student {
    Person *_person;
}

- (void)setup:(BOOL)isNew {
    if (!self.annotation) {
        self.annotation = [AnnotationContainer new];
    }
    self.annotation.parent = self;
    
    if (isNew) {
        _positioned = @(NO);
    }
}

- (void)setProperty:(NSString *)name value:(id)value trigger:(PropertyBinding *)trigger force:(BOOL)force {
    NSString *personUUID = nil;
    if ([name isEqualToString:@"personUUID"]) {
        personUUID = self.personUUID;
    }
    [super setProperty:name value:value trigger:trigger force:force];
    if (personUUID) {
        [[Model instance].application removePersonUsage:personUUID];
        if (self.personUUID) {
            [[Model instance].application addPersonUsage:self.personUUID];
        }
    }
}

- (void)setPersonUUID:(NSString *)personUUID {
    _personUUID = personUUID;
    [self invalidateContext:@"person" userInfo:@{ @"property" : @"personUUID",
                                                  @"value" : personUUID ? personUUID : [NSNull null] }];
}

- (NSString *)name {
    return self.person.name;
}

- (Person *)person {
    return [[[Model instance] application] personByUUID:self.personUUID];
}

- (Photo *)photo {
    return self.person.photo;
}

- (NSString *)nameInitials {
    return self.person.nameInitials;
}

+ (NSString *)exportCSVHeaderString {
    return [NSString stringWithFormat:@"%@;%@;%@;%@;%@;%@",
            NSLocalizedString(@"Name", @""),
            NSLocalizedString(@"Address", @""),
            NSLocalizedString(@"E-Mail", @""),
            NSLocalizedString(@"Phone", @""),
            NSLocalizedString(@"Row", @""),
            NSLocalizedString(@"Seat", @"")];
}

- (NSString *)exportCSVString {
    return [NSString stringWithFormat:@"%@;%@;%@;%@;%@;%@",
            [NSString nilToEmpty:self.name],
            [NSString nilToEmpty:self.person.address],
            [NSString nilToEmpty:self.person.email],
            [NSString nilToEmpty:self.person.phone],
            [NSString nilToEmpty:self.row],
            [NSString nilToEmpty:self.column]];
}

- (NSData *)exportCSVData {
    return [[self exportCSVString] dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSDictionary *)exportXLSData {
    return @{ @"CELL" : @[
                      @{
                       @"CONTENT_STYLE" : @"s65",
                       @"CONTENT_TYPE" : @"String",
                       @"CONTENT" : [NSString nilToEmpty:self.name],
                       },
                      @{
                       @"CONTENT_STYLE" : @"s65",
                       @"CONTENT_TYPE" : @"String",
                       @"CONTENT" : [NSString nilToEmpty:self.person.address],
                       },
                      @{
                       @"CONTENT_STYLE" : @"s65",
                       @"CONTENT_TYPE" : @"String",
                       @"CONTENT" : [NSString nilToEmpty:self.person.email],
                       },
                      @{
                       @"CONTENT_STYLE" : @"s65",
                       @"CONTENT_TYPE" : @"String",
                       @"CONTENT" : [NSString nilToEmpty:self.person.phone],
                       },
                      @{
                       @"CONTENT_STYLE" : @"s65",
                       @"CONTENT_TYPE" : @"Number",
                       @"CONTENT" : [NSString nilToEmpty:self.row],
                       },
                      @{
                       @"CONTENT_STYLE" : @"s65",
                       @"CONTENT_TYPE" : @"Number",
                       @"CONTENT" : [NSString nilToEmpty:self.column],
                       }] };
}

- (BOOL)importCSVString:(NSString *)csvString {
    // TODO: Implement
    return YES;
}

- (BOOL)importCSVData:(NSData *)csvData {
    return [self importCSVString:[[NSString alloc] initWithData:csvData encoding:NSUTF8StringEncoding]];
}

- (void)willBeRemoved {
    [super willBeRemoved];
    [[[Model instance] application] removePersonUsage:self.personUUID];
}

#pragma mark - TileViewControllerDataSource

- (NSString *)tileName {
    return self.person.name;
}

- (BOOL)tileShowNameInitials {
    return !self.person.photoUUID && self.person.nameInitials;
}

- (UIImage *)tileImage {
    if (self.person.photoUUID) {
        return self.photo.image;
    } else {
        // TODO: Use larger icon graphics
        if (self.nameInitials) {
            return [UIImage imageNamed:@"initials_icon"];
        } else {
            return [UIImage imageNamed:@"initials_icon_person"];
        }
    }
    return nil;
}

- (BOOL)tilePositioned {
    return [self.positioned boolValue];
}

- (void)setTilePositioned:(BOOL)positioned {
    [self setProperty:@"positioned" value:@(positioned)];
}

- (NSInteger)tileRow {
    return [self.row integerValue];
}

- (void)setTileRow:(NSInteger)tileRow {
    [self setProperty:@"row" value:@(tileRow)];
}

- (NSInteger)tileColumn {
    return [self.column integerValue];
}

- (void)setTileColumn:(NSInteger)tileColumn {
    [self setProperty:@"column" value:@(tileColumn)];
}

- (id)copyWithZone:(NSZone *)zone {
    Student *studentCopy = [Student new];
    [studentCopy setup:YES];
    studentCopy.personUUID = self.personUUID;
    studentCopy.positioned = self.positioned;
    studentCopy.rating = self.rating;
    studentCopy.row = self.row;
    studentCopy.column = self.column;
    return studentCopy;
}

- (NSDate *)dateForReminderLesson:(CodeReminderLesson)reminderLesson {
    if ([self.parent conformsToProtocol:@protocol(AnnotationReminderLesson)]) {
        return [(JSONEntity<AnnotationReminderLesson> *)self.parent dateForReminderLesson:reminderLesson];
    }
    return nil;
}

#pragma mark - ANNOTATION

- (AnnotationContainer *)annotationByUUID:(NSString *)uuid {
    if ([self.annotation.uuid isEqual:uuid]) {
        return self.annotation;
    }
    return nil;
}

@end