//
//  JSONTransientEntity.m
//  TeacherPlanner
//
//  Created by Oliver Klemenz on 18.01.15.
//
//

#import "JSONTransientEntity.h"

@implementation JSONTransientEntity

+ (id)load:(NSString *)uuid {
    return nil;
}

- (BOOL)store {
    return NO;
}

- (void)setParent:(JSONEntity *)parent {
}

- (JSONEntity *)parent {
    return nil;
}

@end