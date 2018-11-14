//
//  Configuration.m
//  TeacherPlanner
//
//  Created by Oliver on 03.08.14.
//
//

#import "Configuration.h"
#import "Utilities.h"
#import "UIColor+Extension.h"
#import "Common.h"
#import "AppDelegate.h"
#import "RootViewController.h"

@interface Configuration ()
@end

@implementation Configuration

- (instancetype)init {
    self = [super init];
    if (self) {
        _configurableKeys = @[kConfigKeyBrandingActive,
                              kConfigKeyBrandingTitleColor,
                              kConfigKeyBrandingHighlightColor,
                              kConfigKeyBrandingTopBackgroundColor,
                              kConfigKeyBrandingTopButtonColor,
                              kConfigKeyBrandingBottomBackgroundColor,
                              kConfigKeyBrandingBottomButtonColor,
                              kConfigKeyBrandingStatusBarLight];
    }
    return self;
}

+ (id)instance {
    static Configuration *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [Configuration new];
    });
    return instance;
}

- (void)check {
    NSMutableDictionary *configuration = [@{} mutableCopy];
    NSDictionary *configDict = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
    for (NSString *configKey in [configDict allKeys]) {
        if ([self.configurableKeys indexOfObject:configKey] != NSNotFound) {
            configuration[configKey] = configDict[configKey];
        }
    }
    if (self.configuration && ![self.configuration isEqualToDictionary:configuration]) {
        [Common showConfirmation:[AppDelegate instance].rootViewController
                           title:NSLocalizedString(@"Configuration Changed!", @"")
                         message:NSLocalizedString(@"Branding settings only apply after complete restart of the app. Do you want to restart the app after next app close?", @"")
                   okButtonTitle:NSLocalizedString(@"Yes", @"") destructive:NO cancelButtonTitle:NSLocalizedString(@"No", @"") okHandler:^{
                       self->_exitOnResignActive = YES;
                   } cancelHandler:nil];
    }
    _configuration = configuration;
}

