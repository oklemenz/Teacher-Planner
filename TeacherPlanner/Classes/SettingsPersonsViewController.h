//
//  SettingsPersonsViewController.h
//  TeacherPlanner
//
//  Created by Oliver Klemenz on 27.12.14.
//
//

#import "PersonListTableViewController.h"

@interface SettingsPersonsViewController : PersonListTableViewController <ModalViewController>

@property(nonatomic, strong) NSString *subTitle;

- (void)resetFilter;

@end