//
//  DictionaryViewController.h
//  TeacherPlanner
//
//  Created by Oliver Klemenz on 16.08.15.
//
//

#import "AbstractContentDetailTableViewController.h"

@class JSONEntity;
@protocol AnnotationDataSource;

@protocol DictionaryViewControllerDelegate <NSObject>
- (void)didSelectWord:(NSString *)word;
@end

@interface DictionaryViewController : AbstractContentDetailTableViewController

@property (nonatomic, weak) JSONEntity<AnnotationDataSource> *dataSource;
@property (nonatomic, weak) id<DictionaryViewControllerDelegate> dictionaryDelegate;

@end