//
//  StudentTableViewController.m
//  TeacherPlanner
//
//  Created by Oliver on 01.05.14.
//
//

#import "StudentTableViewController.h"
#import "SchoolClass.h"
#import "Student.h"
#import "Person.h"
#import "PersonTableViewController.h"

@interface StudentTableViewController ()
@end

@implementation StudentTableViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.subTitle = NSLocalizedString(@"Students", @"");
        self.definition = @{
                            @"context" : @"student",
                            @"placeholder" : NSLocalizedString(@"Student Name", @""),
                            @"group" : @(YES),
                            @"delete" : @(YES),
                            @"copy" : @(NO),
                            @"photoIcon" : @(YES),
                            @"selectDetail" : @(YES),
                            @"display" : @{
                                    @"height" : @(48) },
                            @"bindings" : @[ @{ @"context" : @"person",
                                                @"property" : @"name" },
                                             @{ @"context" : @"person",
                                                @"property" : @"photoUUID",
                                                @"bindableProperty" : @"imageValue" } ],
                            @"content" : @{
                                    @"className" : @"StudentTabBarViewController",
                                    @"bindings" : @[ @{ @"context" : @"person",
                                                        @"property" : @"name",
                                                        @"bindableProperty" : @"title" } ]
                                    }};
    }
    return self;
}

- (SchoolClass *)schoolClass {
    return (SchoolClass *)self.entity;
}

- (void)newPressed:(id)sender {
    PersonTableViewController *personTableViewController = [PersonTableViewController new];
    personTableViewController.delegate = self;
    [self.navigationController pushViewController:personTableViewController animated:YES];
}

- (void)didSelectPerson:(Person *)person {
    Student *student = [self.schoolClass addAggregation:@"student" parameters:@{ @"personUUID" : person.uuid}];
    [self didSelectContentForEntity:student.uuid hideMenu:NO];
    [self.schoolClass updateAggregation:@"student" object:nil action:@"sort"];
    [self.tableView reloadData];
}

@end