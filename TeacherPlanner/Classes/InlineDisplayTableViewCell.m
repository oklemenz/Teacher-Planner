//
//  InlineDisplayTableViewCell.m
//  TeacherPlanner
//
//  Created by Oliver Klemenz on 14.03.15.
//
//

#import "InlineDisplayTableViewCell.h"

@implementation InlineDisplayTableViewCell

- (void)setValue:(id)value {
    super.value = value;
    [self setText:value];
}

- (void)setDetailValue:(id)detailValue {
    super.detailValue = detailValue;
    [self setDetailText:detailValue];
}

@end