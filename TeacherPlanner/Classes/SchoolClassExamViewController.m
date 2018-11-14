//
//  SchoolClassExamViewController.m
//  TeacherPlanner
//
//  Created by Oliver on 17.05.14.
//
//

#import "SchoolClassExamViewController.h"
#import "SchoolClass.h"

@interface SchoolClassExamViewController ()

@end

@implementation SchoolClassExamViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.name = NSLocalizedString(@"Exams", @"");
        self.tabBarIcon = @"school_class_exam";
        self.editable = YES;

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
    // TODO: Export class exams and grades
}

@end