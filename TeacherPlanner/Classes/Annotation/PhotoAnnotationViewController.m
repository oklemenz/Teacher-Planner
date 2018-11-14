//
//  PhotoAnnotationViewController.m
//  TeacherPlanner
//
//  Created by Klemenz, Oliver on 29.07.14.
//
//

#import "PhotoAnnotationViewController.h"

@interface PhotoAnnotationViewController ()
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIScrollView *scrollView;
@end

@implementation PhotoAnnotationViewController

- (instancetype)initWithImage:(UIImage *)image {
    self = [super init];
    if (self) {
        self.image = image;
        self.navigationItem.rightBarButtonItem = self.editButtonItem;
    }
    return self;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    if (editing) {
        ImageAnnotationViewController *imageAnnotation = [ImageAnnotationViewController new];
        imageAnnotation.delegate = self;
        imageAnnotation.dataSource = self.dataSource;
        [imageAnnotation image:self.image];
        [self.navigationController pushViewController:imageAnnotation animated:YES];
    }
    [super setEditing:false animated:animated];
}

- (void)didFinishDrawingImage:(UIImage *)image updated:(BOOL)updated {
    self.image = image;
    [self setupImage];
    [self.delegate didFinishEditImage:image];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.imageView = [[UIImageView alloc] initWithImage:self.image];

    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.scrollView.delegate = self;
    
    [self setupImage];
    
    [self.scrollView addSubview:self.imageView];
    [self.view addSubview:self.scrollView];
}

- (void)setupImage {
    self.imageView.image = self.image;
    
    self.scrollView.minimumZoomScale =
    MIN(self.scrollView.bounds.size.width / self.imageView.image.size.width / self.imageView.image.scale,
        self.scrollView.bounds.size.height / self.imageView.image.size.height / self.imageView.image.scale);
    if (self.scrollView.minimumZoomScale > 1.0) {
        self.scrollView.minimumZoomScale = 1.0;
    }
    self.scrollView.maximumZoomScale = 10.0;
    self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

@end