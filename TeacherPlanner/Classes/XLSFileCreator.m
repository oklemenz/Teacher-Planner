//
//  XLSFileCreator.m
//  TeacherPlanner
//
//  Created by Oliver Klemenz on 15.02.15.
//
//

#import "XLSFileCreator.h"
#import <libxml/tree.h>
#import <libxml/parser.h>

#define kXLSRepeatBeginRegEx @"\\{\\{#([a-zA-Z0-9_]*)\\}\\}"
#define kXLSRepeatEndRegEx   @"\\{\\{/%@\\}\\}"
#define kXLSVariableRegEx    @"\\{\\{([a-zA-Z0-9_]*)\\}\\}"

@interface XLSFileCreator ()
@property (nonatomic, strong) NSDictionary *data;
@end

@implementation XLSFileCreator

- (instancetype)initWithData:(NSDictionary *)data {
    self = [super init];
    if (self) {
        self.data = data;
    }
    return self;
}

- (void)testData {
    // TODO: Remove
    NSArray *exams = @[
                       @{ kXLSCreateDataExamName : @"KA1",
                          kXLSCreateDataExamType : @(kXLSCreateTypeGrade),
                          kXLSCreateDataExamWeight : @(2),
                          kXLSCreateDataExamAverage : @(4.5) },
                       @{ kXLSCreateDataExamName : @"MD1",
                          kXLSCreateDataExamType : @(kXLSCreateTypeGrade),
                          kXLSCreateDataExamWeight : @(1),
                          kXLSCreateDataExamAverage : @(4.5) },
                       @{ kXLSCreateDataExamName : @"KA2",
                          kXLSCreateDataExamType : @(kXLSCreateTypeGrade),
                          kXLSCreateDataExamWeight : @(2),
                          kXLSCreateDataExamAverage : @(4.5) },
                       @{ kXLSCreateDataExamName : @"MD2",
                          kXLSCreateDataExamType : @(kXLSCreateTypeGrade),
                          kXLSCreateDataExamWeight : @(1),
                          kXLSCreateDataExamAverage : @(4.5) },
                       @{ kXLSCreateDataExamName : @"HJN",
                          kXLSCreateDataExamType : @(kXLSCreateTypeAverageAll),
                          kXLSCreateDataExamAverage : @(4.5) },
                       @{ kXLSCreateDataExamName : @"KA3",
                          kXLSCreateDataExamType : @(kXLSCreateTypeGrade),
                          kXLSCreateDataExamWeight : @(2),
                          kXLSCreateDataExamAverage : @(4.5) },
                       @{ kXLSCreateDataExamName : @"MD3",
                          kXLSCreateDataExamType : @(kXLSCreateTypeGrade),
                          kXLSCreateDataExamWeight : @(1),
                          kXLSCreateDataExamAverage : @(4.5) },
                       @{ kXLSCreateDataExamName : @"KA4",
                          kXLSCreateDataExamType : @(kXLSCreateTypeGrade),
                          kXLSCreateDataExamWeight : @(2),
                          kXLSCreateDataExamAverage : @(4.5) },
                       @{ kXLSCreateDataExamName : @"MD4",
                          kXLSCreateDataExamType : @(kXLSCreateTypeGrade),
                          kXLSCreateDataExamWeight : @(1),
                          kXLSCreateDataExamAverage : @(4.5) },
                       @{ kXLSCreateDataExamName : @"GJN",
                          kXLSCreateDataExamType : @(kXLSCreateTypeAverageSection),
                          kXLSCreateDataExamAverage : @(4.5) }];
    
    NSArray *students = @[
                          @{ kXLSCreateDataStudentName : @"A",
                             kXLSCreateDataStudentExams : @[
                                     @{ kXLSCreateDataStudentGrade : @(1) },
                                     @{ kXLSCreateDataStudentGrade : @(2) },
                                     @{ kXLSCreateDataStudentGrade : @(3) },
                                     @{ kXLSCreateDataStudentGrade : @(4) },
                                     @{ kXLSCreateDataStudentGrade : @(2.3333333333333335),
                                        kXLSCreateDataStudentFormula : [self examFormula:exams position:4] },
                                     @{ kXLSCreateDataStudentGrade : @(5) },
                                     @{ kXLSCreateDataStudentGrade : @(6) },
                                     @{ kXLSCreateDataStudentGrade : @(7) },
                                     @{ kXLSCreateDataStudentGrade : @(8) },
                                     @{ kXLSCreateDataStudentGrade : @(6.333333333333333),
                                        kXLSCreateDataStudentFormula : [self examFormula:exams position:9] }
                                     ]
                             },
                          @{ kXLSCreateDataStudentName : @"B",
                             kXLSCreateDataStudentExams : @[
                                     @{ kXLSCreateDataStudentGrade : @(8) },
                                     @{ kXLSCreateDataStudentGrade : @(7) },
                                     @{ kXLSCreateDataStudentGrade : @(6) },
                                     @{ kXLSCreateDataStudentGrade : @(5) },
                                     @{ kXLSCreateDataStudentGrade : @(6.666666666666667),
                                        kXLSCreateDataStudentFormula : [self examFormula:exams position:4] },
                                     @{ kXLSCreateDataStudentGrade : @(4) },
                                     @{ kXLSCreateDataStudentGrade : @(3) },
                                     @{ kXLSCreateDataStudentGrade : @(2) },
                                     @{ kXLSCreateDataStudentGrade : @(1) },
                                     @{ kXLSCreateDataStudentGrade : @(2.6666666666666665),
                                        kXLSCreateDataStudentFormula : [self examFormula:exams position:9] },
                                     ]
                             }];
    
    NSMutableArray *columns = [@[] mutableCopy];
    NSMutableArray *rows = [@[] mutableCopy];
    
    for (NSInteger i = 0; i < exams.count + 1; i++) {
        NSDictionary *exam = nil;
        if (i > 0) {
            exam = exams[i - 1];
        }
        NSString *examName = exam[kXLSCreateDataExamName];
        NSInteger examType = [exam[kXLSCreateDataExamType] integerValue];
        CGFloat average = [exam[kXLSCreateDataExamAverage] floatValue];
        
        [columns addObject:@{
                             @"CAPTION_STYLE" : (i == 0 ? @"s62" : (examType == 1 ? @"s63" : @"s64")),
                             @"CAPTION" : (i == 0 ? NSLocalizedString(@"Name", @"") : examName),
                             @"AVG_STYLE" : (i == 0 ? @"s71" : (examType == 1 ? @"s72" : @"s73")),
                             @"AVG_TYPE" : (i == 0 ? @"String" : @"Number"),
                             @"AVG_FORMULA" : (i == 0 ? @"" : [self avgFormula:students.count]),
                             @"AVG_CONTENT" : (i == 0 ? NSLocalizedString(@"Average", @"") : @(average))
                             }];
    }
    
    for (NSDictionary *student in students) {
        NSMutableArray *cells = [@[] mutableCopy];
        for (NSInteger i = 0; i < exams.count + 1; i++) {
            NSDictionary *exam = nil;
            NSDictionary *studentExam = nil;
            if (i > 0) {
                exam = exams[i - 1];
                studentExam = student[kXLSCreateDataStudentExams][i - 1];
            }
            NSInteger examType = [exam[kXLSCreateDataExamType] integerValue];
            [cells addObject:@{
                               @"CONTENT_STYLE" : (i == 0 ? @"s65" : (examType == 1 ? @"s66" : @"s67")),
                               @"CONTENT_FORMULA" : (examType > 1 ? studentExam[kXLSCreateDataStudentFormula] : @""),
                               @"CONTENT_TYPE" : (i == 0 ? @"String" : @"Number"),
                               @"CONTENT" : (i == 0 ? student[kXLSCreateDataExamName] : studentExam[kXLSCreateDataStudentGrade]),
                               }];
        }
        [rows addObject:@{ @"CELL" : cells }];
    }
    
    self.data = @{ @"AUTHOR" : @"Oliver Klemenz",
                   @"CREATED" : @"2015-01-30T14:24:00Z",
                   @"FONT_NAME" : @"Calibri",
                   @"FONT_FAMILY" : @"Swiss",
                   @"FONT_SIZE" : @(12),
                   @"FONT_COLOR" : @"#000000",
                   @"NAME" : @"BAS",
                   @"COLUMN" : columns,
                   @"ROW" : rows,
                   @"COLUMN_COUNT" : @(columns.count),
                   @"ROW_COUNT" : @(rows.count + 2) };
}

