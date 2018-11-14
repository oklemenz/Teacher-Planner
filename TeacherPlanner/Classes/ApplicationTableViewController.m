//
//  ApplicationTableViewController.m
//  TeacherPlanner
//
//  Created by Oliver Klemenz on 29.11.14.
//
//

#import "ApplicationTableViewController.h"
#import "ImportApplicationTableViewController.h"
#import "AppDelegate.h"
#import "Application.h"
#import "Utilities.h"
#import "Common.h"
#import "Configuration.h"
#import "SecureStore.h"

@interface ApplicationTableViewController ()

@property (nonatomic, strong) NSMutableDictionary *applicationsByChangeDay;
@property (nonatomic, strong) NSMutableArray *changeDate;
@property (nonatomic, strong) NSMutableArray *protectedApplications;

@end

@implementation ApplicationTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Profiles", @"");
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(newPressed:)];
    UIBarButtonItem *importButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Import", @"")
                                                                    style:UIBarButtonItemStylePlain target:self
                                                                   action:@selector(import:)];
    self.navigationItem.rightBarButtonItems = @[self.editButtonItem, addButton, importButton];
    
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", @"")
                                                                    style:UIBarButtonItemStylePlain target:self
                                                                   action:@selector(close:)];
    self.navigationItem.leftBarButtonItem = closeButton;
    
    UIRefreshControl *refresh = [UIRefreshControl new];
    refresh.tintColor = [Configuration instance].highlightColor;
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Pull to Refresh", @"")];
    [refresh addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
}

- (void)viewWillAppear:(BOOL)animated {
    [self refresh];
}

- (void)refresh {
    [self.refreshControl endRefreshing];
    
    self.applicationsByChangeDay = [@{} mutableCopy];
    self.changeDate = [@[] mutableCopy];
    
    BOOL protect = NO;
    if (!self.protectedApplications) {
        self.protectedApplications = [@[] mutableCopy];
        protect = YES;
    }
    
    NSArray *content = [Utilities readEntities];
    [content enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *uuid = (NSString *)obj;
        if ([Utilities isEntityFolder:uuid]) {
            NSDictionary *fileAttributes = [Utilities readEntityAttributes:uuid];
            if (fileAttributes) {
                NSDate *creationDate = [fileAttributes objectForKey:NSFileCreationDate];
                NSDate *modificationDate = [fileAttributes objectForKey:NSFileModificationDate];
                
                NSDate *dayDate = [Utilities dayDateForDate:modificationDate];
                NSMutableArray *changeDayApplications = self.applicationsByChangeDay[dayDate];
                if (!changeDayApplications) {
                    changeDayApplications = [@[] mutableCopy];
                    self.applicationsByChangeDay[dayDate] = changeDayApplications;
                    [self.changeDate addObject:dayDate];
                }
                BOOL protected = NO;
                if (protect) {
                    [self.protectedApplications addObject:uuid];
                    protected = YES;
                } else {
                    if ([self.protectedApplications containsObject:uuid]) {
                        protected = YES;
                    }
                }
                [changeDayApplications insertObject:@{ @"uuid" : uuid,
                                                       @"creationDate" : creationDate,
                                                       @"modificationDate" : modificationDate,
                                                       @"protected" : @(protected) } atIndex:0];
            }
        }
    }];
    [self.changeDate sortUsingComparator:^NSComparisonResult(NSDate *date1, NSDate *date2) {
        return -[date1 compare:date2];
    }];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"modificationDate" ascending:NO];
    for (NSDate *date in self.changeDate) {
        [self.applicationsByChangeDay[date] sortUsingDescriptors:@[sort]];
    }

    [self.tableView reloadData];
}

- (void)newPressed:(id)sender {
    [self showConfirmPasscode:^{
        Application *applictaion = [Application createApplication:nil];
        if (![[AppDelegate instance] activeApplication]) {
            [[AppDelegate instance] switchApplication:applictaion.uuid lock:NO];
        }
        [self refresh];
    } cancelHandler:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.changeDate.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[Utilities relativeDateFormatter] stringFromDate:self.changeDate[section]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.applicationsByChangeDay[self.changeDate[section]] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"application";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }

    cell.accessoryType = UITableViewCellAccessoryNone;

    
    NSDate *date = self.changeDate[indexPath.section];
    NSDictionary *application = [self.applicationsByChangeDay[date] objectAtIndex:indexPath.row];
    if ([application[@"uuid"] isEqualToString:[[AppDelegate instance] activeApplication]]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }

    cell.textLabel.text = [NSString stringWithFormat:@"%@: %@",
                           NSLocalizedString(@"Changed", @""),
                           [[Utilities dateTimeFormatter] stringFromDate:application[@"modificationDate"]]];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@: %@",
                                 NSLocalizedString(@"Created", @""),
                                 [[Utilities dateTimeFormatter] stringFromDate:application[@"creationDate"]]];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
    
- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *deleteButton = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:NSLocalizedString(@"Delete", @"") handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        [self tableView:tableView commitEditingStyle:UITableViewCellEditingStyleDelete forRowAtIndexPath:indexPath];
    }];
    
    UITableViewRowAction *copyButton = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:NSLocalizedString(@"Copy", @"") handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        NSDate *date = self.changeDate[indexPath.section];
        NSDictionary *application = [self.applicationsByChangeDay[date] objectAtIndex:indexPath.row];
        if ([Application copyApplication:application[@"uuid"]]) {
            [self refresh];
        } else {
            [self setEditing:NO animated:YES];
        }
    }];

    UITableViewRowAction *importButton = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:NSLocalizedString(@"Import", @"") handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        NSDate *date = self.changeDate[indexPath.section];
        NSDictionary *application = [self.applicationsByChangeDay[date] objectAtIndex:indexPath.row];
        ImportApplicationTableViewController *importApplication = [[ImportApplicationTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
        importApplication.applicationUUID = application[@"uuid"];
        [self.navigationController pushViewController:importApplication animated:YES];
        [self setEditing:NO animated:YES];
    }];
    
    NSDate *date = self.changeDate[indexPath.section];
    NSDictionary *application = [self.applicationsByChangeDay[date] objectAtIndex:indexPath.row];
    if (![application[@"uuid"] isEqualToString:[[AppDelegate instance] activeApplication]]) {
        return @[deleteButton, copyButton, importButton];
    }
    return @[copyButton, importButton];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [Common showDeletionConfirmation:self okHandler:^{
            NSDate *date = self.changeDate[indexPath.section];
            NSDictionary *application = [self.applicationsByChangeDay[date] objectAtIndex:indexPath.row];
            void (^deleteApplication)(void) = ^{
                if ([Application deleteApplication:application[@"uuid"]]) {
                    [tableView beginUpdates];
                    [self.applicationsByChangeDay[date] removeObjectAtIndex:indexPath.row];
                    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                    if ([self.applicationsByChangeDay[date] count] == 0) {
                        [self.applicationsByChangeDay removeObjectForKey:date];
                        [self.changeDate removeObject:date];
                        [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
                    }
                    [tableView endUpdates];
                }
            };
            if ([application[@"protected"] boolValue]) {
                [self showConfirmPasscode:deleteApplication cancelHandler:nil];
            } else {
                deleteApplication();
            }
        } cancelHandler:nil];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDate *date = self.changeDate[indexPath.section];
    NSDictionary *application = [self.applicationsByChangeDay[date] objectAtIndex:indexPath.row];
    if (![application[@"uuid"] isEqualToString:[[AppDelegate instance] activeApplication]]) {
        [self showSwitchPopup:^{
            void (^switchApplication)(void) = ^{
                [[AppDelegate instance] switchApplication:application[@"uuid"] lock:YES];
                [self.tableView reloadData];
            };
            if ([application[@"protected"] boolValue]) {
                [self showConfirmPasscode:switchApplication cancelHandler:nil];
            } else {
                switchApplication();
            }
        } cancelHandler:nil];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)showSwitchPopup:(void (^)(void))okHandler cancelHandler:(void (^)(void))cancelHandler {
    [Common showConfirmation:self title:NSLocalizedString(@"Confirm Account Switch", @"")
                     message:NSLocalizedString(@"Do you really want to switch your account?", @"")
               okButtonTitle:NSLocalizedString(@"Switch", @"")
                 destructive:NO
                   okHandler:okHandler
               cancelHandler:cancelHandler];
}

- (void)showConfirmPasscode:(void (^)(void))okHandler cancelHandler:(void (^)(void))cancelHandler {
    [Common showEnterPasscode:self okHandler:^(NSString *passcode) {
        if ([[SecureStore instance] validate:passcode]) {
            if (okHandler) {
                okHandler();
            }
        } else {
            [Common showMessage:self title:NSLocalizedString(@"Teacher Planner", @"") message:NSLocalizedString(@"Entered passcode is not correct", @"") okHandler:nil];
        }
    } cancelHandler:cancelHandler];
}

- (void)close:(id)sender {
    [[AppDelegate instance] dismiss:self animated:YES completion:nil];
}

- (void)import:(id)sender {
    ImportApplicationTableViewController *importApplication = [[ImportApplicationTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [self.navigationController pushViewController:importApplication animated:YES];
}

@end
