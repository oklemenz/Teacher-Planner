//
//  AnnotationHandler.m
//  TeacherPlanner
//
//  Created by Klemenz, Oliver on 25.07.14.
//
//

#import "AnnotationHandler.h"
#import <CoreMedia/CoreMedia.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <AVFoundation/AVFoundation.h>
#import "Utilities.h"
#import "UIImage+Extension.h"
#import "TextAnnotationViewController.h"
#import "PhotoAnnotationViewController.h"
#import "VideoAnnotationViewController.h"
#import "ImageAnnotationViewController.h"
#import "Common.h"
#import "UIViewController+Extension.h"
#import "UILabel+Extension.h"
#import "Configuration.h"
#import "AppDelegate.h"

#define kAnnotationThumbnailSize   100.0f
#define kAnnotationJPGImageQuality 0.5

@interface AnnotationHandler ()

@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) UIImagePickerController *videoPicker;
@property (nonatomic, strong) UIAlertController *alert;

@property (nonatomic, strong) NSDate *startTime;
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) AVAudioRecorder *audioRecorder;

@property (nonatomic) NSString *filePath;

@end

@implementation AnnotationHandler

- (instancetype)initWithAnnotationType:(CodeAnnotationType)type presenter:(UIViewController *)presenter {
    self = [self init];
    if (self) {
        _annotationType = type;
        _presenter = presenter;
    }
    return self;
}

- (UINavigationController *)navigationController {
    return self.presenter.navigationController;
}

- (void)create:(BOOL)crop {
    UIViewController *viewController;
    if (self.annotationType == CodeAnnotationTypeText) {
        viewController = [self writeText];
    } else if (self.annotationType == CodeAnnotationTypePhoto) {
        viewController = [self takePhoto:crop];
    } else if (self.annotationType == CodeAnnotationTypeImage) {
        viewController = [self drawImage];
    } else if (self.annotationType == CodeAnnotationTypeAudio) {
        viewController = [self recordAudio];
    } else if (self.annotationType == CodeAnnotationTypeVideo) {
        viewController = [self recordVideo];
    }
    [self show:viewController annotation:nil presenter:self.presenter];
}

- (void)choose:(BOOL)crop {
    UIViewController *viewController;
    if (self.annotationType == CodeAnnotationTypeText) {
        return;
    } else if (self.annotationType == CodeAnnotationTypePhoto) {
        viewController = [self choosePhoto:crop];
    } else if (self.annotationType == CodeAnnotationTypeImage) {
        return;
    } else if (self.annotationType == CodeAnnotationTypeAudio) {
        return;
    } else if (self.annotationType == CodeAnnotationTypeVideo) {
        viewController = [self chooseVideo];
    }
    [self show:viewController annotation:nil presenter:self.presenter];
}

- (void)display:(Annotation *)annotation {
    UIViewController *viewController;
    if (self.annotationType == CodeAnnotationTypeText) {
        viewController = [self displayText:annotation.text];
    } else if (self.annotationType == CodeAnnotationTypePhoto) {
        viewController = [self displayImage:annotation.image];
    } else if (self.annotationType == CodeAnnotationTypeImage) {
        viewController = [self displayImage:annotation.image];
    } else if (self.annotationType == CodeAnnotationTypeAudio) {
        viewController = [self playAudio:annotation.data];
    } else if (self.annotationType == CodeAnnotationTypeVideo) {
        viewController = [self playVideo:annotation.data];
    }
    [self show:viewController annotation:annotation presenter:self.presenter];
}

- (UIViewController *)present:(Annotation *)annotation presenter:(UIViewController *)presenter {
    UIViewController *viewController;
    if (annotation.type == CodeAnnotationTypeText) {
        viewController = [[self displayText:annotation.text] embedInNavigationController];
    } else if (annotation.type == CodeAnnotationTypePhoto) {
        viewController = [[self displayImage:annotation.image] embedInNavigationController];
    } else if (annotation.type == CodeAnnotationTypeImage) {
        viewController = [[self displayImage:annotation.image] embedInNavigationController];
    } else if (annotation.type == CodeAnnotationTypeAudio) {
        viewController = [self playAudio:annotation.data];
    } else if (annotation.type == CodeAnnotationTypeVideo) {
        viewController = [self playVideo:annotation.data];
    }
    if (viewController) {
        [self show:viewController annotation:annotation presenter:presenter];
    }
    return viewController;
}

