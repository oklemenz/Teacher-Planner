//
//  SchoolClassAnnotationViewController.m
//  TeacherPlanner
//
//  Created by Oliver on 17.05.14.
//
//

#import "SchoolClassAnnotationViewController.h"
#import "AnnotationViewController.h"
#import "Model.h"
#import "Application.h"
#import "AppDelegate.h"

@interface SchoolClassAnnotationViewController ()
@end

@implementation SchoolClassAnnotationViewController

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
    return [NSString stringWithFormat:@"%@ - %@", self.name, self.schoolClass.parent.name];
}

- (SchoolClass *)schoolClass {
    return (SchoolClass *)self.entity;
}

- (void)viewDidLoad {
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.annotationViewController.dataSource = [[self schoolClass] annotation];
    self.annotationViewController.imageDataSource = [[Model instance] application];

    [self addChildViewController:self.annotationViewController];
    self.annotationViewController.view.frame = self.view.bounds;
    [self.view addSubview:self.annotationViewController.view];
    
    self.navigationItem.rightBarButtonItems = self.annotationViewController.navigationItem.rightBarButtonItems;
}

@end