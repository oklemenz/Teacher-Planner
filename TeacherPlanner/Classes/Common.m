//
//  Common.m
//  TeacherPlanner
//
//  Created by Oliver Klemenz on 08.01.15.
//
//

#import "Common.h"
#import "Configuration.h"
#import "AppDelegate.h"

@implementation Common

+ (UIAlertController *)showDeletionConfirmation:(UIViewController *)presenter okHandler:(void (^)(void))okHandler cancelHandler:(void (^)(void))cancelHandler {
    return [Common showConfirmation:presenter title:NSLocalizedString(@"Confirm Deletion", @"")
                     message:NSLocalizedString(@"Data is irreversibly deleted. Do you want to continue?", @"")
               okButtonTitle:NSLocalizedString(@"Delete", @"")
                 destructive:YES
                   okHandler:okHandler cancelHandler:cancelHandler];
}

+ (UIAlertController *)showEditConfirmation:(UIViewController *)presenter okHandler:(void (^)(void))okHandler cancelHandler:(void (^)(void))cancelHandler {
    return [Common showConfirmation:presenter title:NSLocalizedString(@"Edit Completed School Year?", @"")
                            message:NSLocalizedString(@"Do you want to edit school year that is neither active nor in planning?", @"")
                      okButtonTitle:NSLocalizedString(@"Edit", @"")
                        destructive:NO
                          okHandler:okHandler cancelHandler:cancelHandler];
}

+ (UIAlertController *)showConfirmation:(UIViewController *)presenter title:(NSString *)title message:(NSString *)message  okButtonTitle:(NSString *)okButtonTitle destructive:(BOOL)destructive okHandler:(void (^)(void))okHandler cancelHandler:(void (^)(void))cancelHandler {
    return [Common showConfirmation:presenter title:title message:message okButtonTitle:okButtonTitle destructive:destructive cancelButtonTitle:nil okHandler:okHandler cancelHandler:cancelHandler];
}

+ (UIAlertController *)showConfirmation:(UIViewController *)presenter title:(NSString *)title message:(NSString *)message okButtonTitle:(NSString *)okButtonTitle destructive:(BOOL)destructive cancelButtonTitle:(NSString *)cancelButtonTitle okHandler:(void (^)(void))okHandler cancelHandler:(void (^)(void))cancelHandler {
    
    if (!okButtonTitle) {
        okButtonTitle = NSLocalizedString(@"OK", @"");
    }
    if (!cancelButtonTitle) {
        cancelButtonTitle = NSLocalizedString(@"Cancel", @"");
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:cancelButtonTitle
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * action) {
                                                if (cancelHandler) {
                                                    cancelHandler();
                                                }
                                            }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:okButtonTitle
                                              style:destructive ? UIAlertActionStyleDestructive : UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action) {
                                                if (okHandler) {
                                                    okHandler();
                                                }
                                            }]];
    [[AppDelegate instance] present:alert presenter:presenter animated:YES completion:nil];
    return alert;
}

+ (UIAlertController *)showMessage:(UIViewController *)presenter title:(NSString *)title message:(NSString *)message okHandler:(void (^)(void))okHandler {
    return [Common showMessage:presenter title:title message:message okButtonTitle:nil okHandler:okHandler];
}

+ (UIAlertController *)showMessage:(UIViewController *)presenter title:(NSString *)title message:(NSString *)message okButtonTitle:(NSString *)okButtonTitle okHandler:(void (^)(void))okHandler {
    
    if (!okButtonTitle) {
        okButtonTitle = NSLocalizedString(@"OK", @"");
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:okButtonTitle
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action) {
                                                if (okHandler) {
                                                    okHandler();
                                                }
                                            }]];
    [[AppDelegate instance] present:alert presenter:presenter animated:YES completion:nil];
    return alert;
}