- (void)show:(UIViewController *)viewController annotation:(Annotation *)annotation presenter:(UIViewController *)presenter {
    if (viewController) {
        if (annotation) {
            UIViewController *annotationViewController = viewController;
            if ([viewController isKindOfClass:UINavigationController.class]) {
                annotationViewController = [(UINavigationController *)viewController topViewController];
                annotationViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", @"") style:UIBarButtonItemStylePlain target:presenter action:@selector(close:)];
                annotationViewController.navigationItem.rightBarButtonItems = nil;
            }
            if (annotation.subTitle.length > 0) {
                NSString *title = [NSString stringWithFormat:@"%@\n%@", annotation.title, annotation.subTitle];
                UILabel *label = [UILabel createTwoLineTitleLabel:title color:[[Configuration instance] titleColor]];
                annotationViewController.navigationItem.titleView = label;
            } else {
                annotationViewController.title = annotation.title;
            }
        }
        if ([viewController isKindOfClass:UINavigationController.class] ||
            [viewController isKindOfClass:UIImagePickerController.class] ||
            [viewController isKindOfClass:UIAlertController.class] ||
            !presenter.navigationController) {
            if (presenter.navigationController) {
                [[AppDelegate instance] present:viewController presenter:presenter.navigationController animated:YES completion:nil];
            } else {
                [[AppDelegate instance] present:viewController presenter:presenter animated:YES completion:nil];
            }
        } else if ([viewController isKindOfClass:[AVPlayerViewController class]]) {
            [[AppDelegate instance] present:viewController presenter:self.presenter animated:YES completion:^{
                [[(AVPlayerViewController *)viewController player] play];
            }];
        } else {
            [presenter.navigationController pushViewController:viewController animated:YES];
        }
    }
}

- (TextAnnotationViewController *)writeText {
    TextAnnotationViewController *textAnnotation = [TextAnnotationViewController new];
    textAnnotation.delegate = self;
    textAnnotation.editing = YES;
    textAnnotation.dataSource = self.dataSource;
    return textAnnotation;
}

- (TextAnnotationViewController *)displayText:(NSString *)text {
    TextAnnotationViewController *textAnnotation = [[TextAnnotationViewController alloc] initWithText:text];
    textAnnotation.delegate = self;
    textAnnotation.editing = self.editing;
    textAnnotation.dataSource = self.dataSource;
    textAnnotation.title = NSLocalizedString(@"View Text", @"");
    return textAnnotation;
}

- (void)didFinishWritingText:(NSString *)text updated:(BOOL)updated {
    NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
    if (!updated) {
        [self.delegate didAddAnnotation:data thumbnail:nil length:text.length sender:self];
    } else {
        [self.delegate didUpdateAnnotation:data thumbnail:nil length:text.length sender:self];
    }
    [self.navigationController popViewControllerAnimated:YES];
    [self.delegate didFinish];
}

- (UIImagePickerController *)takePhoto:(BOOL)crop {
    self.imagePicker = [UIImagePickerController new];
    self.imagePicker.delegate = self;
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.imagePicker.mediaTypes = @[(NSString*)kUTTypeImage];
    self.imagePicker.allowsEditing = crop;
    return self.imagePicker;
}

- (UIImagePickerController *)choosePhoto:(BOOL)crop {
    self.imagePicker = [UIImagePickerController new];
    self.imagePicker.delegate = self;
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.imagePicker.mediaTypes = @[(NSString*)kUTTypeImage];
    self.imagePicker.allowsEditing = crop;
    return self.imagePicker;
}

- (UIAlertController *)recordAudio {
    self.alert = [Common showConfirmation:nil
                                    title:NSLocalizedString(@"Record Audio", @"")
                                  message:NSLocalizedString(@"Tap record to start", @"")
                            okButtonTitle:NSLocalizedString(@"Record", @"")
                              destructive:NO
                        cancelButtonTitle:nil
                                okHandler:^{
                                 self.alert = [Common showMessage:self.presenter
                                                            title:NSLocalizedString(@"Recording...", @"")
                                                          message:[Utilities formatSeconds:0]
                                                    okButtonTitle:NSLocalizedString(@"Stop", @"")
                                                        okHandler:^{
                                                            NSInteger length = [self stopRecording];
                                                            NSData *data = [NSData dataWithContentsOfFile:self.filePath];
                                                            [Utilities clearGeneratedFolder];
                                                            [self.delegate didAddAnnotation:data thumbnail:nil length:length sender:self];
                                                            [self.timer invalidate];
                                                            self.timer = nil;
                                                            self.startTime = nil;
                                                            self.alert = nil;
                                                    }];
                         self.filePath = [[Utilities generatedFolder] stringByAppendingPathComponent:@"audio.aac"];
                         [self startRecording:ENC_AAC filePath:self.filePath];
                         self.startTime = [NSDate date];
                         self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(updateTime) userInfo:nil repeats:YES];

                     } cancelHandler:^{
                         self.alert = nil;
                     }];
    return self.alert;
}

