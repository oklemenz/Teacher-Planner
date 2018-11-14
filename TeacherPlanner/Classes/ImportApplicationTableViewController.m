//
//  ImportApplicationTableViewController.m
//  TeacherPlanner
//
//  Created by Oliver Klemenz on 21.12.14.
//
//

#import "ImportApplicationTableViewController.h"
#import "AbstractTableViewCell.h"
#import "AppDelegate.h"
#import "Application.h"
#import "Utilities.h"
#import "ShareUtilities.h"
#import "Common.h"
#import "Configuration.h"

#define kApplicationBackupViewType 0
#define kApplicationExportViewType 1

@interface ImportApplicationTableViewController()

@property (nonatomic, strong) UISegmentedControl *segmentedControl;

@property (nonatomic, strong) NSMutableArray *exportApplicationNames;
@property (nonatomic, strong) NSMutableDictionary *exportApplications;

@property (nonatomic, strong) NSMutableArray *backupApplicationNames;
@property (nonatomic, strong) NSMutableDictionary *backupApplicationInfo;
@property (nonatomic, strong) NSMutableDictionary *backupApplications;

@property (nonatomic) NSInteger viewType;

@end

@implementation ImportApplicationTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Import Profile", @"");

    if (!self.applicationUUID) {
        self.segmentedControl = [[UISegmentedControl alloc] initWithItems:@[NSLocalizedString(@"Profile Backups", @""), NSLocalizedString(@"Profile Exports", @"")]];
        self.segmentedControl.frame = CGRectMake(10, 10, self.view.bounds.size.width - 2 * 10, 34);
        self.segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.segmentedControl.selectedSegmentIndex = 0;
        [self.segmentedControl addTarget:self action:@selector(segmentedControlChanged:) forControlEvents: UIControlEventValueChanged];
        self.segmentedControl.tintColor = [Configuration instance].highlightColor;
        
        UIView *tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 54)];
        tableHeaderView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [tableHeaderView addSubview:self.segmentedControl];
        [self.tableView setTableHeaderView:tableHeaderView];
    }

    UIRefreshControl *refresh = [UIRefreshControl new];
    refresh.tintColor = [Configuration instance].highlightColor;
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Pull to Refresh", @"")];
    [refresh addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    
    [self refresh];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    for (UIView *subView in self.segmentedControl.subviews) {
        [subView setTintColor:[Configuration instance].highlightColor];
    }
}

- (void)segmentedControlChanged:(UISegmentedControl *)segmentedControl {
    self.viewType = segmentedControl.selectedSegmentIndex;
    [self.tableView reloadData];
}