- (void)create:(NSString *)filePath fileTemplate:(NSString *)fileTemplate {
    NSString *content = [self applyTemplateFromFile:fileTemplate entity:self.data];
    content = [XLSFileCreator prettyPrintXML:content];
    [content writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

- (NSString *)examFormula:(NSArray *)exams position:(NSInteger)position {
    // Example: =(RC[-4]*2+RC[-3]+RC[-2]*2+RC[-1])/(COUNT(RC[-4])*2+COUNT(RC[-3])+COUNT(RC[-2])*2+COUNT(RC[-1]))
    if (exams.count <= 1 || position < 0 || position >= exams.count) {
        return @"";
    }
    NSDictionary *exam = exams[position];
    NSInteger positionExamType = [exam[kXLSCreateDataExamType] integerValue];
    if (positionExamType <= kXLSCreateTypeGrade) {
        return @"";
    }
    NSString *formula = @"=(";
    for (NSInteger i = position - 1; i >= 0; i--) {
        NSDictionary *exam = exams[i];
        NSInteger examType = [exam[kXLSCreateDataExamType] integerValue];
        if (positionExamType == kXLSCreateTypeAverageSection && examType > kXLSCreateTypeGrade) {
            break;
        }
        if (examType == kXLSCreateTypeGrade) {
            if (i < position - 1) {
                formula = [formula stringByAppendingString:@"+"];
            }
            NSInteger examWeight = [exam[kXLSCreateDataExamWeight] integerValue];
            formula = [formula stringByAppendingFormat:@"RC[%@]", @(i - position)];
            if (examWeight && examWeight > 1) {
                formula = [formula stringByAppendingFormat:@"*%@", @(examWeight)];
            }
        }
    }
    formula = [formula stringByAppendingString:@")/("];
    for (NSInteger i = position-1; i >= 0; i--) {
        NSDictionary *exam = exams[i];
        NSInteger examType = [exam[kXLSCreateDataExamType] integerValue];
        if (positionExamType == kXLSCreateTypeAverageSection && examType > kXLSCreateTypeGrade) {
            break;
        }
        if (examType == kXLSCreateTypeGrade) {
            if (i < position - 1) {
                formula = [formula stringByAppendingString:@"+"];
            }
            NSInteger examWeight = [exam[kXLSCreateDataExamWeight] integerValue];
            formula = [formula stringByAppendingFormat:@"COUNT(RC[%@])", @(i - position)];
            if (examWeight && examWeight > 1) {
                formula = [formula stringByAppendingFormat:@"*%@", @(examWeight)];
            }
        }
    }
    return [formula stringByAppendingString:@")"];
}

- (NSString *)avgFormula:(NSInteger)students {
    return [NSString stringWithFormat:@"=AVERAGE(R[%@]C:R[%@]C)", @(-students), @(-1)];
}

- (NSString *)applyTemplateFromFile:(NSString *)file entity:(NSDictionary *)entity {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:file ofType:@"xml"];
    NSString *fileContent = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    return [self applyTemplate:fileContent entity:entity level:0];
}

- (NSString *)applyTemplate:(NSString *)template entity:(NSDictionary *)entity level:(NSInteger)level {
    NSString *result = template;
    
    NSRegularExpression *repeatBeginRegex = [NSRegularExpression regularExpressionWithPattern:kXLSRepeatBeginRegEx options:0 error:nil];
    NSArray *matches = [repeatBeginRegex matchesInString:result options:0 range:NSMakeRange(0, [result length])];
    
    while (matches.count > 0) {
        NSTextCheckingResult *match = matches[0];
        NSInteger repeatStartIndex = match.range.location;
        NSInteger startIndex = match.range.location + match.range.length;
        NSString *entityName = [result substringWithRange:[match rangeAtIndex:1]];
        
        NSAssert(entityName.length > 0, @"Empty entity name");
        NSAssert(entity[entityName], ([NSString stringWithFormat:@"Entity '%@' is not in model", entityName]));
        NSAssert([entity[entityName] isKindOfClass:NSArray.class], ([NSString stringWithFormat:@"Entity '%@' is not of type array", entityName]));
        
        NSArray *repeatEntity = entity[entityName];
        
        NSError *error;
        NSString *repeatEndRegexString = [NSString stringWithFormat:kXLSRepeatEndRegEx, entityName];
        NSRegularExpression *repeatEndRegex = [NSRegularExpression regularExpressionWithPattern:repeatEndRegexString options:0 error:&error];
        NSAssert(!error, ([NSString stringWithFormat:@"Invalid regex '%@'", repeatEndRegexString]));
        
        matches = [repeatEndRegex matchesInString:result options:0 range:NSMakeRange(0, [result length])];
        if (matches.count > 0) {
            NSTextCheckingResult *match = matches[0];
            NSInteger repeatEndIndex = match.range.location + match.range.length;
            NSInteger endIndex = match.range.location;
            
            NSRange range = {.location = startIndex, .length = endIndex - startIndex};
            NSString *repeatPart = [[result substringWithRange:range] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            
            NSString *rest = [result substringFromIndex:repeatEndIndex];
            result = [result substringToIndex:repeatStartIndex];
            
            for (NSDictionary *childEntity in repeatEntity) {
                NSString *recursiveResult = [self applyTemplate:repeatPart entity:childEntity level:level + 1];
                result = [result stringByAppendingString:recursiveResult];
            }
            
            result = [result stringByAppendingString:rest];
        }
        
        matches = [repeatBeginRegex matchesInString:result options:0 range:NSMakeRange(0, [result length])];
    }
    
    NSRegularExpression *variableRegex = [NSRegularExpression regularExpressionWithPattern:kXLSVariableRegEx options:0 error:nil];
    matches = [variableRegex matchesInString:result options:0 range:NSMakeRange(0, [result length])];
    
    for (NSInteger i = matches.count - 1; i >= 0; i--) {
        NSTextCheckingResult *match = matches[i];
        NSString *variable = [result substringWithRange:[match rangeAtIndex:1]];
        id value = entity[variable];
        if (!value) {
            value = @"";
        }
        NSString *replacedResult = [result substringToIndex:match.range.location];
        replacedResult = [replacedResult stringByAppendingString:[NSString stringWithFormat:@"%@", value]];
        replacedResult = [replacedResult stringByAppendingString:[result substringFromIndex:match.range.location + match.range.length]];
        result = replacedResult;
    }
    
    return result;
}

+ (NSString *)prettyPrintXML:(NSString *)rawXML {
    const char *utf8Str = [rawXML UTF8String];
    xmlDocPtr doc = xmlReadMemory(utf8Str, (int)strlen(utf8Str), NULL, NULL, XML_PARSE_NOCDATA | XML_PARSE_NOBLANKS);
    xmlNodePtr root = xmlDocGetRootElement(doc);
    xmlNodePtr xmlNode = xmlCopyNode(root, 1);
    xmlFreeDoc(doc);
    
    NSString *str = nil;
    
    xmlBufferPtr buff = xmlBufferCreate();
    doc = NULL;
    int level = 0;
    int format = 1;
    
    int result = xmlNodeDump(buff, doc, xmlNode, level, format);
    
    if (result > -1) {
        str = [[NSString alloc] initWithBytes:(xmlBufferContent(buff))
                                       length:(NSUInteger)(xmlBufferLength(buff))
                                     encoding:NSUTF8StringEncoding];
    }
    xmlBufferFree(buff);
    
    NSCharacterSet *ws = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmed = [str stringByTrimmingCharactersInSet:ws];
    return [@"<?xml version=\"1.0\"?>\n" stringByAppendingString:trimmed];
}

@end
