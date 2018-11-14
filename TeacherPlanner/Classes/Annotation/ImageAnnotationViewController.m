//
//  ImageAnnotationViewController.m
//  TeacherPlanner
//
//  Created by Klemenz, Oliver on 31.07.14.
//
//

#import "ImageAnnotationViewController.h"
#import "ImageAnnotationSettingsViewController.h"
#import "PencilStyle.h"
#import "PencilStyleView.h"
#import "UIImage+ImageEffects.h"
#import "AppDelegate.h"
#import "Common.h"
#import "AbstractNavigationController.h"

@interface ImageAnnotationViewController ()

@property (nonatomic) BOOL updateMode;

@property (nonatomic, strong) UIButton *settingsButton;
@property (nonatomic, strong) UIBarButtonItem *settingsButtonItem;

@property (nonatomic, strong) UIBarButtonItem *cancelButton;
@property (nonatomic, strong) UIBarButtonItem *doneButton;
@property (nonatomic, strong) UIBarButtonItem *undoButton;
@property (nonatomic, strong) UIBarButtonItem *clearButton;
@property (nonatomic, strong) UIBarButtonItem *penErasorButton;
@property (nonatomic, strong) UIBarButtonItem *drawModeButtonItem;
@property (nonatomic, strong) UISegmentedControl *drawModeButton;

@property (nonatomic, strong) UIImage *editImage;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *drawImageView;
@property (nonatomic, strong) NSMutableArray *undoImages;
@property (nonatomic, strong) UIView *historyView;

@property (nonatomic, strong) PencilStyle *pencilStyle;

@property (nonatomic, strong) PencilStyle *drawPencilStyle;
@property (nonatomic, strong) PencilStyle *erasePencilStyle;

@property (nonatomic) CGPoint location;

@property (nonatomic) BOOL undoCrop;

@end

@implementation ImageAnnotationViewController

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)image {
    self = [super init];
    if (self) {
        [self view];
        [self image:image];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    self.drawPencilStyle = [[PencilStyle alloc] initWithColor:kImageAnnotationDefaultColor width:3.0 alpha:1.0];
    if ([self.dataSource pencilStyles].count > 0) {
        self.drawPencilStyle = [[self.dataSource pencilStyles] objectAtIndex:0];
    }
    self.pencilStyle = self.drawPencilStyle;
    
    self.settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.settingsButton.bounds = CGRectMake(0, 0, kPencilStyleMaxWidth, kPencilStyleMaxWidth);
    self.settingsButton.layer.cornerRadius = 5.0f;
    self.settingsButton.layer.masksToBounds = YES;
    self.settingsButton.layer.borderWidth = 1.0f;
    self.settingsButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.settingsButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.settingsButton];
    
    [self updateSettingsButton];

    self.cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    self.doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    self.undoButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemUndo target:self action:@selector(undo)];
    self.clearButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Clear", @"") style:UIBarButtonItemStylePlain target:self action:@selector(clear)];
    self.undoButton.enabled = NO;
    
    NSArray *segItemsArray = @[[UIImage imageNamed:@"pencil"], [UIImage imageNamed:@"eraser"]];
    self.drawModeButton = [[UISegmentedControl alloc] initWithItems:segItemsArray];
    self.drawModeButton.frame = CGRectMake(0, 0, 70, 30);
    self.drawModeButton.selectedSegmentIndex = 0;
    self.drawModeButtonItem = [[UIBarButtonItem alloc] initWithCustomView:(UIView *)self.drawModeButton];
    [self.drawModeButton addTarget:self action:@selector(switchDrawMode:) forControlEvents:UIControlEventValueChanged];
    
    self.navigationItem.rightBarButtonItems = @[self.doneButton, self.settingsButtonItem, self.drawModeButtonItem, self.undoButton, self.clearButton];
    
    self.imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    self.imageView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.imageView];
    self.drawImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    self.drawImageView.image = nil;
    [self.view addSubview:self.drawImageView];
    
    self.undoImages = [@[] mutableCopy];
}

