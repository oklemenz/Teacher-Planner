//
//  SettingsExportViewController.m
//  TeacherPlanner
//
//  Created by Oliver Klemenz on 21.12.14.
//
//

#import "SettingsExportViewController.h"
#import "SettingsAddExportViewController.h"
#import "Configuration.h"
#import "Utilities.h"
#import "Common.h"
#import "ShareUtilities.h"

@interface SettingsExportViewController ()

@property (nonatomic, strong) NSMutableDictionary *exportsByCreateDay;
@property (nonatomic, strong) NSMutableArray *createDate;

@end

@implementation SettingsExportViewController

- (instancetype)init {
    self = [self initWithStyle:UITableViewStylePlain];
    if (self) {
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        self.name = NSLocalizedString(@"Exports", @"");
        self.subTitle = NSLocalizedString(@"Settings", @"");
        self.title = [NSString stringWithFormat:@"%@\n%@", self.name, self.subTitle];
        self.tabBarIcon = @"settings_export";
        self.editable = YES;
        self.closeable = YES;
        
        UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(newPressed:)];
        self.navigationItem.rightBarButtonItems = @[self.editButtonItem, addButton];
     
        UIRefreshControl *refresh = [UIRefreshControl new];
        refresh.tintColor = [Configuration instance].highlightColor;
        refresh.attributedTitle = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Pull to Refresh", @"")];
        [refresh addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
        self.refreshControl = refresh;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [self refresh];
}

- (void)refresh {
    [self.refreshControl endRefreshing];
    
    self.exportsByCreateDay = [@{} mutableCopy];
    self.createDate = [@[] mutableCopy];
    
    NSArray *content = [Utilities readContent:[Utilities exportFolder]];
    [content enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *fileName = (NSString *)obj;
        if ([[fileName pathExtension] isEqualToString:kApplicationExtension]) {
            NSString *exportPath = [[Utilities exportFolder] stringByAppendingPathComponent:fileName];
            NSDictionary *fileAttributes = [Utilities readAttributes:exportPath];
            if (fileAttributes) {
                NSDate *creationDate = [fileAttributes objectForKey:NSFileCreationDate];
                
                NSDate *dayDate = [Utilities dayDateForDate:creationDate];
                NSMutableArray *creationByExports = self.exportsByCreateDay[dayDate];
                if (!creationByExports) {
                    creationByExports = [@[] mutableCopy];
                    self.exportsByCreateDay[dayDate] = creationByExports;
                    [self.createDate addObject:dayDate];
                    
                }
                
                NSNumber *fileSize = [fileAttributes objectForKey:NSFileSize];
                [creationByExports addObject:@{ @"filePath" : exportPath,
                                                @"name" : [fileName stringByDeletingPathExtension],
                                                @"creationDate" : creationDate,
                                                @"fileSize" : fileSize }];
            }
        }
    }];
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO];
    for (NSDate *date in self.createDate) {
        [self.exportsByCreateDay[date] sortUsingDescriptors:@[sort]];
    }
    
    [self.tableView reloadData];
}

- (void)newPressed:(id)sender {
    SettingsAddExportViewController *addExport = [SettingsAddExportViewController new];
    [self.navigationController pushViewController:addExport animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.createDate.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[Utilities relativeDateFormatter] stringFromDate:self.createDate[section]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.exportsByCreateDay[self.createDate[section]] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"application";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    NSDate *date = self.createDate[indexPath.section];
    NSDictionary *application = [self.exportsByCreateDay[date] objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [[application[@"filePath"] lastPathComponent] stringByDeletingPathExtension];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@: %@",
                                 NSLocalizedString(@"Created", @""),
                                 [[Utilities dateTimeFormatter] stringFromDate:application[@"creationDate"]]];
    
    UILabel *fileSizeLabel = (UILabel *)cell.accessoryView;
    if (!fileSizeLabel) {
        fileSizeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        fileSizeLabel.textColor = DETAIL_TEXT_COLOR;
        cell.accessoryView = fileSizeLabel;
    }
    fileSizeLabel.text = [Utilities formatFileSize:application[@"fileSize"]];
    [fileSizeLabel sizeToFit];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *deleteButton = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:NSLocalizedString(@"Delete", @"") handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        [self tableView:tableView commitEditingStyle:UITableViewCellEditingStyleDelete forRowAtIndexPath:indexPath];
    }];
    
    UITableViewRowAction *mailButton = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:NSLocalizedString(@"Mail", @"") handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        
        NSDate *date = self.createDate[indexPath.section];
        NSDictionary *application = [self.exportsByCreateDay[date] objectAtIndex:indexPath.row];
        [ShareUtilities showMailExport:application[@"filePath"] presenter:self];
        
        [self setEditing:NO animated:YES];
    }];
    
    return @[deleteButton, mailButton];
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [Common showDeletionConfirmation:self okHandler:^{
            NSDate *date = self.createDate[indexPath.section];
            NSDictionary *export = [self.exportsByCreateDay[date] objectAtIndex:indexPath.row];
            if ([Utilities deletePath:export[@"filePath"]]) {
                [tableView beginUpdates];
                [self.exportsByCreateDay[date] removeObjectAtIndex:indexPath.row];
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                if ([self.exportsByCreateDay[date] count] == 0) {
                    [self.exportsByCreateDay removeObjectForKey:date];
                    [self.createDate removeObject:date];
                    [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
                }
                [tableView endUpdates];
            }
        } cancelHandler:nil];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Import?
}

@end