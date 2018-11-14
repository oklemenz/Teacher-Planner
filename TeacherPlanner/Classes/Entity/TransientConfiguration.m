//
//  TransientConfiguration.m
//  TeacherPlanner
//
//  Created by Oliver Klemenz on 27.12.14.
//
//

#import "TransientConfiguration.h"
#import "Configuration.h"
#import "UIColor+Extension.h"
#import "SecureStore.h"

@implementation TransientConfiguration

- (void)setBrandingActive:(NSNumber *)brandingActive {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:@([brandingActive boolValue]) forKey:kConfigKeyBrandingActive];
    if ([brandingActive boolValue]) {
        
    }
    [userDefaults synchronize];
}

- (NSNumber *)brandingActive {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults valueForKey:kConfigKeyBrandingActive];
}

- (void)setTitleColor:(UIColor *)titleColor {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:[titleColor hexString] forKey:kConfigKeyBrandingTitleColor];
    [userDefaults synchronize];
}

- (UIColor *)titleColor {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *colorString = [userDefaults valueForKey:kConfigKeyBrandingTitleColor];
    if (!colorString) {
        colorString = kBrandingTitleColorDefault;
    }
    return [UIColor colorWithHexString:colorString];
}

- (void)setHighlightColor:(UIColor *)highlightColor {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:[highlightColor hexString] forKey:kConfigKeyBrandingHighlightColor];
    [userDefaults synchronize];
}

- (UIColor *)highlightColor {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *colorString = [userDefaults valueForKey:kConfigKeyBrandingHighlightColor];
    if (!colorString) {
        colorString = kBrandingHighlightColorDefault;
    }
    return [UIColor colorWithHexString:colorString];
}

- (void)setTopBackgroundColor:(UIColor *)topBackgroundColor {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:[topBackgroundColor hexString] forKey:kConfigKeyBrandingTopBackgroundColor];
    [userDefaults synchronize];
}

- (UIColor *)topBackgroundColor {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *colorString = [userDefaults valueForKey:kConfigKeyBrandingTopBackgroundColor];
    if (!colorString) {
        colorString = kBrandingTopBackgroundColorDefault;
    }
    return [UIColor colorWithHexString:colorString];
}

- (void)setTopButtonColor:(UIColor *)topButtonColor {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:[topButtonColor hexString] forKey:kConfigKeyBrandingTopButtonColor];
    [userDefaults synchronize];
}

- (UIColor *)topButtonColor {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *colorString = [userDefaults valueForKey:kConfigKeyBrandingTopButtonColor];
    if (!colorString) {
        colorString = kBrandingTopButtonColorDefault;
    }
    return [UIColor colorWithHexString:colorString];
}

- (void)setBottomBackgroundColor:(UIColor *)bottomBackgroundColor {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:[bottomBackgroundColor hexString] forKey:kConfigKeyBrandingBottomBackgroundColor];
    [userDefaults synchronize];
}

- (UIColor *)bottomBackgroundColor {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *colorString = [userDefaults valueForKey:kConfigKeyBrandingBottomBackgroundColor];
    if (!colorString) {
        colorString = kBrandingBottomBackgroundColorDefault;
    }
    return [UIColor colorWithHexString:colorString];
}

- (void)setBottomButtonColor:(UIColor *)bottomButtonColor {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:[bottomButtonColor hexString] forKey:kConfigKeyBrandingBottomButtonColor];
    [userDefaults synchronize];
}

- (UIColor *)bottomButtonColor {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *colorString = [userDefaults valueForKey:kConfigKeyBrandingBottomButtonColor];
    if (!colorString) {
        colorString = kBrandingBottomButtonColorDefault;
    }
    return [UIColor colorWithHexString:colorString];
}

- (void)setLightStatusBar:(NSNumber *)lightStatusBar {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:@([lightStatusBar boolValue]) forKey:kConfigKeyBrandingStatusBarLight];
    [userDefaults synchronize];
}

- (NSNumber *)lightStatusBar {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults valueForKey:kConfigKeyBrandingStatusBarLight];
}

- (void)setRequestPasscode:(NSNumber *)requestPasscode {
    NSInteger requestPasscodeMin = 0;
    switch ([requestPasscode integerValue]) {
        default:
        case 1:
            requestPasscodeMin = 0;
            break;
        case 2:
            requestPasscodeMin = 1;
            break;
        case 3:
            requestPasscodeMin = 5;
            break;
        case 4:
            requestPasscodeMin = 10;
            break;
    }
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:@(requestPasscodeMin) forKey:kConfigKeySecurityPasscodeTimeout];
    [userDefaults synchronize];
    [[SecureStore instance] setObject:@(requestPasscodeMin) forKey:kSecureStorePasscodeTimeout];
    [[SecureStore instance] synchronize];
}

- (NSNumber *)requestPasscode {
    NSInteger requestPasscode = 0;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *requestPasscodeMin = [userDefaults valueForKey:kConfigKeySecurityPasscodeTimeout];
    switch ([requestPasscodeMin integerValue]) {
        default:
        case 0:
            requestPasscode = 1;
            break;
        case 1:
            requestPasscode = 2;
            break;
        case 5:
            requestPasscode = 3;
            break;
        case 10:
            requestPasscode = 4;
            break;
    }
    return @(requestPasscode);
}

@end