- (void)updateTime {
    NSInteger seconds = [[NSDate date] timeIntervalSinceDate:self.startTime];
    [self.alert setMessage:[Utilities formatSeconds:seconds]];
}

- (BOOL)startRecording:(NSInteger)recordEncoding filePath:(NSString *)filePath {
    self.audioRecorder = nil;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryRecord error:nil];
    NSDictionary *recordSettings;
    if (recordEncoding == ENC_PCM) {
        recordSettings = @{ AVFormatIDKey: @(kAudioFormatLinearPCM),
                            AVNumberOfChannelsKey: @(2),
                            AVSampleRateKey: @(44100),
                            AVLinearPCMBitDepthKey : @(16),
                            AVLinearPCMIsBigEndianKey : @(NO),
                            AVLinearPCMIsFloatKey : @(NO) };
    } else  {
        NSInteger format;
        switch (recordEncoding) {
            case (ENC_AAC):
                format = kAudioFormatMPEG4AAC;
                break;
            case (ENC_ALAC):
                format = kAudioFormatAppleLossless;
                break;
            case (ENC_IMA4):
                format = kAudioFormatAppleIMA4;
                break;
            case (ENC_ILBC):
                format = kAudioFormatiLBC;
                break;
            case (ENC_ULAW):
                format = kAudioFormatULaw;
                break;
            default:
                format = kAudioFormatAppleIMA4;
        }
        recordSettings = @{AVEncoderAudioQualityKey: @(AVAudioQualityMedium),
                           AVFormatIDKey: @(format),
                           AVEncoderBitRateKey: @(128000),
                           AVNumberOfChannelsKey: @(2),
                           AVSampleRateKey: @(44100),
                           AVLinearPCMBitDepthKey : @(16)};
    }
    NSURL *url = [NSURL fileURLWithPath:filePath];
    NSError *error = nil;
    self.audioRecorder = [[AVAudioRecorder alloc] initWithURL:url settings:recordSettings error:&error];
    if ([self.audioRecorder prepareToRecord]){
        [self.audioRecorder record];
        return YES;
    }
    return NO;
}

- (NSInteger)stopRecording {
    NSInteger length = lroundf(self.audioRecorder.currentTime);
    [self.audioRecorder stop];
    return length;
}

- (UIAlertController *)playAudio:(NSData *)data {
    NSURL *url = [Utilities writeGeneratedFile:data path:@"audio.aac"];
    self.alert = [Common showMessage:nil
                               title:NSLocalizedString(@"Playing...", @"")
                             message:[Utilities formatSeconds:0]
                       okButtonTitle:NSLocalizedString(@"Stop", @"")
                           okHandler:^{
                               [self stopPlaying];
                               [self playingStopped];
                               self.alert = nil;
                           }];
    self.startTime = [NSDate date];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    NSError *error;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    self.audioPlayer.delegate = self;
    self.audioPlayer.numberOfLoops = 0;
    [self.audioPlayer play];
    return self.alert;
}

- (void)stopPlaying {
    [self.audioPlayer stop];
    [Utilities clearGeneratedFolder];
}

- (void)playingStopped {
    [self.timer invalidate];
    self.timer = nil;
    self.startTime = nil;
    self.alert = nil;
    [self.delegate didFinish];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [[AppDelegate instance] dismiss:self.alert animated:YES completion:nil];
    [self playingStopped];
}

- (ImageAnnotationViewController *)drawImage {
    ImageAnnotationViewController *imageAnnotation = [ImageAnnotationViewController new];
    imageAnnotation.delegate = self;
    imageAnnotation.dataSource = self.imageDataSource;
    return imageAnnotation;
}

- (void)didFinishDrawingImage:(UIImage *)image updated:(BOOL)updated {
    NSData *data = UIImageJPEGRepresentation(image, kAnnotationJPGImageQuality);
    UIImage *thumbnailImage = [image scaledImage:kAnnotationThumbnailSize];
    NSData *thumbnailData = UIImageJPEGRepresentation(thumbnailImage, kAnnotationJPGImageQuality);
    [self.delegate didAddAnnotation:data thumbnail:thumbnailData length:data.length sender:self];
    [self.navigationController popViewControllerAnimated:YES];
    [self.delegate didFinish];
}

