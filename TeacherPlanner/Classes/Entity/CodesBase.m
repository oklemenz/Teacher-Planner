//
//  CodesBase.m
//  TeacherPlanner
//
//  Created by Oliver Klemenz on 18.01.15.
//
//

#import "CodesBase.h"

@implementation CodesBase

+ (NSInteger)codeCount:(NSString *)code {
    return 0;
}

+ (NSString *)textForCode:(NSString *)code plural:(BOOL)plural {
    return [CodesBase _text:[NSString stringWithFormat:@"%@%@", code, plural ? @"_PLURAL" : @""]];
}

+ (NSString *)textForCode:(NSString *)code value:(NSInteger)value {
    return [CodesBase _text:[NSString stringWithFormat:@"%@_%tu", code, value]];
}

+ (NSString *)longTextForCode:(NSString *)code value:(NSInteger)value {
    return [CodesBase _text:[NSString stringWithFormat:@"%@_%tu_LONG", code, value]];
}

+ (NSString *)shortTextForCode:(NSString *)code value:(NSInteger)value {
    return [CodesBase _text:[NSString stringWithFormat:@"%@_%tu_SHORT", code, value]];
}

+ (NSString *)_text:(NSString *)textCode {
    NSString *text =  NSLocalizedString(textCode, @"");
    if ([text isEqualToString:textCode]) {
        return @"";
    }
    return text;
}

@end