+ (UIAlertController *)showEnterPasscode:(UIViewController *)presenter okHandler:(void (^)(NSString *passcode))okHandler cancelHandler:(void (^)(void))cancelHandler {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Enter Application Passcode", @"") message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    __weak UIAlertController *weakAlert = alert;
    void (^handleNotification)(NSNotification *note) = ^(NSNotification *note) {
        UITextField *password = weakAlert.textFields.firstObject;
        UIAlertAction *okAction = weakAlert.actions.firstObject;
        okAction.enabled = password.text.length > 0;
    };
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.keyboardType = UIKeyboardTypeNumberPad;
        textField.placeholder = NSLocalizedString(@"Passcode", @"");
        textField.secureTextEntry = YES;
        [[NSNotificationCenter defaultCenter] addObserverForName:UITextFieldTextDidChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:handleNotification];
    }];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"")
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * action) {
                                                   [[NSNotificationCenter defaultCenter]
                                                    removeObserver:self name:UITextFieldTextDidChangeNotification
                                                    object:nil];
                                                   UITextField *passcode = alert.textFields.firstObject;
                                                   if (okHandler) {
                                                       okHandler(passcode.text);
                                                   }
                                               }];
    ok.enabled = NO;
    [alert addAction:ok];
    
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"")
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * action) {
                                                [[NSNotificationCenter defaultCenter]
                                                 removeObserver:self name:UITextFieldTextDidChangeNotification
                                                 object:nil];
                                                if (cancelHandler) {
                                                    cancelHandler();
                                                }
                                            }]];
    [[AppDelegate instance] present:alert presenter:presenter animated:YES completion:nil];
    return alert;
}

+ (UIAlertController *)showNotificationConfirmation:(UIViewController *)presenter showHandler:(void (^)(void))showHandler openHandler:(void (^)(void))openHandler  cancelHandler:(void (^)(void))cancelHandler {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Annotation Reminder ", @"") message:NSLocalizedString(@"Do you want to show or navigate to the annotation?", @"") preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"")
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * action) {
                                                if (cancelHandler) {
                                                    cancelHandler();
                                                }
                                            }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Navigate to Annotation", @"")
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action) {
                                                if (openHandler) {
                                                    openHandler();
                                                }
                                            }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Show Annotation", @"")
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action) {
                                                if (showHandler) {
                                                    showHandler();
                                                }
                                            }]];
    [[AppDelegate instance] present:alert presenter:presenter animated:YES completion:nil];
    return alert;
}

+ (UIAlertController *)showText:(UIViewController *)presenter okHandler:(void (^)(NSString *text))okHandler cancelHandler:(void (^)(void))cancelHandler {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Enter Annotation Text", @"") message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    __weak UIAlertController *weakAlert = alert;
    void (^handleNotification)(NSNotification *note) = ^(NSNotification *note) {
        UITextField *text = weakAlert.textFields.firstObject;
        UIAlertAction *okAction = weakAlert.actions.firstObject;
        okAction.enabled = text.text.length > 0;
    };
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.keyboardType = UIKeyboardTypeAlphabet;
        textField.placeholder = NSLocalizedString(@"Text", @"");
        textField.secureTextEntry = YES;
        [[NSNotificationCenter defaultCenter] addObserverForName:UITextFieldTextDidChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:handleNotification];
    }];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"")
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * action) {
                                                   [[NSNotificationCenter defaultCenter]
                                                    removeObserver:self name:UITextFieldTextDidChangeNotification
                                                    object:nil];
                                                   UITextField *text = alert.textFields.firstObject;
                                                   if (okHandler) {
                                                       okHandler(text.text);
                                                   }
                                               }];
    ok.enabled = NO;
    [alert addAction:ok];
    
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"")
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * action) {
                                                [[NSNotificationCenter defaultCenter]
                                                 removeObserver:self name:UITextFieldTextDidChangeNotification
                                                 object:nil];
                                                if (cancelHandler) {
                                                    cancelHandler();
                                                }
                                            }]];
    [[AppDelegate instance] present:alert presenter:presenter animated:YES completion:nil];
    return alert;
}

+ (UIAlertController *)showAnnotationAlertSheet:(UIViewController *)presenter handler:(void (^)(NSInteger option))handler existing:(BOOL)existing {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Annotations", @"")
                                                                   message:NSLocalizedString(@"Select an option", @"")
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Add Annotation with reminder", @"")
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action) {
                                                handler(kActionSheetAnnotationAdd);
                                            }]];
    
    if (existing) {
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Show Annotation", @"")
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * action) {
                                                    handler(kActionSheetAnnotationShow);
                                                }]];
        
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Navigate to Annotation", @"")
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * action) {
                                                    handler(kActionSheetAnnotationNavigate);
                                                }]];
        
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Clear Reminder", @"")
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * action) {
                                                    handler(kActionSheetAnnotationRemove);
                                                }]];

        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Remove Annotation", @"")
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * action) {
                                                    handler(kActionSheetAnnotationRemove);
                                                }]];
    }
    
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"")
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * action) {
                                                handler(kActionSheetAnnotationCancel);
                                            }]];
    [[AppDelegate instance] present:alert presenter:presenter animated:YES completion:nil];
    return alert;
}

@end
