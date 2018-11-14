//
//  StudentTableViewController.h
//  TeacherPlanner
//
//  Created by Oliver on 01.05.14.
//
//

#import <UIKit/UIKit.h>
#import "AbstractMenuTableViewController.h"
#import "PersonTableViewController.h"

@class SchoolYear;
@class SchoolClass;

@interface StudentTableViewController : AbstractMenuTableViewController<PersonTableViewControllerDelegate>

@end
