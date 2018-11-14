//
//  CodesBase.h
//  TeacherPlanner
//
//  Created by Oliver Klemenz on 18.01.15.
//
//

@interface CodesBase : NSObject

+ (NSInteger)codeCount:(NSString *)code;
+ (NSString *)textForCode:(NSString *)code plural:(BOOL)plural;
+ (NSString *)textForCode:(NSString *)code value:(NSInteger)value;
+ (NSString *)longTextForCode:(NSString *)code value:(NSInteger)value;
+ (NSString *)shortTextForCode:(NSString *)code value:(NSInteger)value;

@end