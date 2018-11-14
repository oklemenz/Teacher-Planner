//
//  InlinePhotoPickerTableViewCell.m
//  TeacherPlanner
//
//  Created by Oliver on 14.06.14.
//
//

#import "InlinePhotoPickerTableViewCell.h"
#import <QuartzCore/QuartzCore.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "UIImage+Extension.h"
#import "Model.h"
#import "Application.h"
#import "Photo.h"
#import "PhotoAnnotationViewController.h"
#import "UIImage+Extension.h"
#import "Configuration.h"
#import "AppDelegate.h"

#define kPhotoPlaceholderSize 100
#define kPhotoResolution 200

@interface InlinePhotoPickerTableViewCell ()
@property(nonatomic, strong) UIImageView *photoView;
@property(nonatomic, strong) UIButton *photoButton;
@property(nonatomic, strong) UILabel *photoLabel;
@end

@implementation InlinePhotoPickerTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.alpha = 0.0;
    }
    return self;
}

- (UIImageView *)photoView {
    if (!_photoView) {
        _photoView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _photoView.image = nil;
        _photoView.layer.cornerRadius = kPhotoPlaceholderSize / 2.0;
        _photoView.clipsToBounds = YES;
        _photoView.autoresizingMask = UIViewAutoresizingNone;
    }
    return _photoView;
}

- (UIButton *)photoButton {
    if (!_photoButton) {
        self.photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.photoButton addSubview:self.photoView];
        [self.photoButton addTarget:self action:@selector(didTapPhoto) forControlEvents:UIControlEventTouchUpInside];
        self.photoButton.showsTouchWhenHighlighted = YES;
        self.photoButton.enabled = YES;
        [self.contentView addSubview:self.photoButton];
    }
    return _photoButton;
}

- (UILabel *)photoLabel {
    if (!_photoLabel) {
        _photoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _photoLabel.textColor = [UIColor whiteColor];
        _photoLabel.numberOfLines = 3;
        _photoLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_photoLabel];
    }
    return _photoLabel;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    self.photoButton.enabled = self.value != nil || self.isEditing;
    if (editing) {
        self.photoLabel.text = NSLocalizedString(@"Tap to pick photo", @"");
    } else {
        self.photoLabel.text = NSLocalizedString(@"No photo specified", @"");
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.photoButton.frame = CGRectMake((self.bounds.size.width - kPhotoPlaceholderSize) / 2.0,
                                        (self.bounds.size.height - kPhotoPlaceholderSize) / 2.0,
                                        kPhotoPlaceholderSize,
                                        kPhotoPlaceholderSize);
    self.photoView.frame = CGRectMake(0, 0, kPhotoPlaceholderSize, kPhotoPlaceholderSize);
    self.photoLabel.frame = self.photoButton.frame;
}

- (void)didTapPhoto {
    NSString *title = NSLocalizedString(@"Profile Photo", @"");
    if (self.editing) {
        UIAlertController *alert =
            [UIAlertController alertControllerWithTitle:title
                                                message:nil
                                                    preferredStyle:UIAlertControllerStyleActionSheet];

        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            UIAlertAction *pickPhotoAction =
                [UIAlertAction actionWithTitle:NSLocalizedString(@"Pick a photo", @"")
                                         style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action) {
                                           [self showImagePicker:UIImagePickerControllerSourceTypePhotoLibrary];
                                       }];
            [alert addAction:pickPhotoAction];
        }
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            UIAlertAction *takePhotoAction =
                [UIAlertAction actionWithTitle:NSLocalizedString(@"Take a photo", @"")
                                         style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action) {
                                           [self showImagePicker:UIImagePickerControllerSourceTypeCamera];
                                       }];
            [alert addAction:takePhotoAction];
        }
        
        if (self.value) {
            UIAlertAction *clearPhoto =
                [UIAlertAction actionWithTitle:NSLocalizedString(@"Clear photo", @"")
                                         style:UIAlertActionStyleDestructive
                                       handler:^(UIAlertAction *action) {
                                           [self clearPhoto];
                                       }];
            [alert addAction:clearPhoto];
        }
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"")
                                                         style:UIAlertActionStyleCancel
                                                       handler:^(UIAlertAction * action) {
                                                       }];
        
        [alert addAction:cancel];
        [self.delegate present:alert animated:YES completion:nil];
    } else if (self.value) {
        PhotoAnnotationViewController *photoViewer = [[PhotoAnnotationViewController alloc] initWithImage:self.photoView.image];
        photoViewer.title = title;
        photoViewer.delegate = self;
        photoViewer.dataSource = [Model instance].application;
        [self.delegate push:photoViewer animated:YES completion:nil];
    }
}

