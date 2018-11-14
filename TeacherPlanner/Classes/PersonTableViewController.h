//
//  PersonTableViewController.h
//  TeacherPlanner
//
//  Created by Oliver on 01.05.14.
//
//

#import <UIKit/UIKit.h>
#import "AbstractMenuTableViewController.h"

@class Person;

@protocol PersonTableViewControllerDelegate <NSObject>
- (void)didSelectPerson:(Person *)person;
@end

@interface PersonTableViewController : AbstractMenuTableViewController

@property(nonatomic, assign) id<PersonTableViewControllerDelegate> delegate;

@end
