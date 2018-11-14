//
//  AnnotationContainer.h
//  TeacherPlanner
//
//  Created by Oliver Klemenz on 21.12.14.
//
//

#import "JSONChildEntity.h"
#import "Annotation.h"
#import "AnnotationHandler.h"

@interface AnnotationContainer : JSONChildEntity <AnnotationDataSource, AnnotationReminderLesson>

@property (nonatomic, strong) NSMutableArray<Annotation> *annotation;

@end