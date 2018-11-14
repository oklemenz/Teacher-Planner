//
//  PDFTableViewController.m
//  TeacherPlanner
//
//  Created by Oliver on 25.05.14.
//
//

#import "PDFTableViewController.h"
#import "PDFTableCreator.h"
#import "Utilities.h"

@interface PDFTableViewController ()

@property (nonatomic, strong) NSDictionary *settings;
@property (nonatomic, strong) PDFTableCreator *pdfTableCreator;
@property (nonatomic) BOOL landscape;

@end

@implementation PDFTableViewController

- (instancetype)initWithSettings:(NSDictionary *)settings {
    self = [self init];
    if (self) {
        [self updateSettings:settings];
    }
    return self;
}

- (void)updateSettings:(NSDictionary *)settings {
    self.settings = settings;
    _filePath = settings[kPDFTableCreatorFilePath];
    _fileURL = [NSURL fileURLWithPath:self.filePath];
    self.pdfTableCreator = [[PDFTableCreator alloc] initWithSettings:settings];
}

- (void)viewDidLoad {
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.webView.backgroundColor = [UIColor whiteColor];
    self.webView.delegate = self;
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.webView];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeOrientation:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)show {
    [self.pdfTableCreator create];
    NSURLRequest *request = [NSURLRequest requestWithURL:self.fileURL];
    self.webView.scalesPageToFit = YES;
    self.webView.delegate = self;
    [self.webView loadRequest:request];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self performSelector:@selector(scrollToCenter) withObject:nil afterDelay:0.1];
}

- (void)scrollToCenter {
    CGFloat scrollHeight = self.webView.scrollView.contentSize.height - self.webView.bounds.size.height;
    if (0.0f > scrollHeight) {
        scrollHeight = 0.0f;
    }
    [self.webView.scrollView setContentOffset:CGPointMake(0.0f, scrollHeight / 2.0) animated:YES];
}

- (void)changeOrientation:(NSNotification *)notification {
    if ([self.settings[kPDFTableCreatorOrientationSupport] boolValue]) {
        UIDeviceOrientation currentDeviceOrientation = [[UIDevice currentDevice] orientation];
        if (currentDeviceOrientation == UIDeviceOrientationLandscapeLeft || currentDeviceOrientation == UIDeviceOrientationPortraitUpsideDown) {
            self.webView.transform = CGAffineTransformMakeRotation(M_PI);
        } else {
            self.webView.transform = CGAffineTransformIdentity;
        }
        if ((UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation) && !self.landscape) ||
            (UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation) && self.landscape)) {
            [self show];
        }
        self.landscape = UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation);
    }
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

@end