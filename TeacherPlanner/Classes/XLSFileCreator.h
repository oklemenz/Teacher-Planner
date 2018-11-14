//
//  XLSFileCreator.h
//  TeacherPlanner
//
//  Created by Oliver Klemenz on 15.02.15.
//
//

#import <Foundation/Foundation.h>

#define kXLSCreateTypeGrade          1
#define kXLSCreateTypeAverageAll     2
#define kXLSCreateTypeAverageSection 3

#define kXLSCreateDataExamName       @"name"
#define kXLSCreateDataExamType       @"type"
#define kXLSCreateDataExamWeight     @"weight"
#define kXLSCreateDataExamAverage    @"average"
#define kXLSCreateDataStudentName    @"name"
#define kXLSCreateDataStudentExams   @"exams"
#define kXLSCreateDataStudentGrade   @"grade"
#define kXLSCreateDataStudentFormula @"formula"

@interface XLSFileCreator : NSObject

- (instancetype)initWithData:(NSDictionary *)data;
- (void)create:(NSString *)filePath fileTemplate:(NSString *)fileTemplate;

@end
