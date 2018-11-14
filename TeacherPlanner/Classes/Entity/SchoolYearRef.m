//
//  SchoolYearRef.m
//  TeacherPlanner
//
//  Created by Oliver on 29.12.13.
//
//

#import "SchoolYearRef.h"
#import "Model.h"
#import "Application.h"

@implementation SchoolYearRef

@synthesize name = _name;
@synthesize isActive = _isActive;
@synthesize isPlanned = _isPlanned;

- (SchoolYear *)schoolYear {
    return [[Model instance].application schoolYearByUUID:self.uuid];
}

- (CodeSchoolYearType)type {
    CodeSchoolYearType type = CodeSchoolYearTypePlanned;
    if ([self.isActive boolValue]) {
        type = CodeSchoolYearTypeActive;
    } else if (![self.isPlanned boolValue]) {
        type = CodeSchoolYearTypeCompleted;
    }
    return type;
}

- (void)setName:(NSString *)name {
    if ([_name isEqualToString:name]) {
        return;
    }
    _name = name;
    [self.schoolYear setProperty:@"name" value:name force:YES];
}

- (NSNumber *)isActive {
    if (self.uuid) {
        NSString *activeSchoolYearUUID = [[NSUserDefaults standardUserDefaults] valueForKey:kTeacherPlannerActiveSchoolYear];
        if (![self.uuid isEqualToString:activeSchoolYearUUID] && [_isActive boolValue]) {
            self.isActive = @(NO);
        }
    }
    return _isActive;
}

- (void)setIsActive:(NSNumber *)isActive {
    if ([_isActive boolValue] == [isActive boolValue]) {
        return;
    }
    if (self.uuid) {
        NSString *activeSchoolYearUUID = [[NSUserDefaults standardUserDefaults] valueForKey:kTeacherPlannerActiveSchoolYear];
        if ([_isActive boolValue] && ![isActive boolValue] && [self.uuid isEqualToString:activeSchoolYearUUID]) {
            [[NSUserDefaults standardUserDefaults] setValue:nil forKeyPath:kTeacherPlannerActiveSchoolYear];
        }
        _isActive = isActive;
        if ([isActive boolValue]) {
            [[NSUserDefaults standardUserDefaults] setValue:self.uuid forKeyPath:kTeacherPlannerActiveSchoolYear];
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        _isActive = isActive;
    }
    [self.schoolYear setProperty:@"isActive" value:isActive force:YES];
    [[Model instance].application invalidateContext:@"schoolYearRef" userInfo:@{ @"property" : @"isActive",
                                                                                 @"value" : isActive }];
    if ([isActive boolValue]) {
        [self setProperty:@"isPlanned" value:@(NO)];
    }
}

- (void)setIsPlanned:(NSNumber *)isPlanned {
    if ([_isPlanned boolValue] == [isPlanned boolValue]) {
        return;
    }
    _isPlanned = isPlanned;
    [self.schoolYear setProperty:@"isPlanned" value:isPlanned force:YES];
    [[Model instance].application invalidateContext:@"schoolYearRef" userInfo:@{ @"property" : @"isPlanned",
                                                                                 @"value" : isPlanned }];
    if ([isPlanned boolValue]) {
        [self setProperty:@"isActive" value:@(NO)];
    }
}

- (void)willBeRemoved {
    [super willBeRemoved];
    NSString *activeSchoolYearUUID = [[NSUserDefaults standardUserDefaults] valueForKey:kTeacherPlannerActiveSchoolYear];
    if ([self.uuid isEqualToString:activeSchoolYearUUID]) {
        [[NSUserDefaults standardUserDefaults] setValue:nil forKeyPath:kTeacherPlannerActiveSchoolYear];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

@end