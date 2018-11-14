//
//  Photo.h
//  TeacherPlanner
//
//  Created by Oliver on 03.05.14.
//
//

#import "JSONRootEntity.h"

@interface Photo : JSONRootEntity

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSData *data;

- (UIImage *)image;

+ (void)asyncPhotoImage:(NSString *)photoUUID done:(void (^)(UIImage *image))done;
+ (void)asyncPhotoThumbnail:(NSString *)photoUUID done:(void (^)(UIImage *image))done;

@end
