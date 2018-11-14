//
//  Configuration.h
//  TeacherPlanner
//
//  Created by Oliver on 03.08.14.
//
//

#define kBrandingTitleColorDefault              @"000000"
#define kBrandingTopBackgroundColorDefault      @"0095D8"
#define kBrandingBottomBackgroundColorDefault   @"0095D8"
#define kBrandingTopButtonColorDefault          @"FFFFFF"
#define kBrandingBottomButtonColorDefault       @"FFFFFF"
#define kBrandingHighlightColorDefault          @"FCAC17"

#define kConfigKeyPrefix                        @"TeacherPlanner"
#define kConfigKeyBrandingSecurity              @"TeacherPlannerSecurity"
#define kConfigKeyActiveApplication             @"TeacherPlannerActiveApplication"
#define kConfigKeySecurityPasscodeTimeout       @"TeacherPlannerSecurityPasscodeTimeout"
#define kConfigKeyBrandingPrefix                @"TeacherPlannerBranding"
#define kConfigKeySchoolPrefix                  @"TeacherPlannerSchool"

#define kConfigKeyBrandingActive                @"TeacherPlannerBrandingActive"
#define kConfigKeyBrandingTitleColor            @"TeacherPlannerBrandingTitleColor"
#define kConfigKeyBrandingHighlightColor        @"TeacherPlannerBrandingHighlightColor"
#define kConfigKeyBrandingTopBackgroundColor    @"TeacherPlannerBrandingTopBackgroundColor"
#define kConfigKeyBrandingTopButtonColor        @"TeacherPlannerBrandingTopButtonColor"
#define kConfigKeyBrandingBottomBackgroundColor @"TeacherPlannerBrandingBottomBackgroundColor"
#define kConfigKeyBrandingBottomButtonColor     @"TeacherPlannerBrandingBottomButtonColor"
#define kConfigKeyBrandingStatusBarLight        @"TeacherPlannerBrandingStatusBarLight"

@interface Configuration : NSObject

+ (Configuration *)instance;

@property(nonatomic, strong, readonly) NSArray *configurableKeys;
@property(nonatomic, strong, readonly) NSMutableDictionary *configuration;
@property(nonatomic, readonly) BOOL exitOnResignActive;

@property(nonatomic, readonly) BOOL brandingActive;
@property(nonatomic, readonly) BOOL brandingStatusBarLight;

// Settings colors
@property(nonatomic, readonly) UIColor *titleColor;
@property(nonatomic, readonly) UIColor *topBackgroundColor;
@property(nonatomic, readonly) UIColor *topButtonColor;
@property(nonatomic, readonly) UIColor *bottomBackgroundColor;
@property(nonatomic, readonly) UIColor *bottomButtonColor;
@property(nonatomic, readonly) UIColor *highlightColor;

// Derived colors
@property(nonatomic, readonly) UIColor *lightHighlightColor;
@property(nonatomic, readonly) UIColor *disabledTopButtonColor;
@property(nonatomic, readonly) UIColor *disabledBottomButtonColor;

- (void)check;

- (UIColor *)tintColor;

- (void)applyColors;
- (void)applyBranding:(UIWindow *)window;
- (void)applyStatusBarColor;
- (void)applyStatusBarColorAnimated:(BOOL)animated;

@end