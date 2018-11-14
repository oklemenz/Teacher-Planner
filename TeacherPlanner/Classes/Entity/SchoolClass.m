//
//  SchoolClass.m
//  TeacherPlanner
//
//  Created by Oliver on 29.12.13.
//
//

#import "SchoolClass.h"
#import "SchoolClassSeatingPlanViewController.h"
#import "Model.h"
#import "Application.h"
#import "SchoolYear.h"
#import "Photo.h"
#import "Utilities.h"
#import "NSString+Extension.h"
#import "XLSFileCreator.h"

@implementation SchoolClass {
    NSMutableArray *_studentNameInitials;
    NSMutableDictionary *_studentsByInitial;
}

- (void)setup:(BOOL)isNew {
    if (!self.annotation) {
        self.annotation = [AnnotationContainer new];
    }
    self.annotation.parent = self;

    if (!self.lesson) {
        self.lesson = (NSMutableArray<Lesson> *)[@[] mutableCopy];
    }
    
    for (Lesson *lesson in self.lesson) {
        lesson.parent = self;
    }
    
    [self sortLesson];
    
    if (!self.student) {
        self.student = [@[] mutableCopy];
    }

    _studentNameInitials = [@[ @"" ] mutableCopy];
    _studentsByInitial = [@{ @"" : [@[] mutableCopy] } mutableCopy];
    
    if (isNew) {
        self.name = @"";
        self.subject = @"";
        self.color = kSchoolClassDefaultColor;
    }
    
    for (SchoolClass *student in self.student) {
        student.parent = self;
    }
    [self sortStudent];
}

- (Photo *)getPhoto {
    if (self.photoUUID) {
        return [[Model instance].application photoByUUID:self.photoUUID];
    }
    return nil;
}

#pragma mark - LESSON

- (NSInteger)numberOfLesson {
    return self.lesson.count;
}

- (NSInteger)lessonIndexByUUID:(NSString *)uuid {
    NSInteger index = 0;
    for (Lesson *lesson in self.lesson) {
        if ([lesson.uuid isEqualToString:uuid]) {
            return index;
        }
        index++;
    }
    return index;
}

- (Lesson *)lessonByIndex:(NSInteger)index {
    return [self.lesson objectAtIndex:index];
}

- (Lesson *)lessonByUUID:(NSString *)uuid {
    for (Lesson *lesson in self.lesson) {
        if ([lesson.uuid isEqualToString:uuid]) {
            return lesson;
        }
    }
    return nil;
}

- (Lesson *)addLesson {
    Lesson *lesson = [Lesson new];
    [self insertLesson:lesson];
    return lesson;
}

- (void)insertLesson:(Lesson *)lesson {
    [self.lesson addObject:lesson];
    lesson.parent = self;
}

- (void)removeLessonByUUID:(NSString *)uuid {
    [self removeLesson:[self lessonByUUID:uuid]];
}

- (void)removeLesson:(Lesson *)lesson {
    [self.lesson removeObject:lesson];
}

- (void)sortLesson {
    self.lesson = [[self.lesson sortedArrayUsingComparator:^NSComparisonResult(id l1, id l2) {
        Lesson *lesson1 = (Lesson *)l1;
        Lesson *lesson2 = (Lesson *)l2;
        if (lesson1.weekDay < lesson2.weekDay) {
            return NSOrderedAscending;
        } else if (lesson1.weekDay > lesson2.weekDay) {
            return NSOrderedDescending;
        } else {
            if (lesson1.timeStart < lesson2.timeStart) {
                return NSOrderedAscending;                
            } else if (lesson1.timeStart > lesson2.timeStart) {
                return NSOrderedDescending;
            } else {
                return NSOrderedSame;
            }
        }
    }] mutableCopy];
}

#pragma mark - STUDENT

- (NSInteger)numberOfStudent {
    return self.student.count;
}

- (NSInteger)numberOfStudentGroup {
    return _studentNameInitials.count;
}

- (NSInteger)numberOfStudentByGroup:(NSInteger)group {
    NSString *initial = _studentNameInitials[group];
    if (_studentsByInitial[initial]) {
        return [_studentsByInitial[initial] count];
    }
    return 0;
}

- (NSInteger)numberOfStudentByGroupName:(NSString *)groupName {
    if (_studentsByInitial[groupName]) {
        return [_studentsByInitial[groupName] count];
    }
    return 0;
}

- (NSString *)studentGroupName:(NSInteger)group {
    if (group >= 0 && group < _studentNameInitials.count) {
        return _studentNameInitials[group];
    }
    return nil;
}

