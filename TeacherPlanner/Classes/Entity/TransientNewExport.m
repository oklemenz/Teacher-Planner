//
//  TransientNewExport.m
//  TeacherPlanner
//
//  Created by Oliver Klemenz on 30.12.14.
//
//

#import "TransientNewExport.h"
#import "Utilities.h"

@implementation TransientNewExport

- (instancetype)init {
    self = [super init];
    if (self) {
        NSString *formattedDate = [[Utilities technicalDateTimeFormatter] stringFromDate:[NSDate new]];
        self.name = [NSString stringWithFormat:@"%@_%@", NSLocalizedString(@"TP", @""), formattedDate];
        self.secureTextEntry = @(YES);
    }
    return self;
}

@end