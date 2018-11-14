//
//  Settings.m
//  TeacherPlanner
//
//  Created by Oliver on 17.05.14.
//
//

#import "Settings.h"
#import "Model.h"
#import "Application.h"
#import "Utilities.h"

@implementation Settings

@synthesize teacher = _teacher;
@synthesize school = _school;

- (void)setup:(BOOL)isNew {
    if (isNew) {
        self.isPrivate = @(NO);
        self.promptTouchID = @(YES);
    }
    
    if (!self.teacher) {
        self.teacher = [Teacher new];
    }
    self.teacher.parent = self;
    
    if (!self.school) {
        self.school = [School new];
    }
    self.school.parent = self;
}

- (void)setIsPrivate:(NSNumber *)isPrivate {
    _isPrivate = isPrivate;
    [self.teacher setWelcomeName];
}

- (void)setPromptTouchID:(NSNumber *)promptTouchID {
    _promptTouchID = promptTouchID;
    if ([self.promptTouchID boolValue]) {
        [[NSUserDefaults standardUserDefaults] setValue:@(YES) forKeyPath:kTeacherPlannerTouchID];
    } else {
        [[NSUserDefaults standardUserDefaults] setValue:nil forKeyPath:kTeacherPlannerTouchID];
    }
}

@end