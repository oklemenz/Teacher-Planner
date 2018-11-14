//
//  ContextBinding.h
//  TeacherPlanner
//
//  Created by Oliver Klemenz on 18.12.14.
//
//

#import "PropertyBinding.h"

@interface ContextBinding : PropertyBinding

- (instancetype)initWithEntity:(JSONEntity *)entity context:(NSString *)context;

- (ContextBinding *)appendContext:(NSString *)context;
- (ContextBinding *)appendContext:(NSString *)context row:(NSInteger)row;
- (ContextBinding *)appendRow:(NSInteger)row;

+ (ContextBinding *)createContextBinding:(JSONEntity *)entity context:(NSString *)context;

+ (NSString *)appendContext:(NSString *)context subContext:(NSString *)subContext;
+ (NSString *)appendContext:(NSString *)context row:(NSInteger)row;
+ (NSString *)appendContext:(NSString *)context subContext:(NSString *)subContext row:(NSInteger)row;

@end
