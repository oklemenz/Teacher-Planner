//
//  InlineCountableViewCell.m
//  TeacherPlanner
//
//  Created by Oliver on 07.06.14.
//
//

#import "InlineCountTableViewCell.h"

@implementation InlineCountTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (void)setContext:(id)contextValue source:(id)source userInfo:(NSDictionary *)userInfo {
    self.detailTextLabel.text = [NSString stringWithFormat:@"%ld %@",
                                 (unsigned long)[contextValue count], NSLocalizedString(@"entries", @"")];
}

@end