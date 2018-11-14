//
//  TeacherPlannerController.m
//  TeacherPlanner
//
//  Created by Klemenz, Oliver on 25.07.14.
//
//

#import "AnnotationViewController.h"
#import "AnnotationReminderViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "Utilities.h"
#import "Annotation.h"
#import "AnnotationHandler.h"
#import "UIImage+Extension.h"
#import "Common.h"
#import "Configuration.h"
#import "AppDelegate.h"

@interface AnnotationViewController () {
}

@property (nonatomic, strong) AnnotationHandler *annotationHandler;
@property (nonatomic, strong) NSMutableArray *annotations;
@property (nonatomic, strong) NSString *aggregation;

@end

@implementation AnnotationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Annotations", @"");
    self.aggregation = @"annotation";
    
    self.clearsSelectionOnViewWillAppear = YES;
    self.tableView.allowsSelectionDuringEditing = YES;

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(newPressed:)];
    self.navigationItem.rightBarButtonItems = @[self.editButtonItem, addButton];
    
    UIRefreshControl *refresh = [UIRefreshControl new];
    refresh.tintColor = [Configuration instance].highlightColor;
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Pull to Refresh", @"")];
    [refresh addTarget:self action:@selector(refreshData:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.showNewDialog) {
        self.showNewDialog = NO;
        [self performSelector:@selector(showNewAnnotation) withObject:nil afterDelay:0.1];
    }
}

- (void)showAnnotation:(NSString *)uuid {
    [self refreshData:nil];
    NSIndexPath *indexPath = [self.dataSource aggregationGroupIndex:self.aggregation uuid:uuid];
    if (indexPath) {
        [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
        [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
    }
}

- (void)newPressed:(id)sender {
    [self showNewAnnotation];
}

- (void)showNewAnnotation {
    self.annotations = [@[] mutableCopy];
    
    // Write Text
    [self.annotations addObject:@{ @"title" : NSLocalizedString(@"Write text", @""),
                                   @"type" : @(CodeAnnotationTypeText),
                                   @"new" : @(YES) }];
    
    // Take Photo
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [self.annotations addObject:@{ @"title" : NSLocalizedString(@"Take Photo", @""),
                                       @"type" : @(CodeAnnotationTypePhoto),
                                       @"new" : @(YES) }];
    }

    // Take Photo and Crop
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [self.annotations addObject:@{ @"title" : NSLocalizedString(@"Take Photo and Crop", @""),
                                       @"type" : @(CodeAnnotationTypePhoto),
                                       @"new" : @(YES),
                                       @"crop" : @(YES) }];
    }
    
    // Choose Photo
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
        [self.annotations addObject:@{ @"title" : NSLocalizedString(@"Choose Photo", @""),
                                       @"type" : @(CodeAnnotationTypePhoto),
                                       @"new" : @(NO) }];
    }

    // Choose Photo and Crop
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
        [self.annotations addObject:@{ @"title" : NSLocalizedString(@"Choose Photo and Crop", @""),
                                       @"type" : @(CodeAnnotationTypePhoto),
                                       @"new" : @(NO),
                                       @"crop" : @(YES) }];
    }
    
    // Draw Picture
    [self.annotations addObject:@{ @"title" : NSLocalizedString(@"Draw Picture", @""),
                                   @"type" : @(CodeAnnotationTypeImage),
                                   @"new" : @(YES) }];
    
    // Record Audio
    [self.annotations addObject:@{ @"title" : NSLocalizedString(@"Record Audio", @""),
                                   @"type" : @(CodeAnnotationTypeAudio),
                                   @"new" : @(YES) }];
    
    // Record Video
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *videoPicker = [UIImagePickerController new];
        NSArray *sourceTypes = [UIImagePickerController availableMediaTypesForSourceType:videoPicker.sourceType];
        if ([sourceTypes containsObject:(NSString*)kUTTypeMovie]) {
            [self.annotations addObject:@{ @"title" : NSLocalizedString(@"Record Video", @""),
                                           @"type" : @(CodeAnnotationTypeVideo),
                                           @"new" : @(YES) }];
        }
    }
    
    // Choose Video
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
        [self.annotations addObject:@{ @"title" : NSLocalizedString(@"Choose Video", @""),
                                       @"type" : @(CodeAnnotationTypeVideo),
                                       @"new" : @(NO) }];
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"New Annotation", @"") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    for (NSDictionary *annotation in self.annotations) {
        void(^annotationHandler)(UIAlertAction *action) = ^(UIAlertAction *action) {
            self.annotationHandler = [[AnnotationHandler alloc] initWithAnnotationType:[annotation[@"type"] integerValue] presenter:self];
            self.annotationHandler.delegate = self;
            self.annotationHandler.dataSource = self.dataSource;
            self.annotationHandler.imageDataSource = self.imageDataSource;
            if ([annotation[@"new"] boolValue]) {
                [self.annotationHandler create:[annotation[@"crop"] boolValue]];
            } else {
                [self.annotationHandler choose:[annotation[@"crop"] boolValue]];
            }
        };
        UIAlertAction *action = [UIAlertAction actionWithTitle:annotation[@"title"]
                                                         style:UIAlertActionStyleDefault
                                                       handler:annotationHandler];
        [alert addAction:action];
    }

    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"")
                                                     style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction * action) {
                                                   }];
    
    [alert addAction:cancel];
    [[AppDelegate instance] present:alert presenter:self animated:YES completion:nil];
}

