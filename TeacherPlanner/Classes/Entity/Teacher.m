//
//  Teacher.m
//  TeacherPlanner
//
//  Created by Oliver on 17.05.14.
//
//

#import "Teacher.h"
#import "Settings.h"
#import "PersonRef.h"
#import "Utilities.h"
#import "Model.h"
#import "Codes.h"

@implementation Teacher

- (NSString *)name {
    return [NSString stringWithFormat:@"%@%@%@", self.firstName ? self.firstName : @"",
                                                 self.firstName && self.lastName ? @" " : @ "",
                                                 self.lastName ? self.lastName : @""];
}

- (void)setTitle:(NSInteger)title {
    _title = title;
    [self setWelcomeName];
}

- (void)setLastName:(NSString *)lastName {
    _lastName = lastName;
    [self setWelcomeName];
}

- (void)setParent:(JSONEntity *)parent {
    [super setParent:parent];
    [self setWelcomeName];
}

- (void)setWelcomeName {
    if (!self.parent) {
        return;
    }
    if ([[(Settings *)self.parent isPrivate] boolValue]) {
        [[NSUserDefaults standardUserDefaults] setValue:nil forKeyPath:kTeacherPlannerWelcomeName];
    } else {
        NSString *name;
        NSString *title = [Codes textForCode:kCodePersonTitle value:self.title];
        if (title.length > 0 && self.lastName.length > 0) {
            name = [[NSString alloc] initWithFormat:@"%@ %@", title, self.lastName];
            [[NSUserDefaults standardUserDefaults] setValue:name forKeyPath:kTeacherPlannerWelcomeName];
        } else {
            [[NSUserDefaults standardUserDefaults] setValue:nil forKeyPath:kTeacherPlannerWelcomeName];
        }
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)nameInitials {
    return [Utilities nameInitials:self.name];
}

@end
