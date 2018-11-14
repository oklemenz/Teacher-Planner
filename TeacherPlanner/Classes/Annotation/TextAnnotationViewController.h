//
//  TextAnnotationViewController.h
//  TeacherPlanner
//
//  Created by Klemenz, Oliver on 30.07.14.
//
//

#import <UIKit/UIKit.h>
#import "DictionaryViewController.h"

@class JSONEntity;
@protocol AnnotationDataSource;

@protocol TextAnnotationViewControllerDelegate <NSObject>
- (void)didFinishWritingText:(NSString *)text updated:(BOOL)updated;
@end

@interface TextAnnotationViewController : UIViewController <UITextViewDelegate, DictionaryViewControllerDelegate>

@property (nonatomic, weak) JSONEntity<AnnotationDataSource> *dataSource;
@property (nonatomic, weak) id<TextAnnotationViewControllerDelegate> delegate;

- (instancetype)init;
- (instancetype)initWithText:(NSString *)text;

- (NSString *)text;
- (void)setText:(NSString *)text;

@end