- (void)didAddAnnotation:(NSData *)data thumbnail:(NSData *)thumbnail length:(CGFloat)length sender:(id)sender {
    NSMutableDictionary *parameters = [@{ @"type" : @(((AnnotationHandler *)sender).annotationType),
                                          @"data" : data,
                                          @"length" : @(length) } mutableCopy];
    if (thumbnail) {
        parameters[@"thumbnail"] = thumbnail;
    }
    Annotation *annotation = [self.dataSource addAggregation:self.aggregation parameters:parameters];
    NSIndexPath *indexPath = [self.dataSource aggregationGroupIndex:self.aggregation uuid:annotation.uuid];
    [self.tableView beginUpdates];
    if ([self.dataSource numberOfAggregation:self.aggregation group:indexPath.section] == 1) {
        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
    }
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
}

- (void)didUpdateAnnotation:(NSData *)data thumbnail:(NSData *)thumbnail length:(CGFloat)length sender:(id)sender {
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
    Annotation *annotation = [self.dataSource aggregation:self.aggregation group:selectedIndexPath.section index:selectedIndexPath.row];
    if (annotation) {
        NSMutableDictionary *parameters = [@{ @"data" : data,
                                              @"length" : @(length) } mutableCopy];
        if (thumbnail) {
            parameters[@"thumbnail"] = thumbnail;
        }
        [self.dataSource updateAggregation:self.aggregation object:annotation action:@"update" parameters:parameters];
        [self refreshSelectedCell];
    }
}

- (void)didFinish {
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
    if (selectedIndexPath) {
        [self.tableView deselectRowAtIndexPath:selectedIndexPath animated:YES];
    }
}

