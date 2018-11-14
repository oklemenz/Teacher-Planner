//
//  PersonTableViewController.m
//  TeacherPlanner
//
//  Created by Oliver on 01.05.14.
//
//

#import "PersonTableViewController.h"
#import "Model.h"
#import "Application.h"
#import "PersonRef.h"

@interface PersonTableViewController ()
@end

@implementation PersonTableViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.name = NSLocalizedString(@"Persons", @"");
        self.definition = @{
                            @"context" : @"personRef",
                            @"placeholder" : NSLocalizedString(@"Person Name", @""),
                            @"ref" : @(YES),
                            @"group" : @(YES),
                            @"search" : @(YES),
                            @"delete" : @(YES),
                            @"photoIcon" : @(YES),
                            @"selectDetail" : @(YES),
                            @"index" : @(YES),
                            @"display" : @{
                                    @"height" : @(48) },
                            @"bindings" : @[ @{ @"property" : @"name" },
                                             @{ @"property" : @"photoUUID",
                                                @"bindableProperty" : @"imageValue" } ],
                            @"content" : @{
                                    @"className" : @"PersonTabBarViewController",
                                    @"bindings" : @[ @{ @"property" : @"name",
                                                        @"bindableProperty" : @"title" } ]
                                    }};
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.entity = [Model instance].application;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([[Model instance].application numberOfPersonRefGroup] == 0 ||
        ([[Model instance].application numberOfPersonRefGroup] == 1 &&
         [[Model instance].application numberOfPersonRefByGroup:0] == 0)) {
        [self newPressed:nil];
    }
}

- (Person *)person:(NSIndexPath *)indexPath {
    PersonRef *personRef = [[Model instance].application personRefByGroup:indexPath.section index:indexPath.row];
    return [[Model instance].application personByUUID:personRef.uuid];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self person:indexPath].useCount <= 0;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self person:indexPath].useCount <= 0 ? UITableViewCellEditingStyleDelete : UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self person:indexPath].useCount <= 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.delegate) {
        [self.delegate didSelectPerson:[self person:indexPath]];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end