- (NSIndexPath *)studentGroupIndexByUUID:(NSString *)uuid {
    NSInteger group = 0;
    for (NSString *initial in _studentNameInitials) {
        NSInteger index = 0;
        for (SchoolYearRef *student in _studentsByInitial[initial]) {
            if ([student.uuid isEqualToString:uuid]) {
                return [NSIndexPath indexPathForRow:index inSection:group];
            }
            index++;
        }
        group++;
    }
    return nil;
}

- (Student *)studentByGroup:(NSInteger)group index:(NSInteger)index {
    if (group >= 0 && group < _studentNameInitials.count) {
        NSString *initial = _studentNameInitials[group];
        if (index >= 0 && index < [_studentsByInitial[initial] count]) {
            return _studentsByInitial[initial][index];
        }
    }
    return nil;
}

- (Student *)studentByUUID:(NSString *)uuid {
    for (Student *student in self.student) {
        if ([student.uuid isEqual:uuid]) {
            return student;
        }
    }
    return nil;
}

- (Student *)addStudent:(NSDictionary *)parameters {
    NSString *personUUID = parameters[@"personUUID"];
    for (Student *student in self.student) {
        if ([student.personUUID isEqual:personUUID]) {
            return student;
        }
    }
    Student *student = [Student new];
    student.personUUID = personUUID;
    [self insertStudent:student];
    return student;
}

- (void)insertStudent:(Student *)student {
    [_studentsByInitial[@""] insertObject:student atIndex:0];
    [[[Model instance] application] addPersonUsage:student.personUUID];
    [self.student addObject:student];
    student.parent = self;
}

- (void)removeStudentByUUID:(NSString *)uuid {
    [self removeStudent:[self studentByUUID:uuid]];
}

- (void)removeStudent:(Student *)student {
    [student willBeRemoved];
    for (NSString *initial in _studentNameInitials) {
        if ([_studentsByInitial[initial] containsObject:student]) {
            [_studentsByInitial[initial] removeObject:student];
            if ([_studentsByInitial[initial] count] == 0 && ![initial isEqualToString:@""]) {
                [_studentsByInitial removeObjectForKey:initial];
                [_studentNameInitials removeObject:initial];
            }
            break;
        }
    }
    [self.student removeObject:student];
}

- (void)sortStudent {
    _studentNameInitials = [@[ @"" ] mutableCopy];
    _studentsByInitial = [@{ @"" : [@[] mutableCopy] } mutableCopy];
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    self.student = [[self.student sortedArrayUsingDescriptors:@[sort]] mutableCopy];
    
    for (Student *student in self.student) {
        NSString *initial = [(student.person.name.length > 0 ? [student.person.name substringToIndex:1] : @"") uppercaseString];
        NSMutableArray *studentsByInitial = _studentsByInitial[initial];
        if (!studentsByInitial) {
            studentsByInitial = [@[] mutableCopy];
            _studentsByInitial[initial] = studentsByInitial;
            [_studentNameInitials addObject:initial];
        }
        [studentsByInitial addObject:student];
    }
    _studentNameInitials = [[_studentNameInitials sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] mutableCopy];
}

#pragma mark - ANNOTATION

- (AnnotationContainer *)annotationByUUID:(NSString *)uuid {
    if ([self.annotation.uuid isEqual:uuid]) {
        return self.annotation;
    }
    return nil;
}

#pragma mark - MISC

- (void)clearStudentPositions {
    for (Student *student in self.student) {
        [student setProperty:@"row" value:nil];
        [student setProperty:@"column" value:nil];
        [student setProperty:@"positioned" value:@(NO)];
    }
}

- (NSString *)exportCSVString {
    [self sortStudent];
    [self normalizeStudentPosition];
    NSString *exportCSV = [NSString stringWithFormat:@"%@;%@", NSLocalizedString(@"No.", @""),
                           [Student exportCSVHeaderString]];
    NSInteger index = 1;
    for (Student *student in self.student) {
        if (exportCSV.length == 0) {
            exportCSV = [student exportCSVString];
        } else {
            exportCSV = [exportCSV stringByAppendingFormat:@"\n%tu;%@", index, [student exportCSVString]];
        }
        index++;
    }
    return exportCSV;
}