- (void)didFinishEditImage:(UIImage *)image {
    image = [image squareImage];
    [self setPhoto:image];
    [self.delegate popToRootViewControllerAnimated:YES];
}
                                                                                       
- (void)showImagePicker:(UIImagePickerControllerSourceType)sourceType {
    UIImagePickerController *photoPicker = [UIImagePickerController new];
    photoPicker.allowsEditing = YES;
    photoPicker.delegate = self;
    photoPicker.sourceType = sourceType;
    photoPicker.mediaTypes = @[(NSString *)kUTTypeImage];
    [self.delegate present:photoPicker animated:YES completion:nil];
    photoPicker.view.tintColor = [Configuration instance].highlightColor;
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([navigationController.viewControllers count] == 3) {
        UIView *cropOverlay = [[[viewController.view.subviews objectAtIndex:1]subviews] objectAtIndex:0];
        cropOverlay.hidden = YES;
        
        CGRect bounds = [[UIScreen mainScreen] bounds];
        CGFloat position = (bounds.size.height - bounds.size.width) / 2.0;

        CAShapeLayer *circleLayer = [CAShapeLayer layer];
        UIBezierPath *path2 = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, position, bounds.size.width, bounds.size.width)];
        [path2 setUsesEvenOddFillRule:YES];
        [circleLayer setPath:[path2 CGPath]];
        
        [circleLayer setFillColor:[[UIColor clearColor] CGColor]];
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, bounds.size.width, bounds.size.height - 72.0) cornerRadius:0];
        [path appendPath:path2];
        [path setUsesEvenOddFillRule:YES];
        
        CAShapeLayer *fillLayer = [CAShapeLayer layer];
        fillLayer.path = path.CGPath;
        fillLayer.fillRule = kCAFillRuleEvenOdd;
        fillLayer.fillColor = [UIColor blackColor].CGColor;
        fillLayer.opacity = 0.8;
        [viewController.view.layer addSublayer:fillLayer];
        
        UILabel *moveLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, bounds.size.width, 50)];
        [moveLabel setText:NSLocalizedString(@"Move and Scale", @"")];
        [moveLabel setTextAlignment:NSTextAlignmentCenter];
        [moveLabel setTextColor:[UIColor whiteColor]];
        
        [viewController.view addSubview:moveLabel];
    }
}

- (void)imagePickerController:(UIImagePickerController *)photoPicker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = info[UIImagePickerControllerEditedImage];
    image = [[image squareImage] resizeImage:CGSizeMake(kPhotoResolution, kPhotoResolution)];
    [self setPhoto:image];
    [[AppDelegate instance] dismiss:photoPicker animated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)photoPicker {
    [[AppDelegate instance] dismiss:photoPicker animated:YES completion:nil];
}

- (void)setValue:(id)value {
    super.value = value;
    self.photoButton.enabled = self.value != nil || self.isEditing;
    if (self.value) {
        [Photo asyncPhotoImage:self.value done:^(UIImage *image) {
            self.photoView.image = image;
            self.photoLabel.hidden = YES;
        }];
        return;
    }
    self.photoView.image = [UIImage imageNamed:@"photo_placeholder"];
    self.photoLabel.hidden = NO;
}

- (void)setPhoto:(UIImage *)image {
    [self clearPhoto];
    Photo *photo = [[Model instance].application addAggregation:@"photo" parameters:@{ @"data" : UIImageJPEGRepresentation(image, 0.8)}];
    [self setProperty:@"value" value:photo.uuid];
}

- (void)clearPhoto {
    if (self.value) {
        [[Model instance].application removeAggregation:@"photo" uuid:self.value];
        [self setProperty:@"value" value:nil];
    }
}

@end