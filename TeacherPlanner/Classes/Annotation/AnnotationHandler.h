//
//  AnnotationHandler.h
//  TeacherPlanner
//
//  Created by Klemenz, Oliver on 25.07.14.
//
//

#import <UIKit/UIKit.h>
#import "Annotation.h"
#import <AVFoundation/AVFoundation.h>
#import "TextAnnotationViewController.h"
#import "PhotoAnnotationViewController.h"
#import "ImageAnnotationViewController.h"

@class AnnotationHandler;

@protocol AnnotationDataSource
- (JSONEntity *)dictionaryEntity;
- (NSString *)dictionaryAggregation;
- (NSInteger)numberOfAnnotation;
- (NSInteger)numberOfAnnotationGroup;
- (NSInteger)numberOfAnnotationByGroup:(NSInteger)group;
- (NSInteger)numberOfAnnotationByGroupName:(NSString *)groupName;
- (NSString *)annotationGroupName:(NSInteger)group;
- (NSIndexPath *)annotationGroupIndexByUUID:(NSString *)uuid;
- (Annotation *)annotationByGroup:(NSInteger)group index:(NSInteger)index;
- (Annotation *)annotationByUUID:(NSString *)uuid;
- (Annotation *)addAnnotation:(NSDictionary *)parameters;
- (void)insertAnnotation:(Annotation *)annotation;
- (void)updateAnnotation:(Annotation *)annotation parameters:(NSDictionary *)parameters;
- (void)removeAnnotationByUUID:(NSString *)uuid;
- (void)removeAnnotation:(Annotation *)annotation;
- (void)sortAnnotation;
@end

@protocol AnnotationHandlerDelegate <NSObject>
- (void)didAddAnnotation:(NSData *)data thumbnail:(NSData *)thumbnail length:(CGFloat)length sender:(id)sender;
- (void)didUpdateAnnotation:(NSData *)data thumbnail:(NSData *)thumbnail length:(CGFloat)length sender:(id)sender;
- (void)didFinish;
@end

@interface AnnotationHandler : NSObject <UINavigationControllerDelegate, UIImagePickerControllerDelegate, AVAudioPlayerDelegate, TextAnnotationViewControllerDelegate, PhotoAnnotationViewControllerDelegate, ImageAnnotationViewControllerDelegate> {
    enum {
        ENC_AAC  = 1,
        ENC_ALAC = 2,
        ENC_IMA4 = 3,
        ENC_ILBC = 4,
        ENC_ULAW = 5,
        ENC_PCM  = 6,
    } encodingTypes;
}

@property (nonatomic, readonly) CodeAnnotationType annotationType;
@property (nonatomic, weak) UIViewController *presenter;
@property (nonatomic, weak) id<AnnotationHandlerDelegate> delegate;
@property (nonatomic, weak) JSONEntity<AnnotationDataSource> *dataSource;
@property (nonatomic, weak) JSONEntity<ImageAnnotationDataSource> *imageDataSource;
@property (nonatomic) BOOL editing;

- (instancetype)initWithAnnotationType:(CodeAnnotationType)type presenter:(UIViewController *)presenter;

- (void)create:(BOOL)crop;
- (void)choose:(BOOL)crop;
- (void)display:(Annotation *)annotation;

- (UIViewController *)present:(Annotation *)annotation presenter:(UIViewController *)presenter;

@end