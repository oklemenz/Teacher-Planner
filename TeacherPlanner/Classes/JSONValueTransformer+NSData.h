//
//  JSONValueTransformer+NSData.h
//  TeacherPlanner
//
//  Created by Oliver on 19.06.14.
//
//

#import "JSONValueTransformer.h"

@interface JSONValueTransformer (NSData)

- (NSData *)NSDataFromNSString:(NSString*)string;
- (id)JSONObjectFromNSData:(NSData *)data;

@end