- (void)switchDrawMode:(UISegmentedControl *)segmentedControl {
    if (segmentedControl.selectedSegmentIndex == 0) {
        self.pencilStyle = self.drawPencilStyle;
    } else {
        self.pencilStyle = [[PencilStyle alloc] initWithColor:[UIColor whiteColor] width:self.drawPencilStyle.width alpha:self.drawPencilStyle.alpha];
    }
    [self.dataSource addPencilStyle:self.drawPencilStyle];
}

- (void)updateSettingsButton {
    PencilStyleView *pencilStyleView = [[PencilStyleView alloc] initWithPencilStyle:self.drawPencilStyle];
    [self.settingsButton setImage:[pencilStyleView icon] forState:UIControlStateNormal];
    [self.settingsButton addTarget:self action:@selector(settings) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillAppear:(BOOL)animated {
    [[AppDelegate instance] enableMenuSwipe:NO];
    if (self.editImage) {
        UIGraphicsBeginImageContextWithOptions(self.imageView.frame.size, NO, 0);
        [self.editImage drawInRect:[self centerRect:self.imageView.frame size:self.editImage.size]];
        self.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [[AppDelegate instance] enableMenuSwipe:YES];
}

- (void)image:(UIImage *)image {
    [self view];
    self.updateMode = YES;
    self.editImage = image;
}

- (CGRect)centerRect:(CGRect)rect size:(CGSize)size {
    CGFloat topOffset = self.navigationController.navigationBar.frame.size.height +
                        [UIApplication sharedApplication].statusBarFrame.size.height;
    CGFloat bottomOffset = self.tabBarController.tabBar.frame.size.height;
    CGSize rectSize = CGSizeMake(rect.size.width, rect.size.height - topOffset - bottomOffset);
    CGFloat ratio = fmin(rectSize.width / size.width, rectSize.height / size.height);
    CGRect newRect = CGRectMake(rect.origin.x, rect.origin.y, size.width * ratio, size.height * ratio);
    CGFloat offsetX = (rectSize.width - newRect.size.width) / 2.0;
    CGFloat offsetY = (rectSize.height - newRect.size.height) / 2.0;
    return CGRectMake(rect.origin.x + offsetX,
                      rect.origin.y + offsetY + topOffset,
                      newRect.size.width, newRect.size.height);
}

- (void)settings {
    [self togglePencilStyleHistory];
}

- (void)togglePencilStyleHistory {
    [self showPencilStyleHistory:!self.historyView animated:YES];
}

- (void)showPencilStyleHistory:(BOOL)show animated:(BOOL)animated {
    if (!self.historyView && show) {
        self.historyView = [[UIView alloc] initWithFrame:self.view.bounds];
        self.historyView.backgroundColor = [UIColor clearColor];
        self.historyView.userInteractionEnabled = YES;
        UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, 0);
        [self.view drawViewHierarchyInRect:self.view.bounds afterScreenUpdates:YES];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        image = [image applyBlurWithRadius:5.0f];
        UIGraphicsEndImageContext();
        
        UIImageView *blurImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        blurImageView.image = image;
        
        [self.historyView addSubview:blurImageView];
        
        UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, 0.0);
        UIImage *blank = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        UIImageView *rasterView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        rasterView.image = blank;
        rasterView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"raster"]];
        rasterView.alpha = 0.5;
        [self.historyView addSubview:rasterView];
        
        CGPoint offset = CGPointMake(0, self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height);
        
        UIButton *newPencilStyle = [[UIButton alloc] initWithFrame:CGRectMake(offset.x, offset.y, kPencilStyleGrid, kPencilStyleGrid)];
        newPencilStyle.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        newPencilStyle.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        newPencilStyle.titleLabel.font = [UIFont boldSystemFontOfSize:12.0f];
        [newPencilStyle setTitleColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
        [newPencilStyle addTarget:self action:@selector(didTapNewPencilStyle:) forControlEvents: UIControlEventTouchUpInside];
        [newPencilStyle setTitle:NSLocalizedString(@"New", @"") forState:UIControlStateNormal];
        [self.historyView addSubview:newPencilStyle];

        CGFloat width = self.view.bounds.size.width;
        CGFloat height = self.view.bounds.size.height;
        NSInteger columnCount = floor(width / kPencilStyleGrid);
        NSInteger rowCount = floor(height / kPencilStyleGrid);
        

        UIGraphicsBeginImageContext(rasterView.frame.size);
        [rasterView.image drawInRect:rasterView.frame];

        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetAllowsAntialiasing(context, NO);
        
        CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:0.5 alpha:1.0].CGColor);
        CGContextSetLineWidth(context, 1.0);
        CGFloat dashLengths[] = { 10, 5 };
        CGContextSetLineDash(context, 0, dashLengths, 2);
        
        for (int i = 0; i < columnCount; i++) {
            CGContextMoveToPoint(context, (i+1) * kPencilStyleGrid, 0);
            CGContextAddLineToPoint(context, (i+1) * kPencilStyleGrid, height);
            CGContextStrokePath(context);
        }
        for (int j = 0; j < rowCount; j++) {
            CGContextMoveToPoint(context, 0, offset.y + (j+1) * kPencilStyleGrid);
            CGContextAddLineToPoint(context, width, offset.y + (j+1) * kPencilStyleGrid);
            CGContextStrokePath(context);
        }
        
        rasterView.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        NSInteger row = 0;
        NSInteger column = 1;
        for (PencilStyle *pencilStyle in [self.dataSource pencilStyles]) {
            PencilStyleView *pencilStyleView = [[PencilStyleView alloc] initWithPencilStyle:pencilStyle];
            pencilStyleView.delegate = self;
            [pencilStyleView position:row column:column offset:offset];
            [self.historyView addSubview:pencilStyleView];
            column++;
            if (column >= columnCount) {
                row++;
                column = 0;
            }
        }

        if (animated) {
            self.historyView.alpha = 0.0;
            [UIView animateWithDuration:0.5 animations:^{
                self.historyView.alpha = 1.0;
            }];
        } else {
            self.historyView.alpha = 1.0;
        }
        
        [self.view addSubview:self.historyView];
        [self enabledButtons:NO];
        
    } else if (self.historyView && !show) {
        if (animated) {
            [UIView animateWithDuration:0.5 animations:^{
                [self enabledButtons:YES];
                self.historyView.alpha = 0.0;
            } completion:^(BOOL finished) {
                [self.historyView removeFromSuperview];
                self.historyView = nil;
            }];
        } else {
            self.historyView.alpha = 0.0;
            [self.historyView removeFromSuperview];
            self.historyView = nil;
            [self enabledButtons:YES];
        }
    }
}

