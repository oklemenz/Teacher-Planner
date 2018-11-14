//
//  StudentGradeViewController.m
//  TeacherPlanner
//
//  Created by Oliver on 17.05.14.
//
//

#import "StudentGradeViewController.h"
#import "Student.h"

@interface StudentGradeViewController ()

@end

@implementation StudentGradeViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.name = NSLocalizedString(@"Grades", @"");
        self.tabBarIcon = @"student_grade";
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
    // TODO: Export student with exams and grades
}

- (Student *)student {
    return (Student *)self.entity;
}

@end