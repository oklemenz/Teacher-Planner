//
//  TransientReminder.h
//  TeacherPlanner
//
//  Created by Oliver Klemenz on 01.05.15.
//
//

#import "JSONTransientEntity.h"
#import "Annotation.h"

@interface TransientReminder : JSONTransientEntity

@property (nonatomic, strong) NSString *status;
@property (nonatomic) NSInteger lesson;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic) NSInteger offset;
@property (nonatomic) NSDateComponents *offsetDateComponents;
@property (nonatomic, strong) NSDate *fireDate;

@property (nonatomic, weak) Annotation *annotation;

@end