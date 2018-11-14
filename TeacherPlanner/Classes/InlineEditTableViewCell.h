//
//  InlineEditTableViewCell.h
//  TeacherPlanner
//
//  Created by Oliver on 13.04.14.
//
//

#import <UIKit/UIKit.h>
#import "AbstractTableViewCell.h"

@class InlineEditTableViewCell;
@class JSONEntity;
@class PropertyBinding;

@interface InlineEditTableViewCell : AbstractTableViewCell<UITextFieldDelegate, UIScrollViewDelegate>

@property (nonatomic, retain) UITextField *textField;
@property (nonatomic, retain) UILabel *initialsTextLabel;

@property (nonatomic, strong) NSString *imageValue;
@property (nonatomic, strong) UIColor *color;

// Options
@property (nonatomic) BOOL showInitialsIcon;
@property (nonatomic) BOOL showPhotoIcon;
@property (nonatomic) BOOL secureTextEntry;
@property (nonatomic) NSNumber *secureTextEntryNumber;
@property (nonatomic, strong) NSNumber *keyboard;
@property (nonatomic, strong) NSNumber *autocapitalization;

@end
