//
//  JSONValueTransformer+NSData.m
//  TeacherPlanner
//
//  Created by Oliver on 19.06.14.
//
//

#import "JSONValueTransformer+NSData.h"

@implementation JSONValueTransformer(NSData)

- (NSData *)NSDataFromNSString:(NSString *)string {
    return [[NSData alloc] initWithBase64EncodedString:string options:0];
}

- (id)JSONObjectFromNSData:(NSData *)data {
    return [data base64EncodedStringWithOptions:0];
}

@end