//
//  SchoolClassTeachingViewController.m
//  TeacherPlanner
//
//  Created by Oliver Klemenz on 29.01.15.
//
//

#import "SchoolClassTeachingViewController.h"
#import "SchoolClass.h"

@interface SchoolClassTeachingViewController ()

@end

@implementation SchoolClassTeachingViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.name = NSLocalizedString(@"In Classroom", @"");
        self.tabBarIcon = @"school_class_teaching";

        UIBarButtonItem *actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(didPressAction:)];
        self.navigationItem.rightBarButtonItems = @[self.editButtonItem, actionButton];
    }
    return self;
}

- (NSString *)subTitle {
    return [NSString stringWithFormat:@"%@ - %@", self.name, self.schoolClass.parent.name];
}

- (SchoolClass *)schoolClass {
    return (SchoolClass *)self.entity;
}

- (void)didPressAction:(id)sender {
    // TODO: Export all students teaching information for class..
}

@end
