//
//  JSONRootEntity.m
//  TeacherPlanner
//
//  Created by Oliver on 14.10.14.
//
//

#import "JSONRootEntity.h"

@implementation JSONRootEntity 

- (void)setParent:(JSONEntity *)parent {
}

- (JSONEntity *)parent {
    return nil;
}

- (BOOL)isProtected {
    return NO;
}

- (BOOL)suppressProtected {
    return NO;
}

- (void)setSuppressProtected:(BOOL)suppressProtected {
}

@end