- (PhotoAnnotationViewController *)displayImage:(UIImage *)image {
    PhotoAnnotationViewController *photoAnnotation = [[PhotoAnnotationViewController alloc] initWithImage:image];
    photoAnnotation.delegate = self;
    photoAnnotation.dataSource = self.imageDataSource;
    photoAnnotation.editing = self.editing;
    photoAnnotation.title = NSLocalizedString(@"View Picture", @"");
    return photoAnnotation;
}

- (void)didFinishEditImage:(UIImage *)image {
    NSData *data = UIImageJPEGRepresentation(image, kAnnotationJPGImageQuality);
    UIImage *thumbnailImage = [image scaledImage:kAnnotationThumbnailSize];
    NSData *thumbnailData = UIImageJPEGRepresentation(thumbnailImage, kAnnotationJPGImageQuality);
    [self.delegate didUpdateAnnotation:data thumbnail:thumbnailData length:data.length sender:self];
    [self.navigationController popViewControllerAnimated:YES];
    [self.delegate didFinish];
}

- (UIImagePickerController *)recordVideo {
    self.videoPicker = [UIImagePickerController new];
    self.videoPicker.delegate = self;
    self.videoPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.videoPicker.mediaTypes = @[(NSString*)kUTTypeMovie];
    self.videoPicker.allowsEditing = YES;
    self.videoPicker.videoQuality = UIImagePickerControllerQualityTypeMedium;
    self.videoPicker.videoMaximumDuration = 30.0f;
    return self.videoPicker;
}

- (UIImagePickerController *)chooseVideo {
    self.videoPicker = [UIImagePickerController new];
    self.videoPicker.delegate = self;
    self.videoPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.videoPicker.mediaTypes = @[(NSString*)kUTTypeMovie];
    self.videoPicker.allowsEditing = YES;
    return self.videoPicker;
}

- (AVPlayerViewController *)playVideo:(NSData *)data {
    NSURL *url = [Utilities writeGeneratedFile:data path:@"video.mp4"];
    AVPlayer *player = [AVPlayer playerWithURL:url];
    VideoAnnotationViewController *playerViewController = [VideoAnnotationViewController new];
    playerViewController.player = player;
    return playerViewController;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    if (picker == self.imagePicker) {
        [[AppDelegate instance] dismiss:picker animated:YES completion:nil];
        UIImage *image;
        if (picker.allowsEditing) {
            image = [info objectForKey:@"UIImagePickerControllerEditedImage"];
        } else {
            image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        }
        UIImage *thumbnailImage = [image scaledImage:kAnnotationThumbnailSize];
        NSData *data = UIImageJPEGRepresentation(image, kAnnotationJPGImageQuality);
        NSData *thumbnailData = UIImageJPEGRepresentation(thumbnailImage, kAnnotationJPGImageQuality);
        [self.delegate didAddAnnotation:data thumbnail:thumbnailData length:data.length sender:self];
        [self.delegate didFinish];
    } else if (picker == self.videoPicker) {
        [[AppDelegate instance] dismiss:picker animated:YES completion:nil];
        NSURL *url = [info objectForKey:UIImagePickerControllerMediaURL];
        AVAsset *movie = [AVAsset assetWithURL:url];
        CMTime movieDuration = movie.duration;
        NSInteger length = lroundf(movieDuration.value / movieDuration.timescale);
        NSData *data = [NSData dataWithContentsOfURL:url];
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
        AVAssetImageGenerator *generate1 = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        generate1.appliesPreferredTrackTransform = YES;
        NSError *err = NULL;
        CMTime time = CMTimeMake(1, 2);
        CGImageRef thumbnailRef = [generate1 copyCGImageAtTime:time actualTime:NULL error:&err];
        UIImage *thumbnailImage = [[UIImage alloc] initWithCGImage:thumbnailRef];
        NSData *thumbnailData = UIImageJPEGRepresentation(thumbnailImage, kAnnotationJPGImageQuality);
        [self.delegate didAddAnnotation:data thumbnail:thumbnailData length:length sender:self];
        [self.delegate didFinish];
    }
}

