//
//  StudentTeachingViewController.m
//  TeacherPlanner
//
//  Created by Oliver on 17.05.14.
//
//

#import "StudentTeachingViewController.h"
#import "Student.h"

@interface StudentTeachingViewController ()

@end

@implementation StudentTeachingViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.name = NSLocalizedString(@"In Classroom", @"");
        self.tabBarIcon = @"student_teaching";
        self.editable = YES;
        
        UIBarButtonItem *actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(didPressAction:)];
        self.navigationItem.rightBarButtonItems = @[self.editButtonItem, actionButton];
    }
    return self;
}

- (NSString *)subTitle {
    return [NSString stringWithFormat:@"%@ - %@ - %@", self.name, self.student.parent.name, self.student.parent.parent.name];
}

- (void)didPressAction:(id)sender {
    // TODO: Export student teaching information..
}

- (Student *)student {
    return (Student *)self.entity;
}

@end