- (NSData *)exportCSVData {
    return [[self exportCSVString] dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSDictionary *)exportXLSData {
    [self sortStudent];
    [self normalizeStudentPosition];

    NSArray *columnNames = [[Student exportCSVHeaderString] componentsSeparatedByString:@";"];
    NSMutableArray *columns = [@[] mutableCopy];
    for (NSString *columnName in columnNames) {
        [columns addObject:@{
                             @"CAPTION_STYLE" : @"s62",
                             @"CAPTION" : columnName }];
    }
    NSMutableArray *rows = [@[] mutableCopy];
    for (Student *student in self.student) {
        [rows addObject:[student exportXLSData]];
    }
    return @{ @"AUTHOR" : [Model instance].application.settings.teacher.name,
              @"CREATED" : [[Utilities isoDateFormatter] stringFromDate:[NSDate new]],
              @"FONT_NAME" : @"Calibri",
              @"FONT_FAMILY" : @"Swiss",
              @"FONT_SIZE" : @(12),
              @"FONT_COLOR" : @"#000000",
              @"NAME" : self.name,
              @"COLUMN" : columns,
              @"ROW" : rows,
              @"COLUMN_COUNT" : @(columns.count),
              @"ROW_COUNT" : @(rows.count + 1) };
}

- (BOOL)importCSVString:(NSString *)csvString {
    // TODO: Implement
    return YES;
}

- (BOOL)importCSVData:(NSData *)csvData {
    return [self importCSVString:[[NSString alloc] initWithData:csvData encoding:NSUTF8StringEncoding]];
}

- (void)importXLSData:(NSURL *)xlsData {
    // TODO: Parse XML
}

- (void)normalizeStudentPosition {
    if (self.student.count > 0) {
        NSInteger minRow = INT_MAX;
        NSInteger minColumn = INT_MAX;
        for (Student *student in self.student) {
            if (![student.positioned boolValue]) {
                [student setProperty:@"row" value:nil];
                [student setProperty:@"column" value:nil];
                continue;
            }
            minRow = MIN(minRow, [student.row integerValue]);
            minColumn = MIN(minColumn, [student.column integerValue]);
        }
        for (Student *student in self.student) {
            if ([student.positioned boolValue]) {
                [student setProperty:@"row" value:@([student.row integerValue] - minRow + 1)];
                [student setProperty:@"column" value:@([student.column integerValue] - minColumn + 1)];
            }
        }
    }
}

- (void)willBeRemoved {
    [super willBeRemoved];
    for (Student *student in self.student) {
        [student willBeRemoved];
    }
}

- (id)copyWithZone:(NSZone *)zone {
    SchoolClass *schoolClassCopy = [SchoolClass new];
    schoolClassCopy.lesson = [@[] mutableCopy];
    for (Lesson *lesson in self.lesson) {
        [schoolClassCopy insertLesson:[lesson copy]];
    }
    schoolClassCopy.student = [@[] mutableCopy];
    for (Student *student in self.student) {
        [schoolClassCopy insertStudent:[student copy]];
    }
    [schoolClassCopy setup:YES];
    schoolClassCopy.name = [NSString stringWithFormat:@"%@*", self.name];
    schoolClassCopy.subject = self.subject;
    schoolClassCopy.photoUUID = self.photoUUID;
    schoolClassCopy.classroom = self.classroom;
    schoolClassCopy.color = self.color;
    return schoolClassCopy;
}

+ (NSString *)exportSchoolClass:(SchoolClass *)schoolClass password:(NSString *)password temp:(BOOL)temp {
    NSString *folderName = [Utilities createTempFolder];
    NSString *folderPath = [[Utilities generatedFolder] stringByAppendingPathComponent:folderName];
    
    NSString *filename = [[NSString stringWithFormat:@"%@_%@", schoolClass.name, schoolClass.parent.name] validFilePath];
    NSString *csvPath = [filename stringByAppendingPathExtension:kCSVExtension];
    NSString *xlsPath = [filename stringByAppendingPathExtension:kXLSExtension];
    NSString *pdfPath = [filename stringByAppendingPathExtension:kPDFExtension];
    
    NSData *data = [schoolClass exportCSVData];
    [Utilities writeGeneratedFile:data path:[folderName stringByAppendingPathComponent:csvPath]];

    XLSFileCreator *xlsFileCreator = [[XLSFileCreator alloc] initWithData:[schoolClass exportXLSData]];
    [xlsFileCreator create:xlsPath fileTemplate:@"student"];

    [SchoolClassSeatingPlanViewController generatePDFSeatingPlan:schoolClass path:[folderPath stringByAppendingPathComponent:pdfPath]];
    
    NSInteger index = 1;
    for (Student *student in schoolClass.student) {
        if (student.photoUUID) {
            NSString *photoPath = [[[NSString stringWithFormat:@"%tu. %@", index, student.person.name] stringByAppendingPathExtension:kJPGExtension] validFilePath];
            [Utilities writeGeneratedFile:[student photo].data path:[folderName stringByAppendingPathComponent:photoPath]];
        }
        index++;
    }
    
    filename = [filename stringByAppendingPathExtension:kClassExtension];
    BOOL success = NO;
    if (temp) {
        NSString *targetFile = [[Utilities generatedFolder] stringByAppendingPathComponent:filename];
        success = [Utilities zipFolder:folderPath targetPath:targetFile password:password];
    } else {
        NSString *targetFile = [[Utilities exportFolder] stringByAppendingPathComponent:filename];
        success = [Utilities zipFolder:folderPath targetPath:targetFile password:password];
        [Utilities clearGeneratedFolder];
    }
    return success ? filename : nil;
}

+ (SchoolClass *)importSchoolClass:(NSString *)path password:(NSString *)password {
    NSString *folderName = [Utilities createTempFolder];
    NSString *folderPath = [[Utilities generatedFolder] stringByAppendingPathComponent:folderName];
    SchoolClass *schoolClass = nil;
    if ([Utilities unzipFolder:path targetPath:folderPath password:password]) {
        
    }
    return schoolClass;
}

- (NSDate *)dateForReminderLesson:(CodeReminderLesson)reminderLesson {
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [Utilities calendar];
    
    NSDateComponents *components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitWeekOfYear fromDate:now];
    
    NSMutableArray *dates = [@[] mutableCopy];
    NSMutableArray *datesThisWeek = [@[] mutableCopy];
    NSMutableArray *datesNextWeek = [@[] mutableCopy];
    
    School *school = [Model instance].application.settings.school;
    if (school) {
        for (Lesson *lesson in self.lesson) {
            [components setWeekday:[lesson.weekDay integerValue] + 1]; // 1 = Sunday, 2 = Monday
            
            SchoolTime *schoolTimeStart = [school schoolTimeByIndex:[lesson.timeStart integerValue]];
            
            if (schoolTimeStart) {
                NSDateComponents *lessonComponents = [calendar components:NSCalendarUnitHour | NSCalendarUnitMinute fromDate:schoolTimeStart.startTime];
                [components setHour:lessonComponents.hour];
                [components setMinute:lessonComponents.minute];
                NSDate *lessonStartDate = [calendar dateFromComponents:components];
                
                if ([now compare:lessonStartDate] == NSOrderedAscending ||
                    [now compare:lessonStartDate] == NSOrderedSame) {
                    [dates addObject:lessonStartDate];
                    [datesThisWeek addObject:lessonStartDate];
                }
                lessonStartDate = [calendar dateByAddingUnit:NSCalendarUnitDay
                                                       value:7
                                                      toDate:lessonStartDate
                                                     options:0];
                [dates addObject:lessonStartDate];
                [datesNextWeek addObject:lessonStartDate];
            }
        }
    }

    NSArray *sortedDates = [dates sortedArrayUsingComparator:^(NSDate *d1, NSDate *d2) {
        return [d1 compare:d2];
    }];
    NSArray *sortedDatesThisWeek = [datesThisWeek sortedArrayUsingComparator:^(NSDate *d1, NSDate *d2) {
        return [d1 compare:d2];
    }];
    NSArray *sortedDatesNextWeek = [datesNextWeek sortedArrayUsingComparator:^(NSDate *d1, NSDate *d2) {
        return [d1 compare:d2];
    }];

    NSDate *nextDate = nil;
    
    switch (reminderLesson) {
        case CodeReminderLessonNext:
            if (sortedDates.count > 0) {
                nextDate = sortedDates[0];
            }
            break;
        case CodeReminderLessonAfterNext:
            if (sortedDates.count > 1) {
                nextDate = sortedDates[1];
            }
            break;
        case CodeReminderLessonLastThisWeek:
            if (sortedDatesThisWeek.count > 0) {
                nextDate = sortedDatesThisWeek[sortedDatesThisWeek.count - 1];
            }
            break;
        case CodeReminderLessonFirstNextWeek:
            if (sortedDatesNextWeek.count > 0) {
                nextDate = sortedDatesNextWeek[0];
            }
            break;
        case CodeReminderLessonLastNextWeek:
            if (sortedDatesNextWeek.count > 0) {
                nextDate = sortedDatesNextWeek[sortedDatesNextWeek.count - 1];
            }
            break;
        case CodeReminderLessonFirstWeekAfterNext:
            if (sortedDatesNextWeek.count > 0) {
                nextDate = sortedDatesNextWeek[0];
                nextDate = [calendar dateByAddingUnit:NSCalendarUnitDay
                                     value:7
                                    toDate:nextDate
                                   options:0];
            }
            break;
        case CodeReminderLessonLastWeekAfterNext:
            if (sortedDatesNextWeek.count > 0) {
                nextDate = sortedDatesNextWeek[sortedDatesNextWeek.count - 1];
                nextDate = [calendar dateByAddingUnit:NSCalendarUnitDay
                                                value:7
                                               toDate:nextDate
                                              options:0];
            }
            break;
    }
    return nextDate;
}

@end