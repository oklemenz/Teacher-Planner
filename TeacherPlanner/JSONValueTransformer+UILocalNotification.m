//
//  JSONValueTransformer+UILocalNotification.m
//  TeacherPlanner
//
//  Created by Oliver Klemenz on 02.05.15.
//
//

#import "JSONValueTransformer+UILocalNotification.h"

@implementation JSONValueTransformer (UILocalNotification)

- (UILocalNotification *)UILocalNotificationFromNSString:(NSString*)string {
    NSData *data = [[NSData alloc] initWithBase64EncodedString:string options:0];
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

- (id)JSONObjectFromUILocalNotification:(UILocalNotification *)localNotification {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:localNotification];
    return [data base64EncodedStringWithOptions:0];
}

@end