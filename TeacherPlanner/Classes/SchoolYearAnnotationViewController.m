//
//  SchoolYearAnnotationExportViewController.m
//  TeacherPlanner
//
//  Created by Oliver on 04.05.14.
//
//

#import "SchoolYearAnnotationViewController.h"
#import "AnnotationViewController.h"
#import "Model.h"
#import "Application.h"
#import "SchoolYear.h"

@interface SchoolYearAnnotationViewController ()
@end

@implementation SchoolYearAnnotationViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.name = NSLocalizedString(@"Annotations", @"");
        self.subTitle = self.name;
        self.tabBarIcon = @"annotation";
        self.annotationViewController = [AnnotationViewController new];
    }
    return self;
}

- (void)viewDidLoad {
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.annotationViewController.dataSource = [[self schoolYear] annotation];
    self.annotationViewController.imageDataSource = [[Model instance] application];
    
    [self addChildViewController:self.annotationViewController];
    self.annotationViewController.view.frame = self.view.bounds;
    [self.view addSubview:self.annotationViewController.view];
    
    self.navigationItem.rightBarButtonItems = self.annotationViewController.navigationItem.rightBarButtonItems;
}

- (SchoolYear *)schoolYear {
    return (SchoolYear *)self.entity;
}

@end