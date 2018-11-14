//
//  XMLReader.h
//  TeacherPlanner
//
//  Created by Oliver Klemenz on 09.03.15.
//
//


#import <Foundation/Foundation.h>


@interface XMLReader : NSObject <NSXMLParserDelegate> {
}

+ (NSDictionary *)dictionaryForXMLData:(NSData *)data error:(NSError **)errorPointer;
+ (NSDictionary *)dictionaryForXMLString:(NSString *)string error:(NSError **)errorPointer;

@end