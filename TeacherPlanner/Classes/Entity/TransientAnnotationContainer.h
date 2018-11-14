//
//  TransientAnnotationContainer.h
//  TeacherPlanner
//
//  Created by Oliver Klemenz on 25.05.15.
//
//

#import "JSONTransientEntity.h"
#import "Annotation.h"
#import "AnnotationHandler.h"
#import "AnnotationContainer.h"

@interface TransientAnnotationContainer : JSONTransientEntity <AnnotationDataSource>

@property (nonatomic, strong) NSMutableArray<Annotation> *annotation;
@property (nonatomic, strong) AnnotationContainer *delegate;
@property (nonatomic, strong) NSDate *date;

@end