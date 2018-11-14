//
//  TextAnnotationViewController.m
//  TeacherPlanner
//
//  Created by Klemenz, Oliver on 30.07.14.
//
//

#import "TextAnnotationViewController.h"
#import "DictionaryViewController.h"
#import "UIBarButtonItem+Extension.h"
#import "AnnotationHandler.h"
#import "Word.h"
#import "Configuration.h"

@interface TextAnnotationViewController ()
@property (nonatomic) BOOL updateMode;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIBarButtonItem *doneButton;
@property (nonatomic, strong) UIBarButtonItem *dictionaryButton;
@end

@implementation TextAnnotationViewController

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (instancetype)initWithText:(NSString *)text {
    self = [super init];
    if (self) {
        // TODO: Check this
        [self view];
        [self setText:text];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = NSLocalizedString(@"Write Text", @"");
    
    self.doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
    self.doneButton.enabled = NO;

    self.dictionaryButton = [UIBarButtonItem createCustomTintedTopBarButtonItem:@"dictionary"];
    [(UIButton *)self.dictionaryButton.customView addTarget:self action:@selector(openDictionary:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItems = @[self.doneButton, self.dictionaryButton];
    
    self.textView = [[UITextView alloc] initWithFrame:self.view.bounds];
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.textView.backgroundColor = [UIColor whiteColor];
    self.textView.tintColor = [Configuration instance].highlightColor;
    self.textView.font = [UIFont systemFontOfSize:18.0f];
    self.textView.delegate = self;
    self.textView.text = @"_";
    self.textView.text = @"";
    [self.view addSubview:self.textView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [self view];
    [super setEditing:editing animated:animated];
    self.textView.editable = editing;
    if (editing) {
        self.navigationItem.rightBarButtonItem = self.doneButton;
        [self.textView becomeFirstResponder];
    } else {
        self.updateMode = YES;
        self.navigationItem.rightBarButtonItem = self.editButtonItem;
    }
}

- (NSString *)text {
    return self.textView.text;
}

- (void)setText:(NSString *)text {
    self.updateMode = YES;
    self.textView.text = text;
    [self textViewDidChange:self.textView];
}

- (void)keyboardWasShown:(NSNotification *)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)) {
        self.textView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - keyboardSize.width);
    } else {
        self.textView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - keyboardSize.height);
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
}

- (void)done:(id)sender {
    [self.delegate didFinishWritingText:self.textView.text updated:self.updateMode];
}

- (void)textViewDidChange:(UITextView *)textView {
    self.doneButton.enabled = textView.text.length > 0;
    if ([textView.text hasSuffix:@"\n"]) {
        [textView scrollRectToVisible:CGRectMake(0, textView.contentSize.height-1, 1, 1) animated:YES];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField*)textField {
    [textField resignFirstResponder];
    return NO;
}

- (void)openDictionary:(id)sender {
    DictionaryViewController *dictionary = [DictionaryViewController new];
    dictionary.dataSource = self.dataSource;
    if (self.editing) {
        dictionary.dictionaryDelegate = self;
    }
    
    Word *word;
    if (self.textView.selectedTextRange) {
        NSString *selectedText = [self.textView textInRange:self.textView.selectedTextRange];
        if (selectedText.length > 0) {
            JSONEntity *dictionaryEntity = [dictionary.dataSource dictionaryEntity];
            if (![[dictionaryEntity callAggregation:[dictionary.dataSource dictionaryAggregation] object:selectedText action:@"contains"] boolValue]) {
                word = [Word new];
                word.name = selectedText;
                [dictionaryEntity insertAggregation:[dictionary.dataSource dictionaryAggregation] object:word];
            }
        }
    }
    [self.navigationController pushViewController:dictionary animated:YES];
    if (word) {
        dictionary.editing = YES;
    }
}

- (void)didSelectWord:(NSString *)word {
    if (!self.editing) {
        return;
    }
    if (word.length > 0) {
        UITextPosition *beginning = self.textView.beginningOfDocument;
        UITextPosition *selectionStart = self.textView.selectedTextRange.start;
        UITextPosition *selectionEnd = self.textView.selectedTextRange.end;
        NSInteger location = [self.textView offsetFromPosition:beginning toPosition:selectionStart];
        NSInteger length = [self.textView offsetFromPosition:selectionStart toPosition:selectionEnd];
        NSRange selectedRange = NSMakeRange(location, length);
        NSInteger startLocation = selectedRange.location - 1;
        if (startLocation < 0) {
            startLocation = 0;
        }
        NSRange startRange = NSMakeRange(startLocation, 1);
        NSInteger endLocation = selectedRange.location + selectedRange.length;
        if (endLocation >= self.textView.text.length) {
            endLocation = self.textView.text.length-1;
        }
        if (endLocation < 0) {
            endLocation = 0;
        }
        if (endLocation >= startLocation && startLocation > 0) {
            NSRange endRange = NSMakeRange(endLocation, 1);
            NSString *lastChar = [self.textView.text substringWithRange:startRange];
            NSString *nextChar = [self.textView.text substringWithRange:endRange];
            if (![lastChar isEqualToString:@" "] && startLocation > 0) {
                word = [NSString stringWithFormat:@" %@", word];
            }
            if (![nextChar isEqualToString:@" "] && endLocation < self.textView.text.length-1) {
                word = [NSString stringWithFormat:@"%@ ", word];
            }
        }
        UITextRange *textRange = self.textView.selectedTextRange;
        if (!textRange.isEmpty) {
            [self.textView replaceRange:textRange withText:word];
        } else {
            [self.textView insertText:word];
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end