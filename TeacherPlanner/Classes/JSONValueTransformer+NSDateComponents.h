//
//  JSONValueTransformer+NSDateComponents.h
//  TeacherPlanner
//
//  Created by Oliver Klemenz on 02.05.15.
//
//

#import "JSONValueTransformer.h"

@interface JSONValueTransformer (NSDateComponents)

- (NSDateComponents *)NSDateComponentsFromNSString:(NSString*)string;
- (id)JSONObjectFromNSDateComponents:(NSDateComponents *)dateComponents;

@end