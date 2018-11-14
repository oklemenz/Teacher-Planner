//
//  Lesson.h
//  TeacherPlanner
//
//  Created by Oliver Klemenz on 14.03.15.
//
//

#import "JSONChildEntity.h"

@protocol Lesson
@end

@interface Lesson : JSONChildEntity

@property (nonatomic, strong) NSNumber *weekDay;
@property (nonatomic, strong) NSNumber *timeStart;
@property (nonatomic, strong) NSNumber *timeEnd;
@property (nonatomic, strong) NSString *room;

@end