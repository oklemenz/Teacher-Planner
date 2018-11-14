//
//  LockScreenViewController.h
//  TeacherPlanner
//
//  Created by Oliver on 04.01.14.
//
//

#import <UIKit/UIKit.h>

typedef enum LockScreenMode : NSUInteger {
    kLockScreenModeCreatePasscode,
    kLockScreenModeEnterPasscode,
} LockScreenMode;

@protocol LockScreenViewControllerDelegate
- (void)didUnlockWithPasscode:(NSString *)passcode;
- (void)didUnlockWithTouchID;
@end

@interface LockScreenViewController : UIViewController

@property (weak, nonatomic) id<LockScreenViewControllerDelegate> delegate;
@property (nonatomic) enum LockScreenMode mode;

@property (strong, nonatomic) UIView *blurredView;
@property (strong, nonatomic) IBOutlet UIView *coverView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;


@property (strong, nonatomic) IBOutlet UIView *startPage;
@property (strong, nonatomic) IBOutlet UIView *startContentView;

@property (strong, nonatomic) IBOutlet UILabel *greetingLabel;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;


@property (strong, nonatomic) IBOutlet UIView *unlockPage;
@property (strong, nonatomic) IBOutlet UIView *unlockContentView;
@property (weak, nonatomic) IBOutlet UIView *codeKeyPadView;

@property (strong, nonatomic) IBOutlet UILabel *headerLabel;
@property (strong, nonatomic) IBOutlet UITextField *passcodeField;
@property (strong, nonatomic) IBOutlet UIButton *okButton;
@property (strong, nonatomic) IBOutlet UIButton *infoButton;
@property (strong, nonatomic) IBOutlet UIButton *cancelDeleteButton;

@property (strong, nonatomic) IBOutlet UIView *keyPadView;

- (void)wrongPasscodeShake;
- (IBAction)okPressed:(id)sender;
- (IBAction)cancelPressed:(id)sender;
- (IBAction)infoPressed:(id)sender;

- (void)show;

@end
