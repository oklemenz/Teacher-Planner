//
//  VideoAnnotationViewController.m
//  TeacherPlanner
//
//  Created by Klemenz, Oliver on 30.07.14.
//
//

#import "VideoAnnotationViewController.h"
#import "Utilities.h"

@interface VideoAnnotationViewController ()
@end

@implementation VideoAnnotationViewController

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.player pause];
    [Utilities clearGeneratedFolder];
}

- (void)dealloc {
    [Utilities clearGeneratedFolder];
}

@end