- (void)convertVideoToLowQuailtyWithInputURL:(NSURL *)inputURL outputURL:(NSURL *)outputURL {
    AVAsset *videoAsset = [[AVURLAsset alloc] initWithURL:inputURL options:nil];
    AVAssetTrack *videoTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    CGSize videoSize = videoTrack.naturalSize;
    NSDictionary *videoWriterCompressionSettings =  [NSDictionary dictionaryWithObjectsAndKeys:@(1250000), AVVideoAverageBitRateKey, nil];
    NSDictionary *videoWriterSettings = [NSDictionary dictionaryWithObjectsAndKeys:AVVideoCodecH264, AVVideoCodecKey, videoWriterCompressionSettings, AVVideoCompressionPropertiesKey, @(videoSize.width), AVVideoWidthKey, @(videoSize.height), AVVideoHeightKey, nil];
    AVAssetWriterInput* videoWriterInput = [AVAssetWriterInput
                                            assetWriterInputWithMediaType:AVMediaTypeVideo
                                            outputSettings:videoWriterSettings];
    videoWriterInput.expectsMediaDataInRealTime = YES;
    videoWriterInput.transform = videoTrack.preferredTransform;
    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:outputURL fileType:AVFileTypeQuickTimeMovie error:nil];
    [videoWriter addInput:videoWriterInput];
    NSDictionary *videoReaderSettings = [NSDictionary dictionaryWithObject:@(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange) forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    AVAssetReaderTrackOutput *videoReaderOutput = [[AVAssetReaderTrackOutput alloc] initWithTrack:videoTrack outputSettings:videoReaderSettings];
    AVAssetReader *videoReader = [[AVAssetReader alloc] initWithAsset:videoAsset error:nil];
    [videoReader addOutput:videoReaderOutput];
    AVAssetWriterInput* audioWriterInput = [AVAssetWriterInput
                                            assetWriterInputWithMediaType:AVMediaTypeAudio
                                            outputSettings:nil];
    audioWriterInput.expectsMediaDataInRealTime = NO;
    [videoWriter addInput:audioWriterInput];
    AVAssetTrack* audioTrack = [[videoAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
    AVAssetReaderOutput *audioReaderOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:audioTrack outputSettings:nil];
    AVAssetReader *audioReader = [AVAssetReader assetReaderWithAsset:videoAsset error:nil];
    [audioReader addOutput:audioReaderOutput];
    [videoWriter startWriting];
    [videoReader startReading];
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
    dispatch_queue_t processingQueue = dispatch_queue_create("processingQueue1", NULL);
    [videoWriterInput requestMediaDataWhenReadyOnQueue:processingQueue usingBlock:^{
        while ([videoWriterInput isReadyForMoreMediaData]) {
            CMSampleBufferRef sampleBuffer;
            if ([videoReader status] == AVAssetReaderStatusReading &&
                (sampleBuffer = [videoReaderOutput copyNextSampleBuffer])) {
                
                [videoWriterInput appendSampleBuffer:sampleBuffer];
                CFRelease(sampleBuffer);
            }
            else {
                [videoWriterInput markAsFinished];
                if ([videoReader status] == AVAssetReaderStatusCompleted) {
                    [audioReader startReading];
                    [videoWriter startSessionAtSourceTime:kCMTimeZero];
                    dispatch_queue_t processingQueue = dispatch_queue_create("processingQueue2", NULL);
                    [audioWriterInput requestMediaDataWhenReadyOnQueue:processingQueue usingBlock:^{
                        while (audioWriterInput.readyForMoreMediaData) {
                            CMSampleBufferRef sampleBuffer;
                            if ([audioReader status] == AVAssetReaderStatusReading &&
                                (sampleBuffer = [audioReaderOutput copyNextSampleBuffer])) {
                                
                                [audioWriterInput appendSampleBuffer:sampleBuffer];
                                CFRelease(sampleBuffer);
                            } else {
                                [audioWriterInput markAsFinished];
                                if ([audioReader status] == AVAssetReaderStatusCompleted) {
                                    [videoWriter finishWritingWithCompletionHandler:^(){
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            [self videoCompressionDone:outputURL];
                                            
                                        });
                                    }];
                                }  else if ([audioReader status] == AVAssetReaderStatusFailed ||
                                            [audioReader status] == AVAssetReaderStatusCancelled) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [self videoCompressionFailed];
                                    });
                                }
                            }
                        }
                        
                    }];
                } else if ([videoReader status] == AVAssetReaderStatusFailed ||
                          [videoReader status] == AVAssetReaderStatusCancelled) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self videoCompressionFailed];
                    });
                }
            }
        }
    }];
    [self.navigationController popViewControllerAnimated:YES];
    [self.delegate didFinish];
}

- (void)videoCompressionDone:(NSURL *)videoURL {
    NSData *data = [NSData dataWithContentsOfURL:videoURL];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:[videoURL path] error:NULL];
    [self.delegate didAddAnnotation:data thumbnail:nil length:data.length sender:self];
    [self.navigationController popViewControllerAnimated:YES];
    [self.delegate didFinish];
}

- (void)videoCompressionFailed {
    [self.navigationController popViewControllerAnimated:YES];
    [self.delegate didFinish];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
}

@end