- (void)selectPencilStyle:(PencilStyle *)pencilStyle animated:(BOOL)animated {
    self.drawPencilStyle = pencilStyle;
    [self.dataSource addPencilStyle:pencilStyle];
    [self switchDrawMode:self.drawModeButton];
    [self updateSettingsButton];
    [self showPencilStyleHistory:NO animated:animated];
}

- (void)didSelectPencilStyle:(PencilStyleView *)pencilStyleView {
    [self selectPencilStyle:pencilStyleView.pencilStyle animated:YES];
}

- (void)didMarkPencilStyle:(PencilStyleView *)pencilStyleView {
    [self editPencilStyle:pencilStyleView.pencilStyle];
}

- (void)didTapNewPencilStyle:(UITapGestureRecognizer *)gestureRecognizer {
    [self editPencilStyle:self.drawPencilStyle];
}

- (void)editPencilStyle:(PencilStyle *)pencilStyle {
    ImageAnnotationSettingsViewController *settings = [[ImageAnnotationSettingsViewController alloc] initWithPencilStyle:pencilStyle];
    settings.delegate = self;
    [self.navigationController pushViewController:settings animated:YES];
}

- (void)enabledButtons:(BOOL)enabled {
    if (enabled) {
        self.navigationItem.leftBarButtonItem = self.navigationItem.backBarButtonItem;
    } else if (!enabled) {
        self.navigationItem.leftBarButtonItem = self.cancelButton;
    }
    self.doneButton.enabled = enabled;
    self.undoButton.enabled = enabled;
    self.clearButton.enabled = enabled;
    self.drawModeButton.enabled =  enabled;
    self.drawModeButtonItem.enabled = enabled;
    self.drawModeButton.userInteractionEnabled = enabled;
    if (enabled) {
        [self enabledUndoButton];
    }
}