- (void)refresh {
    [self.refreshControl endRefreshing];
    
    self.exportApplicationNames = [@[] mutableCopy];
    self.exportApplications = [@{} mutableCopy];

    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO];
    
    if (!self.applicationUUID) {
        NSString *name = NSLocalizedString(@"Profile Exports", @"");
        [self.exportApplicationNames addObject:name];
        NSMutableArray *exports = self.exportApplications[name];
        if (!exports) {
            exports = [@[] mutableCopy];
            self.exportApplications[name] = exports;
        }
        NSArray *content = [Utilities readContent:[Utilities exportFolder]];
        [content enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *fileName = (NSString *)obj;
            if ([[fileName pathExtension] isEqualToString:kApplicationExtension]) {
                NSString *exportPath = [[Utilities exportFolder] stringByAppendingPathComponent:fileName];
                NSDictionary *fileAttributes = [Utilities readAttributes:exportPath];
                if (fileAttributes) {
                    NSDate *creationDate = [fileAttributes objectForKey:NSFileCreationDate];
                    NSNumber *fileSize = [fileAttributes objectForKey:NSFileSize];
                    [exports addObject:@{ @"filePath" : exportPath,
                                          @"name" : [fileName stringByDeletingPathExtension],
                                          @"creationDate" : creationDate,
                                          @"fileSize" : fileSize } ];
                }
            }
        }];
        [exports sortUsingDescriptors:@[sort]];
    }
    
    self.backupApplicationNames = [@[] mutableCopy];
    self.backupApplicationInfo = [@{} mutableCopy];
    self.backupApplications = [@{} mutableCopy];
    
    NSArray *content = [Utilities readContent:[Utilities backupFolder]];
    [content enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *fileName = (NSString *)obj;
        if ([[fileName pathExtension] isEqualToString:kApplicationExtension]) {
            NSString *name = [[fileName stringByDeletingPathExtension] stringByDeletingPathExtension];
            if (!self.applicationUUID || [self.applicationUUID isEqualToString:name]) {
                NSMutableArray *backups = self.backupApplications[name];
                if (!backups) {
                    backups = [@[] mutableCopy];
                    self.backupApplications[name] = backups;
                    [self.backupApplicationNames addObject:name];
                }
                NSString *backupPath = [[Utilities backupFolder] stringByAppendingPathComponent:fileName];
                NSDictionary *fileAttributes = [Utilities readAttributes:backupPath];
                if (fileAttributes) {
                    NSDate *creationDate = [fileAttributes objectForKey:NSFileCreationDate];
                    NSNumber *fileSize = [fileAttributes objectForKey:NSFileSize];
                    [backups addObject:@{ @"filePath" : backupPath,
                                          @"name" : name,
                                          @"creationDate" : creationDate,
                                          @"fileSize" : fileSize } ];
                    NSDate *date = self.backupApplicationInfo[name];
                    if (!date || [creationDate compare:date] == NSOrderedAscending) {
                        self.backupApplicationInfo[name] = creationDate;
                    }
                }
                [backups sortUsingDescriptors:@[sort]];
            }
        }
    }];
    
    [self.backupApplicationNames sortUsingComparator:^NSComparisonResult(NSString *name1, NSString *name2) {
        NSDate *date1 = self.backupApplicationInfo[name1];
        NSDate *date2 = self.backupApplicationInfo[name2];
        return [date1 compare:date2];
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger count = 0;
    if (self.viewType == kApplicationBackupViewType) {
        count = self.backupApplicationNames.count;
    } else if (self.viewType == kApplicationExportViewType) {
        count = self.exportApplicationNames.count;
    }
    if (count == 0) {
        return 1;
    }
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = 0;
    if (self.viewType == kApplicationBackupViewType) {
        if (self.backupApplicationNames.count > 0) {
            count = [self.backupApplications[self.backupApplicationNames[section]] count];
        }
    } else if (self.viewType == kApplicationExportViewType) {
        if (self.exportApplicationNames.count > 0) {
            count = [self.exportApplications[self.exportApplicationNames[section]] count];
        }
    }
    if (count == 0) {
        return 1;
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = [@"CellIdentifier_" stringByAppendingFormat:@"%tu", self.viewType];

    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        UITableViewCellStyle style = UITableViewCellStyleValue1;
        if (self.viewType == kApplicationExportViewType) {
            style = UITableViewCellStyleSubtitle;
        }
        cell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:CellIdentifier];
    }

    NSInteger count = 0;
    if (self.viewType == kApplicationBackupViewType) {
        if (self.backupApplicationNames.count > 0) {
            count = [self.backupApplications[self.backupApplicationNames[indexPath.section]] count];
        }
    } else if (self.viewType == kApplicationExportViewType) {
        if (self.exportApplicationNames.count > 0) {
            count = [self.exportApplications[self.exportApplicationNames[indexPath.section]] count];
        }
    }
    
    if (count == 0) {
        if (self.viewType == kApplicationBackupViewType) {
            cell.textLabel.text = NSLocalizedString(@"No Profile Backups", @"");
        } else if (self.viewType == kApplicationExportViewType) {
            cell.textLabel.text = NSLocalizedString(@"No Profile Exports", @"");
        }
    } else {
        NSDictionary *application;
        if (self.viewType == kApplicationBackupViewType) {
            if (self.backupApplicationNames.count > 0) {
                application = [self.backupApplications[self.backupApplicationNames[indexPath.section]] objectAtIndex:indexPath.row];
            }
            cell.textLabel.text = [[Utilities dateTimeFormatter] stringFromDate:application[@"creationDate"]];
        } else if (self.viewType == kApplicationExportViewType) {
            if (self.exportApplicationNames.count > 0) {
                application = [self.exportApplications[self.exportApplicationNames[indexPath.section]] objectAtIndex:indexPath.row];
            }
            cell.textLabel.text = [[application[@"filePath"] lastPathComponent] stringByDeletingPathExtension];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@: %@",
                                         NSLocalizedString(@"Created", @""),
                                         [[Utilities dateTimeFormatter] stringFromDate:application[@"creationDate"]]];
        }
        if (application) {
            UILabel *fileSizeLabel = (UILabel *)cell.accessoryView;
            if (!fileSizeLabel) {
                fileSizeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
                fileSizeLabel.textColor = DETAIL_TEXT_COLOR;;
                cell.accessoryView = fileSizeLabel;
            }
            fileSizeLabel.text = [Utilities formatFileSize:application[@"fileSize"]];
            [fileSizeLabel sizeToFit];
        }
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger count = 0;
    if (self.viewType == kApplicationBackupViewType) {
        count = self.backupApplicationNames.count;
    } else if (self.viewType == kApplicationExportViewType) {
        count = self.exportApplicationNames.count;
    }
    return count > 0;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [Common showDeletionConfirmation:self okHandler:^{
            NSMutableArray *applications;
            if (self.viewType == kApplicationBackupViewType) {
                if (self.backupApplicationNames.count > 0) {
                    applications = self.backupApplications[self.backupApplicationNames[indexPath.section]];
                }
            } else if (self.viewType == kApplicationExportViewType) {
                if (self.exportApplicationNames.count > 0) {
                    applications = self.exportApplications[self.exportApplicationNames[indexPath.section]];
                }
            }
            if (applications) {
                NSDictionary *application = [applications objectAtIndex:indexPath.row];
                if ([Utilities deletePath:application[@"filePath"]]) {
                    [tableView beginUpdates];
                    [applications removeObjectAtIndex:indexPath.row];
                    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                    if (applications.count == 0) {
                        if (self.viewType == kApplicationBackupViewType) {
                            [self.backupApplications removeObjectForKey:self.backupApplicationNames[indexPath.section]];
                            [self.backupApplicationNames removeObjectAtIndex:indexPath.section];
                        } else if (self.viewType == kApplicationExportViewType) {
                            [self.exportApplications removeObjectForKey:self.exportApplicationNames[indexPath.section]];
                            [self.exportApplicationNames removeObjectAtIndex:indexPath.section];
                        }
                        [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section]
                                 withRowAnimation:UITableViewRowAnimationFade];
                    }
                    [tableView endUpdates];
                }
            }
        } cancelHandler:nil];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *applications;
    if (self.viewType == kApplicationBackupViewType) {
        if (self.backupApplicationNames.count > 0) {
            applications = self.backupApplications[self.backupApplicationNames[indexPath.section]];
        }
    } else if (self.viewType == kApplicationExportViewType) {
        if (self.exportApplicationNames.count > 0) {
            applications = self.exportApplications[self.exportApplicationNames[indexPath.section]];
        }
    }
    if (applications && applications.count > 0) {
        NSDictionary *application = [applications objectAtIndex:indexPath.row];
        [self showImportPopup:^{
            if (self.viewType == kApplicationBackupViewType) {
                [self handleImportResult:[Application importApplication:application[@"filePath"] type:kApplicationImportTypeBackup password:nil]];
            } else if (self.viewType == kApplicationExportViewType) {
                [ShareUtilities showPasswordEntry:self handler:^(NSString *password) {
                    [self handleImportResult:[Application importApplication:application[@"filePath"] type:
                    kApplicationImportTypeExport password:password]];
                }];
            }
        } cancelHandler:nil];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)handleImportResult:(BOOL)success {
    if (success) {
        [Common showMessage:self title:NSLocalizedString(@"Profile Import", @"") message:NSLocalizedString(@"Profile sucessfully imported", @"") okButtonTitle:nil okHandler:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
    } else {
        [Common showMessage:self title:NSLocalizedString(@"Profile Import", @"") message:NSLocalizedString(@"Error during profile import. Wrong Password?", @"") okButtonTitle:nil okHandler:nil];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.viewType == kApplicationBackupViewType) {
        NSInteger count = 0;
        if (self.backupApplicationNames.count > 0) {
            count = [self.backupApplications[self.backupApplicationNames[section]] count];
            NSDate *infoDate = self.backupApplicationInfo[self.backupApplicationNames[section]];
            return [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Backup created", @""),
                    [[Utilities dateTimeFormatter] stringFromDate:infoDate]];
        }
        if (count == 0) {
            return NSLocalizedString(@"Profile Backups", @"");
        }
    } else if (self.viewType == kApplicationExportViewType) {
        return NSLocalizedString(@"Profile Exports", @"");
    }
    return @"";
}

- (void)showImportPopup:(void (^)(void))okHandler cancelHandler:(void (^)(void))cancelHandler {
    [Common showConfirmation:self title:NSLocalizedString(@"Confirm Profile Import", @"")
                     message:NSLocalizedString(@"Do you really want to import the profile?", @"")
               okButtonTitle:NSLocalizedString(@"Import", @"")
                 destructive:NO
                   okHandler:okHandler
               cancelHandler:cancelHandler];
}

@end
