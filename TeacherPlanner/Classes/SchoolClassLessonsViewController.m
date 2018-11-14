//
//  SchoolClassLessonsViewController.m
//  TeacherPlanner
//
//  Created by Oliver Klemenz on 15.03.15.
//
//

#import "SchoolClassLessonsViewController.h"
#import "Lesson.h"

@interface SchoolClassLessonsViewController ()

@end

@implementation SchoolClassLessonsViewController

- (instancetype)init {
    self = [self initWithStyle:UITableViewStyleGrouped];
    if (self) {
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        self.name = NSLocalizedString(@"Lessons", @"");
        self.tabBarIcon = @"settings";
        self.editable = NO;
        
        self.definition = @[ @{ @"title" : NSLocalizedString(@"Lesson", @""),
                                @"definition" : @[
                                        @{ @"title" : NSLocalizedString(@"Weekday", @""),
                                           @"control" : @"CodePicker",
                                           @"label" : @(YES),
                                           @"code" : @"CodeWeekDay",
                                           @"options" : @{
                                                   @"includeEmpty" : @(YES)
                                           },
                                           @"bindings" : @[ @{ @"property" : @"weekDay" } ],
                                           @"edit" : @{
                                                   @"height" : @(150),
                                                   @"offsetX" : @(40),
                                                   @"offsetY" : @(0) } },
                                        @{ @"title" : NSLocalizedString(@"Start Time", @""),
                                           @"control" : @"EntitySelection",
                                           @"bindings" : @[ @{ @"property" : @"timeStart",
                                                               @"bindableProperty" : @"index" },
                                                            @{ @"context" : @"/settings/school",
                                                               @"property" : @"schoolTime",
                                                               @"bindableProperty" : @"entity" } ],
                                           @"selection" : @(YES),
                                           @"detail" : @{
                                                   @"context" : @"/settings/school/schoolTime",
                                                   @"bindings" : @[ @{ @"property" : @"startTime",
                                                                       @"bindableProperty" : @"valueStart" },
                                                                    @{ @"property" : @"endTime",
                                                                       @"bindableProperty" : @"valueEnd" } ],
                                                   @"control" : @"TimeFromTo" },
                                           @"options" : @{
                                                   @"showIndex" : @(YES),
                                                   @"descriptionPath" : @"startTimeText"
                                                   } },
                                        @{ @"title" : NSLocalizedString(@"End Time", @""),
                                           @"control" : @"EntitySelection",
                                           @"bindings" : @[ @{ @"property" : @"timeEnd",
                                                               @"bindableProperty" : @"index" },
                                                            @{ @"context" : @"/settings/school",
                                                               @"property" : @"schoolTime",
                                                               @"bindableProperty" : @"entity" } ],
                                           @"selection" : @(YES),
                                           @"detail" : @{
                                                   @"context" : @"/settings/school/schoolTime",
                                                   @"bindings" : @[ @{ @"property" : @"startTime",
                                                                       @"bindableProperty" : @"valueStart" },
                                                                    @{ @"property" : @"endTime",
                                                                       @"bindableProperty" : @"valueEnd" } ],
                                                   @"control" : @"TimeFromTo" },
                                           @"options" : @{
                                                   @"showIndex" : @(YES),
                                                   @"descriptionPath" : @"endTimeText"
                                         } },
                                        @{ @"title" : NSLocalizedString(@"Room", @""),
                                           @"control" : @"Edit",
                                           @"label" : @(YES),
                                           @"bindings" : @[ @{ @"property" : @"room" } ] }
                                        ] } ];
    }
    return self;
}

- (NSString *)subTitle {
    return [NSString stringWithFormat:@"%@ - %@ - %@", self.name, self.lesson.parent.parent.name, self.lesson.parent.name];
}

- (Lesson *)lesson {
    return (Lesson *)self.entity;
}

@end
