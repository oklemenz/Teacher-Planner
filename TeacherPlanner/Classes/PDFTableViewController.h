//
//  PDFTableViewController.h
//  TeacherPlanner
//
//  Created by Oliver on 25.05.14.
//
//

#import <UIKit/UIKit.h>

@interface PDFTableViewController : UIViewController <UIWebViewDelegate>

@property (strong, nonatomic) IBOutlet UIWebView *webView;

@property (nonatomic, strong, readonly) NSString *filePath;
@property (nonatomic, strong, readonly) NSURL *fileURL;

- (instancetype)initWithSettings:(NSDictionary *)settings;

- (void)show;
- (void)updateSettings:(NSDictionary *)settings;

@end
