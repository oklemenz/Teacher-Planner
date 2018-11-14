//
//  Attachment.h
//  TeacherPlanner
//
//  Created by Oliver on 05.10.14.
//
//

#import "JSONRootEntity.h"
#import "Codes.h"

@interface Attachment : JSONRootEntity

@property (nonatomic, strong) NSData *data;

@end