- (void)refreshSelectedCell {
    [self.tableView beginUpdates];
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
    if (selectedIndexPath) {
        [self.tableView reloadRowsAtIndexPaths:@[selectedIndexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
    [self.tableView endUpdates];
    if (selectedIndexPath) {
        [self.tableView selectRowAtIndexPath:selectedIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.dataSource numberOfAggregationGroup:self.aggregation];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.dataSource aggregationGroupName:self.aggregation group:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataSource numberOfAggregation:self.aggregation group:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CellIdentifier";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
         cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }

    Annotation *annotation = [self.dataSource aggregation:self.aggregation group:indexPath.section index:indexPath.row];
    cell.imageView.image = annotation.iconImage;
    cell.textLabel.text = annotation.title;
    cell.detailTextLabel.text = annotation.subTitle;
    
    if (annotation.type == CodeAnnotationTypeText) {
        cell.textLabel.minimumScaleFactor = 8.0 / cell.textLabel.font.pointSize;;
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
    } else {
        cell.textLabel.minimumScaleFactor = 0.0;
        cell.textLabel.adjustsFontSizeToFitWidth = NO;
    }
    
    BOOL reminderActive = annotation.reminderFireDate && [[NSDate date] compare:annotation.reminderFireDate] == NSOrderedAscending;

    UIImage *image = nil;
    if (reminderActive) {
        image = [[UIImage imageNamed:@"reminder_show"] tintImageWithColor:[Configuration instance].highlightColor];
    } else {
        image = [[UIImage imageNamed:@"reminder_show"] tintImageWithColor:[Configuration instance].lightHighlightColor];
    }
    CGRect frame = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
    UIButton *button = [[UIButton alloc] initWithFrame:frame];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapReminder:)];
    [button addGestureRecognizer:tapGesture];
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPressReminder:)];
    [button addGestureRecognizer:longPressGesture];
    button.backgroundColor = [UIColor clearColor];
    cell.accessoryView = button;
    
    return cell;
}

- (void)didTapReminder:(UITapGestureRecognizer *)gesture {
    CGPoint location = [gesture locationInView:self.view];
    if (CGRectContainsPoint([self.view convertRect:self.tableView.frame fromView:self.tableView.superview], location)) {
        CGPoint locationInTableview = [self.tableView convertPoint:location fromView:self.view];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:locationInTableview];
        if (indexPath) {
            [self tableView:self.tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
        }
    }
}

- (void)didLongPressReminder:(UILongPressGestureRecognizer *)gesture {
    CGPoint location = [gesture locationInView:self.view];
    if (CGRectContainsPoint([self.view convertRect:self.tableView.frame fromView:self.tableView.superview], location)) {
        CGPoint locationInTableview = [self.tableView convertPoint:location fromView:self.view];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:locationInTableview];
        if (indexPath) {
            [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
            Annotation *annotation = [self.dataSource aggregation:self.aggregation group:indexPath.section index:indexPath.row];
            if (annotation) {
                [annotation unscheduleReminder];
                [self refreshSelectedCell];
            }
        }
    }
}

- (void)didChangeReminder:(NSDate *)reminderDate offset:(NSDateComponents *)offset annotation:(Annotation *)annotation sender:(id)sender {
    [self refreshSelectedCell];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    AnnotationReminderViewController *reminder = [AnnotationReminderViewController new];
    reminder.delegate = self;
    reminder.annotation = [self.dataSource aggregation:self.aggregation group:indexPath.section index:indexPath.row];
    [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    [self.navigationController pushViewController:reminder animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Annotation *annotation = [self.dataSource aggregation:self.aggregation group:indexPath.section index:indexPath.row];
        [tableView beginUpdates];
        NSString *groupName = [self.dataSource aggregationGroupName:self.aggregation group:indexPath.section];
        [self.dataSource removeAggregation:self.aggregation object:annotation];
        if ([self.dataSource numberOfAggregation:self.aggregation groupName:groupName] == 0) {
            [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
        }
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [tableView endUpdates];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Annotation *annotation = [self.dataSource aggregation:self.aggregation group:indexPath.section index:indexPath.row];
    self.annotationHandler = [[AnnotationHandler alloc] initWithAnnotationType:annotation.type presenter:self];
    self.annotationHandler.delegate = self;
    self.annotationHandler.dataSource = self.dataSource;
    self.annotationHandler.imageDataSource = self.imageDataSource;
    self.annotationHandler.editing = self.editing;
    [self.annotationHandler display:annotation];
}

- (void)refreshData:(id)sender {
    if (self.refreshControl) {
        [self.refreshControl endRefreshing];
    }
    [self.dataSource updateAggregation:self.aggregation object:nil action:@"sort"];
    [self.tableView reloadData];
}

@end