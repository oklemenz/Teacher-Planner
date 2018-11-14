//
//  InlineEntitySelectionTableViewCell.m
//  TeacherPlanner
//
//  Created by Oliver Klemenz on 18.12.14.
//
//

#import "InlineEntitySelectionTableViewCell.h"

@implementation InlineEntitySelectionTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [self updateProperty:nil];
    [super setEditing:editing animated:animated];
}

- (void)setUuid:(NSString *)uuid {
    if ([self propertyBinding:@"uuid"]) {
        super.uuid = uuid;
        [self updateProperty:@"uuid"];
    }
}

- (void)setIndex:(NSNumber *)index {
    if ([self propertyBinding:@"index"]) {
        super.index = index;
        [self updateProperty:@"index"];
    }
}

- (void)setEntity:(NSArray *)entity {
    _entity = entity;
    [self updateProperty:nil];
}

- (void)updateProperty:(NSString *)property {
    if (!property) {
        if ([self propertyBinding:@"uuid"]) {
            property = @"uuid";
        } else if ([self propertyBinding:@"index"]) {
            property = @"index";
        }
    }
    if ([property isEqualToString:@"index"] && self.index) {
        NSInteger index = [self.index integerValue];
        if (index >= 0 && index < self.entity.count) {
            NSString *text;
            if (self.descriptionPath) {
                text = [self.entity[index] valueForKeyPath:self.descriptionPath];
            } else {
                text = [self.entity[index] name];
            }
            if (self.showIndex) {
                text = [NSString stringWithFormat:@"%tu. %@", index + 1, text];
            }
            self.detailTextLabel.text = text;
            return;
        }
    }
    if ([property isEqualToString:@"uuid"] && self.uuid) {
        NSString *uuid = self.uuid;
        NSInteger index = 0;
        for (JSONEntity *entity in self.entity) {
            if (entity.uuid == uuid) {
                NSString *text;
                if (self.descriptionPath) {
                    text = [entity valueForKeyPath:self.descriptionPath];
                } else {
                    text = entity.name;
                }
                if (self.showIndex) {
                    text = [NSString stringWithFormat:@"%tu. %@", index + 1, text];
                }
                self.detailTextLabel.text = text;
                return;
            }
            index++;
        }
    }
    self.detailTextLabel.text = NSLocalizedString(@"Not specified", @"");
}

- (void)reset {
    [super reset];
    self.entity = nil;
    _descriptionPath = nil;
    _showIndex = NO;
}

@end