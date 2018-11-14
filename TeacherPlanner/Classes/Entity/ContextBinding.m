//
//  ContextBinding.m
//  TeacherPlanner
//
//  Created by Oliver Klemenz on 18.12.14.
//
//

#import "ContextBinding.h"
#import "NSString+Extension.h"
#import "Model.h"
#import "Application.h"

@implementation ContextBinding

- (instancetype)initWithEntity:(JSONEntity *)entity context:(NSString *)context {
    if (context) {
        if ([context rangeOfString:@"/"].location == 0) {
            entity = [[Model instance] application];
            context = [context substringFromIndex:1];
        } else if ([context isEqualToString:@""]) {
            context = nil;
        }
    }
    self = [super initWithEntity:entity context:context property:nil];
    if (self) {
    }
    return self;
}

- (ContextBinding *)appendContext:(NSString *)context {
    ContextBinding *contextBinding = [ContextBinding createContextBinding:self.entity context:context];
    if (contextBinding.entity == self.entity) {
        contextBinding = [ContextBinding createContextBinding:contextBinding.entity
                                            context:[ContextBinding appendContext:self.context subContext:contextBinding.context]];
    }
    return contextBinding;
}

- (ContextBinding *)appendContext:(NSString *)context row:(NSInteger)row {
    ContextBinding *contextBinding = [ContextBinding createContextBinding:self.entity context:context];
    if (contextBinding.entity == self.entity) {
        contextBinding = [ContextBinding createContextBinding:contextBinding.entity
                                                      context:[ContextBinding appendContext:self.context subContext:contextBinding.context row:row]];
    }
    return contextBinding;
}

- (ContextBinding *)appendRow:(NSInteger)row {
    return [ContextBinding createContextBinding:self.entity
                                        context:[ContextBinding appendContext:self.context row:row]];
}

- (id)copyWithZone:(NSZone *)zone {
    return [[ContextBinding alloc] initWithEntity:self.entity context:self.context];
}

+ (ContextBinding *)createContextBinding:(JSONEntity *)entity context:(NSString *)context {
    return [[ContextBinding alloc] initWithEntity:entity context:context];
}

+ (NSString *)appendContext:(NSString *)context subContext:(NSString *)subContext {
    NSString *resultContext = nil;
    if (context && subContext) {
        resultContext = [NSString stringWithFormat:@"%@/%@", context, subContext];
    } else if (context) {
        resultContext = context;
    } else if (subContext) {
        resultContext = subContext;
    }
    return resultContext;
}

+ (NSString *)appendContext:(NSString *)context row:(NSInteger)row {
    return [NSString stringWithFormat:@"%@/%tu", context, row];
}

+ (NSString *)appendContext:(NSString *)context subContext:(NSString *)subContext row:(NSInteger)row {
    return [ContextBinding appendContext:[ContextBinding appendContext:context subContext:subContext] row:row];
}

- (BOOL)isContextBinding {
    return YES;
}

@end