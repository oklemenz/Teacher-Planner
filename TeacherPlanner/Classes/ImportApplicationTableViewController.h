//
//  ImportApplicationTableViewController.h
//  TeacherPlanner
//
//  Created by Oliver Klemenz on 21.12.14.
//
//

#import <UIKit/UIKit.h>
#import "UIViewController+Extension.h"

@interface ImportApplicationTableViewController : UITableViewController <ModalViewController>

@property (nonatomic, strong) NSString *applicationUUID;

@end
