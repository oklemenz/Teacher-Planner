//
//  XMLReader.m
//  TeacherPlanner
//
//  Created by Oliver Klemenz on 09.03.15.
//
//

#import "XMLReader.h"

NSString *const kXMLReaderTextNodeKey = @"text";

@interface XMLReader () {
    NSMutableArray *dictionary;
    NSMutableString *textString;
    NSError __autoreleasing **xmlError;
}

- (id)initWithError:(NSError **)error;
- (NSDictionary *)objectWithData:(NSData *)data;

@end

@implementation XMLReader

+ (NSDictionary *)dictionaryForXMLData:(NSData *)data error:(NSError **)error {
    XMLReader *reader = [[XMLReader alloc] initWithError:error];
    NSDictionary *rootDictionary = [reader objectWithData:data];
    return rootDictionary;
}

+ (NSDictionary *)dictionaryForXMLString:(NSString *)string error:(NSError **)error {
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    return [XMLReader dictionaryForXMLData:data error:error];
}

- (id)initWithError:(NSError **)error {
    if (self = [super init]) {
        xmlError = error;
    }
    return self;
}

- (NSDictionary *)objectWithData:(NSData *)data {
    dictionary = [@[] mutableCopy];
    textString = [@"" mutableCopy];
    [dictionary addObject:[@{} mutableCopy]];
    
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    parser.delegate = self;
    BOOL success = [parser parse];
    
    if (success) {
        return [dictionary objectAtIndex:0];
    }
    return nil;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {

    NSMutableDictionary *parentDict = [dictionary lastObject];

    NSMutableDictionary *childDict = [@{} mutableCopy];
    [childDict addEntriesFromDictionary:attributeDict];
    
    id existingValue = [parentDict objectForKey:elementName];
    if (existingValue) {
        NSMutableArray *array = nil;
        if ([existingValue isKindOfClass:NSMutableArray.class]) {
            array = (NSMutableArray *)existingValue;
        } else {
            array = [@[] mutableCopy];
            [array addObject:existingValue];
            [parentDict setObject:array forKey:elementName];
        }
        [array addObject:childDict];
    } else {
        [parentDict setObject:childDict forKey:elementName];
    }
    [dictionary addObject:childDict];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    NSMutableDictionary *dictInProgress = [dictionary lastObject];
    if ([textString length] > 0) {
        [dictInProgress setObject:textString forKey:kXMLReaderTextNodeKey];
        textString = [@"" mutableCopy];
    }
    [dictionary removeLastObject];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    [textString appendString:string];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    *xmlError = parseError;
}

@end