//
//  Photo.m
//  TeacherPlanner
//
//  Created by Oliver on 03.05.14.
//
//

#import "Photo.h"
#import "Model.h"
#import "Application.h"
#import "Utilities.h"
#import "UIImage+Extension.h"

#define kPhotoImageSize 41

@implementation Photo {
    UIImage *_image;
}

- (UIImage *)image {
    if (self.data) {
        if (!_image) {
            _image = [UIImage imageWithData:self.data];
        }
        return _image;
    }
    return nil;
}

+ (void)asyncPhotoImage:(NSString *)photoUUID done:(void (^)(UIImage *image))done {
    dispatch_async(dispatch_queue_create("load image from photo", nil), ^{
        Photo *photo = [[Model instance].application photoByUUID:photoUUID];
        UIImage *image = [photo image];
        dispatch_async(dispatch_get_main_queue(), ^{
            done(image);
        });
    });
}

+ (void)asyncPhotoThumbnail:(NSString *)photoUUID done:(void (^)(UIImage *image))done {
    [Photo asyncPhotoImage:photoUUID done:^(UIImage *image) {
        done([image scaledImage:kPhotoImageSize]);
    }];
}

@end