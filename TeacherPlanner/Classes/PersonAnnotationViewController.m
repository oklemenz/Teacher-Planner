//
//  PersonAnnotationViewController.m
//  TeacherPlanner
//
//  Created by Oliver on 17.05.14.
//
//

#import "PersonAnnotationViewController.h"
#import "AnnotationViewController.h"
#import "Model.h"
#import "Application.h"

@interface PersonAnnotationViewController ()
@end

@implementation PersonAnnotationViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.name = NSLocalizedString(@"Annotations", @"");
        self.tabBarIcon = @"annotation";
        self.annotationViewController = [AnnotationViewController new];
    }
    return self;
}

- (NSString *)title {
    return self.entity.name;
}

- (NSString *)subTitle {
    return [NSString stringWithFormat:@"%@ - %@", NSLocalizedString(@"Persons", @""), NSLocalizedString(@"Annotations", @"")];
}

- (void)viewDidLoad {
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.annotationViewController.dataSource = [[self person] annotation];
    self.annotationViewController.imageDataSource = [[Model instance] application];
    
    [self addChildViewController:self.annotationViewController];
    self.annotationViewController.view.frame = self.view.bounds;
    [self.view addSubview:self.annotationViewController.view];
    
    self.navigationItem.rightBarButtonItems = self.annotationViewController.navigationItem.rightBarButtonItems;
}

- (Person *)person {
    return (Person *)self.entity;
}

@end