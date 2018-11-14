//
//  AbstractMenuTableViewController.h
//  TeacherPlanner
//
//  Created by Oliver Klemenz on 29.01.15.
//
//

#import "AbstractMenuBaseTableViewController.h"
#import "Bindable.h"
#import "PropertyBinding.h"

@interface AbstractMenuTableViewController : AbstractMenuBaseTableViewController

@property(nonatomic) NSDictionary *definition;

@end