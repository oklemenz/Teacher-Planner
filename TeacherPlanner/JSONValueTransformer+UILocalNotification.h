//
//  JSONValueTransformer+UILocalNotification.h
//  TeacherPlanner
//
//  Created by Oliver Klemenz on 02.05.15.
//
//

#import "JSONValueTransformer.h"

@interface JSONValueTransformer (UILocalNotification)

- (UILocalNotification *)UILocalNotificationFromNSString:(NSString*)string;
- (id)JSONObjectFromUILocalNotification:(UILocalNotification *)localNotification;

@end