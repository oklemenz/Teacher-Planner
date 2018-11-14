//
//  TransientNewExport.h
//  TeacherPlanner
//
//  Created by Oliver Klemenz on 30.12.14.
//
//

#import "JSONTransientEntity.h"

@interface TransientNewExport : JSONTransientEntity

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *retypePassword;
@property (nonatomic, strong) NSNumber *secureTextEntry;

@end