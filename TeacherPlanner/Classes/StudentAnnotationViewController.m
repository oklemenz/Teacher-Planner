//
//  PersonAnnotationViewController.m
//  TeacherPlanner
//
//  Created by Oliver on 17.05.14.
//
//

#import "StudentAnnotationViewController.h"
#import "AnnotationViewController.h"
#import "Model.h"
#import "Application.h"

@interface StudentAnnotationViewController ()
@end

@implementation StudentAnnotationViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.name = NSLocalizedString(@"Annotations", @"");
        self.tabBarIcon = @"annotation";
        self.annotationViewController = [AnnotationViewController new];
    }
    return self;
}

- (NSString *)subTitle {
    return [NSString stringWithFormat:@"%@ - %@ - %@", self.name, self.student.parent.name, self.student.parent.parent.name];
}

- (void)viewDidLoad {
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.annotationViewController.dataSource = [[self student] annotation];
    self.annotationViewController.imageDataSource = [[Model instance] application];
    
    [self addChildViewController:self.annotationViewController];
    self.annotationViewController.view.frame = self.view.bounds;
    [self.view addSubview:self.annotationViewController.view];
    
    self.navigationItem.rightBarButtonItems = self.annotationViewController.navigationItem.rightBarButtonItems;
}

- (Student *)student {
    return (Student *)self.entity;
}

@end