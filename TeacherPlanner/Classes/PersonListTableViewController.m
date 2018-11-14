//
//  PersonListTableViewController.m
//  TeacherPlanner
//
//  Created by Oliver Klemenz on 27.12.14.
//
//

#import "PersonListTableViewController.h"
#import "PersonListDetailTableViewController.h"
#import "AppDelegate.h"
#import "InlineEditTableViewCell.h"
#import "Model.h"
#import "Application.h"
#import "PersonRef.h"
#import "UIButton+Extension.h"
#import "PropertyBinding.h"
#import "Configuration.h"
#import "Common.h"

@interface PersonListTableViewController ()

@end

@implementation PersonListTableViewController

- (instancetype)init {
    self = [self initWithStyle:UITableViewStylePlain];
    if (self) {
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
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
                            @"index" : @(YES),
                            @"display" : @{
                                    @"height" : @(48) },
                            @"bindings" : @[ @{ @"property" : @"name" },
                                             @{ @"property" : @"photoUUID",
                                                @"bindableProperty" : @"imageValue" } ],
                            @"detail" : @{
                                    @"className" : @"PersonListDetailTableViewController",
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
    if (self.selectionUUID) {
        NSIndexPath *indexPath = [[Model instance].application personRefGroupIndexByUUID:self.selectionUUID];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
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

@end