//
//  Word.h
//  TeacherPlanner
//
//  Created by Oliver Klemenz on 16.08.15.
//
//

#import "JSONChildEntity.h"

@protocol Word
@end

@interface Word : JSONChildEntity

@property (nonatomic, strong) NSString *name;

@end