- (void)didChangeSettings:(PencilStyle *)pencilStyle sender:(id)sender {
    [self selectPencilStyle:pencilStyle animated:NO];
}

- (void)undo {
    if (self.undoImages.count > 0) {
        UIImage *undoImage = [self.undoImages lastObject];
        if (undoImage) {
            self.imageView.image = undoImage;
        }
        [self.undoImages removeLastObject];
    } else if (!self.undoCrop) {
        self.imageView.image = nil;
    }
    [self enabledUndoButton];
}

- (void)enabledUndoButton {
    self.undoButton.enabled = self.undoImages.count > 0 || (self.imageView.image && !self.undoCrop);
}

- (void)cancel {
    [self showPencilStyleHistory:NO animated:true];
}

- (void)done {
    CGFloat topOffset = self.navigationController.navigationBar.frame.size.height +
                        [UIApplication sharedApplication].statusBarFrame.size.height;
    CGFloat bottomOffset = self.tabBarController.tabBar.frame.size.height;

    CGRect rect = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y - topOffset,
                             self.view.bounds.size.width, self.view.bounds.size.height);
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(rect.size.width, rect.size.height - topOffset - bottomOffset), NO, 0);
    [self.view drawViewHierarchyInRect:rect afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    [self.delegate didFinishDrawingImage:image updated:self.updateMode];
}

- (void)clear {
    [Common showConfirmation:self
                       title:NSLocalizedString(@"Clear drawing", @"")
                     message:NSLocalizedString(@"Do you want to clear all?", @"")
               okButtonTitle:nil destructive:NO okHandler:^{
                   [self addUndo];
                   self.imageView.image = nil;
               } cancelHandler:nil];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.historyView) {
        return;
    }
    UITouch *touch = [touches anyObject];
    self.location = [touch locationInView:self.imageView];
    [self touchesMoved:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.historyView) {
        return;
    }
    UITouch *touch = [touches anyObject];
    CGPoint currentLocation = [touch locationInView:self.view];
    UIGraphicsBeginImageContext(self.view.frame.size);
    [self.drawImageView.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextMoveToPoint(context, self.location.x, self.location.y);
    CGContextAddLineToPoint(context, currentLocation.x, currentLocation.y);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineWidth(context, self.pencilStyle.width);
    CGContextSetStrokeColorWithColor(context, [self.pencilStyle.color CGColor]);
    CGContextSetBlendMode(context,kCGBlendModeNormal);
    CGContextStrokePath(context);

    self.drawImageView.image = UIGraphicsGetImageFromCurrentImageContext();
    [self.drawImageView setAlpha:self.pencilStyle.alpha];
    UIGraphicsEndImageContext();
    
    self.location = currentLocation;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.historyView) {
        return;
    }
    [self addUndo];
    UIGraphicsBeginImageContext(self.imageView.frame.size);
    [self.imageView.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) blendMode:kCGBlendModeNormal alpha:1.0];
    [self.drawImageView.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) blendMode:kCGBlendModeNormal alpha:self.pencilStyle.alpha];
    self.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    self.drawImageView.image = nil;
    UIGraphicsEndImageContext();
}

- (void)addUndo {
    if (self.imageView.image) {
        [self.undoImages addObject:self.imageView.image];
    }
    self.undoButton.enabled = YES;
    if (self.undoImages.count > kImageAnnotationMaxUndo) {
        [self.undoImages removeObjectAtIndex:0];
        self.undoCrop = YES;
    }
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