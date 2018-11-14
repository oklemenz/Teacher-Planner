//
//  Bindable.m
//  TeacherPlanner
//
//  Created by Oliver on 28.06.14.
//
//

#import "Bindable.h"
#import "NSString+Extension.h"
#import "objc/message.h"

@implementation Bindable

+ (void)setOptions:(id)bindable options:(NSDictionary *)options {
    if (options) {
        for (NSString *key in [options allKeys]) {
            id value = [options valueForKeyPath:key];
            if ([bindable respondsToSelector:NSSelectorFromString(key)] ||
                [bindable respondsToSelector:NSSelectorFromString([NSString stringWithFormat:@"set%@:", [key capitalize]])]) {
                [bindable setValue:value forKeyPath:key];
            }
        }
    }
}

@end