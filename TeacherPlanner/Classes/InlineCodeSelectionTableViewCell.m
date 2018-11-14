//
//  InlineCodeSelectionTableViewCell.m
//  TeacherPlanner
//
//  Created by Oliver on 01.06.14.
//
//

#import "InlineCodeSelectionTableViewCell.h"
#import "InlineCodeSelectionTableViewController.h"
#import "Codes.h"

@implementation InlineCodeSelectionTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (NSString *)code {
    return self.definition[@"code"];
}

- (void)setValue:(id)value {
    super.value = value;
    [self updateContent:NO];
}

- (void)updateContent:(BOOL)animated {
    NSInteger code = [self.value integerValue];
    NSString *text = code > 0 ? [Codes textForCode:self.code value:[self.value integerValue]] : @"";
    self.textLabel.textColor = [UIColor blackColor];
    if (self.label) {
        if (code > 0) {
            self.detailTextLabel.text = text;
        } else {
            self.detailTextLabel.text = NSLocalizedString(@"Not specified", @"");
        }
    } else {
        if (code > 0) {
            self.textLabel.textColor = [UIColor blackColor];
            self.textLabel.text = text;
        } else {
            self.textLabel.textColor = PLACEHOLDER_COLOR;
            self.textLabel.text = self.placeholder;
        }
    }
}

- (void)showSelection:(UINavigationController *)navigationController {
    PropertyBinding *propertyBinding = [[self propertyBinding:@"value"] copy];
    InlineCodeSelectionTableViewController *selectionController =
        [[InlineCodeSelectionTableViewController alloc] initWithCode:self.code
                                                     propertyBinding:propertyBinding];
    [propertyBinding attachControl:selectionController];
    selectionController.selectionMode = self.editing;
    selectionController.hideClear = self.hideClear;
    [navigationController pushViewController:selectionController animated:YES];
}

@end