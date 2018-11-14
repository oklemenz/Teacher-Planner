//
//  JSONValueTransformer+NSDateComponents.m
//  TeacherPlanner
//
//  Created by Oliver Klemenz on 02.05.15.
//
//

#import "JSONValueTransformer+NSDateComponents.h"

@implementation JSONValueTransformer (NSDateComponents)

- (NSDateComponents *)NSDateComponentsFromNSString:(NSString*)string {
    NSData *data = [[NSData alloc] initWithBase64EncodedString:string options:0];
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

- (id)JSONObjectFromNSDateComponents:(NSDateComponents *)dateComponents {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dateComponents];
    return [data base64EncodedStringWithOptions:0];
}

@end