- (void)applyColors {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    _brandingActive = [userDefaults boolForKey:kConfigKeyBrandingActive];
    
    if (!self.brandingActive) {
        
        _highlightColor = [UIView new].tintColor;
        _titleColor = [UIColor blackColor];
        _topBackgroundColor = [UIColor colorWithWhite:247.0/255.0 alpha:1.0];
        _topButtonColor = _highlightColor;
        _bottomBackgroundColor = _topBackgroundColor;
        _bottomButtonColor = _highlightColor;
        
        _brandingStatusBarLight = NO;
        [self applyStatusBarColor];
        
    } else {
        
        // Title Color
        NSString *brandingTitleColorHexString = [userDefaults valueForKey:kConfigKeyBrandingTitleColor];
        if (!brandingTitleColorHexString) {
            brandingTitleColorHexString = kBrandingTitleColorDefault;
            [userDefaults setValue:brandingTitleColorHexString forKey:kConfigKeyBrandingTitleColor];
        }
        UIColor *brandingTitleColor = [UIColor colorWithHexString:brandingTitleColorHexString];
        if (brandingTitleColor) {
            _titleColor = brandingTitleColor;
        }
        
        // Highlight Color
        NSString *brandingHighlightColorHexString = [userDefaults valueForKey:kConfigKeyBrandingHighlightColor];
        if (!brandingHighlightColorHexString) {
            brandingHighlightColorHexString = kBrandingHighlightColorDefault;
            [userDefaults setValue:brandingHighlightColorHexString forKey:kConfigKeyBrandingHighlightColor];
        }
        UIColor *brandingHighlightColor = [UIColor colorWithHexString:brandingHighlightColorHexString];
        if (brandingHighlightColor) {
            _highlightColor = brandingHighlightColor;
        }
        
        // Top Background Color
        NSString *brandingTopBackgroundColorHexString = [userDefaults valueForKey:kConfigKeyBrandingTopBackgroundColor];
        if (!brandingTopBackgroundColorHexString) {
            brandingTopBackgroundColorHexString = kBrandingTopBackgroundColorDefault;
            [userDefaults setValue:brandingTopBackgroundColorHexString forKey:kConfigKeyBrandingTopBackgroundColor];
        }
        UIColor *brandingTopBackgroundColor = [UIColor colorWithHexString:brandingTopBackgroundColorHexString];
        if (brandingTopBackgroundColor) {
            _topBackgroundColor = brandingTopBackgroundColor;
        }
        
        // Top Button Color
        NSString *brandingTopButtonColorHexString = [userDefaults valueForKey:kConfigKeyBrandingTopButtonColor];
        if (!brandingTopButtonColorHexString) {
            brandingTopButtonColorHexString = kBrandingTopButtonColorDefault;
            [userDefaults setValue:brandingTopButtonColorHexString forKey:kConfigKeyBrandingTopButtonColor];
        }
        UIColor *brandingTopButtonColor = [UIColor colorWithHexString:brandingTopButtonColorHexString];
        if (brandingTopButtonColor) {
            _topButtonColor = brandingTopButtonColor;
        }
        
        // Bottom Background Color
        NSString *brandingBottomBackgroundColorHexString = [userDefaults valueForKey:kConfigKeyBrandingBottomBackgroundColor];
        if (!brandingBottomBackgroundColorHexString) {
            brandingBottomBackgroundColorHexString = kBrandingBottomBackgroundColorDefault;
            [userDefaults setValue:brandingBottomBackgroundColorHexString forKey:kConfigKeyBrandingBottomBackgroundColor];
        }
        UIColor *brandingBottomBackgroundColor = [UIColor colorWithHexString:brandingBottomBackgroundColorHexString];
        if (brandingBottomBackgroundColor) {
            _bottomBackgroundColor = brandingBottomBackgroundColor;
        }
        
        // Bottom Button Color
        NSString *brandingBottomButtonColorHexString = [userDefaults valueForKey:kConfigKeyBrandingBottomButtonColor];
        if (!brandingBottomButtonColorHexString) {
            brandingBottomButtonColorHexString = kBrandingBottomButtonColorDefault;
            [userDefaults setValue:brandingBottomButtonColorHexString forKey:kConfigKeyBrandingBottomButtonColor];
        }
        UIColor *brandingBottomButtonColor = [UIColor colorWithHexString:brandingBottomButtonColorHexString];
        if (brandingBottomButtonColor) {
            _bottomButtonColor = brandingBottomButtonColor;
        }

        _brandingStatusBarLight = [userDefaults boolForKey:kConfigKeyBrandingStatusBarLight];
        
        [userDefaults synchronize];
    }

    _lightHighlightColor = [self.highlightColor colorWithAlphaComponent:0.3f];
    if ([self.topBackgroundColor colorIsDark]) {
        _disabledTopButtonColor = [self.topBackgroundColor blendWithColor:self.topButtonColor alpha:0.5f];
    } else {
        if ([self.bottomButtonColor colorIsDark]) {
            _disabledTopButtonColor = [self.topBackgroundColor blendWithColor:self.topButtonColor alpha:0.3f];
        } else {
            _disabledTopButtonColor = [self.topBackgroundColor blendWithColor:[UIColor blackColor] alpha:0.3f];
        }
    }
    if ([self.bottomBackgroundColor colorIsDark]) {
        _disabledBottomButtonColor = [self.bottomBackgroundColor blendWithColor:self.bottomButtonColor alpha:0.5f];
    } else {
        if ([self.bottomButtonColor colorIsDark]) {
            _disabledBottomButtonColor = [self.bottomBackgroundColor blendWithColor:self.bottomButtonColor alpha:0.3f];
        } else {
            _disabledBottomButtonColor = [self.bottomBackgroundColor blendWithColor:[UIColor blackColor] alpha:0.3f];
        }
    }
}

- (UIColor *)tintColor {
    return self.highlightColor;
}

- (void)applyBranding:(UIWindow *)window {
    if (self.brandingActive) {
        window.tintColor = self.topButtonColor;
        [[UINavigationBar appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : self.titleColor }];
        [[UINavigationBar appearance] setBarTintColor:self.topBackgroundColor];
        [[UIToolbar appearance] setBarTintColor:self.bottomBackgroundColor];
        [[UITabBar appearance] setBarTintColor:self.bottomBackgroundColor];
        [[UITabBarItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName :
                                                                 self.disabledBottomButtonColor } forState:UIControlStateNormal];
        [[UITabBarItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName :
                                                                 self.bottomButtonColor } forState:UIControlStateSelected];
        [[UITableViewCell appearance] setTintColor:self.highlightColor];
        [[UIView appearanceWhenContainedIn:UIAlertController.class, nil] setTintColor:[self highlightColor]];
        [self applyStatusBarColor];
    }
}

- (void)applyStatusBarColor {
    [self applyStatusBarColorAnimated:NO];
}

- (void)applyStatusBarColorAnimated:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    if (self.brandingActive && self.brandingStatusBarLight) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:animated];
    } else {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:animated];
    }
}

@end
