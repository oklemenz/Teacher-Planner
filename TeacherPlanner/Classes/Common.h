//
//  Common.h
//  TeacherPlanner
//
//  Created by Oliver Klemenz on 08.01.15.
//
//

@interface Common : NSObject

#define kActionSheetAnnotationCancel 0
#define kActionSheetAnnotationAdd 1
#define kActionSheetAnnotationShow 2
#define kActionSheetAnnotationNavigate 3
#define kActionSheetAnnotationClear 4
#define kActionSheetAnnotationRemove 5

+ (UIAlertController *)showDeletionConfirmation:(UIViewController *)presenter okHandler:(void (^)(void))okHandler cancelHandler:(void (^)(void))cancelHandler;

+ (UIAlertController *)showEditConfirmation:(UIViewController *)presenter okHandler:(void (^)(void))okHandler cancelHandler:(void (^)(void))cancelHandler;

+ (UIAlertController *)showConfirmation:(UIViewController *)presenter title:(NSString *)title message:(NSString *)message okButtonTitle:(NSString *)okButtonTitle destructive:(BOOL)destructive okHandler:(void (^)(void))okHandler cancelHandler:(void (^)(void))cancelHandler;

+ (UIAlertController *)showConfirmation:(UIViewController *)presenter title:(NSString *)title message:(NSString *)message okButtonTitle:(NSString *)okButtonTitle destructive:(BOOL)destructive cancelButtonTitle:(NSString *)cancelButtonTitle okHandler:(void (^)(void))okHandler cancelHandler:(void (^)(void))cancelHandler;

+ (UIAlertController *)showMessage:(UIViewController *)presenter title:(NSString *)title message:(NSString *)message okHandler:(void (^)(void))okHandler;

+ (UIAlertController *)showMessage:(UIViewController *)presenter title:(NSString *)title message:(NSString *)message okButtonTitle:(NSString *)okButtonTitle okHandler:(void (^)(void))okHandler;

+ (UIAlertController *)showEnterPasscode:(UIViewController *)presenter okHandler:(void (^)(NSString *passcode))okHandler cancelHandler:(void (^)(void))cancelHandler;

+ (UIAlertController *)showNotificationConfirmation:(UIViewController *)presenter showHandler:(void (^)(void))showHandler openHandler:(void (^)(void))openHandler  cancelHandler:(void (^)(void))cancelHandler;

+ (UIAlertController *)showText:(UIViewController *)presenter okHandler:(void (^)(NSString *text))okHandler cancelHandler:(void (^)(void))cancelHandler;

+ (UIAlertController *)showAnnotationAlertSheet:(UIViewController *)presenter handler:(void (^)(NSInteger option))handler existing:(BOOL)existing;

@end
