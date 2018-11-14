//
//  ImageAnnotationSettingsViewController.m
//  TeacherPlanner
//
//  Created by Klemenz, Oliver on 31.07.14.
//
//

#import "ImageAnnotationSettingsViewController.h"
#import "PencilStyleView.h"

@interface ImageAnnotationSettingsViewController()

@property (nonatomic, strong) UIBarButtonItem *doneButton;

@end

@implementation ImageAnnotationSettingsViewController

- (instancetype)initWithPencilStyle:(PencilStyle *)pencilStyle {
    self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"Image Settings", @"");
        
        self.doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
        self.navigationItem.rightBarButtonItem = self.doneButton;
        self.editing = YES;
        
        self.entity = [pencilStyle copy];
        
        self.definition = @[ @{ @"title" : NSLocalizedString(@"Pencil Style", @""),
                                @"definition" : @[
                                        @{ @"title" : NSLocalizedString(@"Preview", @""),
                                           @"control" : @"ColorPreview",
                                           @"edit" : @{
                                                   @"offsetY" : @(10),
                                                   @"height" : @(100)
                                                   },
                                           @"options" : @{
                                                   @"showTitle" : @(YES)
                                                   },
                                           @"bindings" : @[ @{ @"property" : @"color",
                                                               @"bindableProperty" : @"color" },
                                                            @{ @"property" : @"width",
                                                               @"bindableProperty" : @"width" },
                                                            @{ @"property" : @"alpha",
                                                               @"bindableProperty" : @"alphaValue" } ] },
                                        @{ @"title" : NSLocalizedString(@"Color", @""),
                                           @"control" : @"ColorPicker",
                                           @"edit" : @{
                                                   @"offsetX" : @(20),
                                                   @"offsetY" : @(10),
                                                   @"height" : @(200) },
                                           @"options" : @{
                                                   @"showTitle" : @(YES)
                                                   },
                                           @"bindings" : @[ @{ @"property" : @"color" } ] },
                                        @{ @"title" : NSLocalizedString(@"Width", @""),
                                           @"control" : @"Slider",
                                           @"bindings" : @[ @{ @"property" : @"width" } ],
                                           @"edit" : @{
                                                   @"height" : @(80),
                                                   @"offsetX" : @(15)
                                                   },
                                           @"options" : @{
                                                   @"showTitle" : @(YES),
                                                   @"minimumValue" : @(0.0),
                                                   @"maximumValue" : @(kPencilStyleMaxWidth),
                                                   @"continuous" : @(YES),
                                                   } },
                                        @{ @"title" : NSLocalizedString(@"Alpha", @""),
                                           @"control" : @"Slider",
                                           @"bindings" : @[ @{ @"property" : @"alpha" } ],
                                           @"edit" : @{
                                                   @"height" : @(80),
                                                   @"offsetX" : @(15)
                                                   },
                                           @"options" : @{
                                                   @"showTitle" : @(YES),
                                                   @"minimumValue" : @(0.0),
                                                   @"maximumValue" : @(1.0),
                                                   @"continuous" : @(YES),
                                                   } }
                                        ] } ];

    }
    return self;
}

- (PencilStyle *)pencilStyle {
    return (PencilStyle *)self.entity;
}

- (void)done {
    [self.delegate didChangeSettings:[self.pencilStyle copy] sender:self];
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

@end