//
//  RSDFDatePickerDetailView.m
//  TeacherPlanner
//
//  Created by Oliver on 25.05.14.
//
//

#import "RSDFDatePickerDetailView.h"
#import "RSDayFlow.h"
#import "Utilities.h"

@interface RSDFDatePickerDetailView ()

@property(nonatomic, strong) CALayer *topBorder;
@property(nonatomic) BOOL shown;

@end

@implementation RSDFDatePickerDetailView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.userInteractionEnabled = NO;
        
        self.header = [[UILabel alloc] initWithFrame:CGRectZero];
        self.header.textAlignment = NSTextAlignmentCenter;
        self.header.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        self.header.font = [UIFont boldSystemFontOfSize:20.0f];
        self.header.textColor = [UIColor blackColor];
        [self addSubview:self.header];
        
        self.headerDescription = [[UILabel alloc] initWithFrame:CGRectZero];
        self.headerDescription.textAlignment = NSTextAlignmentCenter;
        self.headerDescription.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        self.headerDescription.font = [UIFont boldSystemFontOfSize:15.0f];
        self.headerDescription.textColor = [UIColor blackColor];
        [self addSubview:self.headerDescription];
        
        self.topBorder = [CALayer layer];
        self.topBorder.frame = CGRectMake(0.0f, 0.0f, self.frame.size.width, 1.0f);
        self.topBorder.backgroundColor = [UIColor colorWithWhite:200/255.0f alpha:1.0f].CGColor;
        [self.layer addSublayer:self.topBorder];
        
        self.alpha = 0.0f;
        self.shown = NO;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.topBorder.frame = CGRectMake(0.0f, 0.0f, self.frame.size.width, 1.0f);
}

- (void)show {
    self.shown = YES;
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 0.9f;
    }];
}

- (void)hide {
    self.shown = NO;
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 0.0f;
    }];
}

- (void)setHeaderDate:(NSDate *)date {
    self.header.text = [[Utilities dateFormatter] stringFromDate:date];
}

- (void)setDescriptionInfo:(NSArray *)info {
    if (info.count > 0) {
        NSString *description = @"";
        for (NSDictionary *entry in info) {
            if ([description isEqualToString:@""]) {
                description = entry[@"name"];
            } else {
                description = [description stringByAppendingFormat:@", %@", entry[@"name"]];
            }
        }
        self.headerDescription.text = description;
    } else {
        self.headerDescription.text = @"";
    }
    [self position];
}

- (void)position {
    if (self.headerDescription.text.length > 0) {
        CGFloat line = self.bounds.size.height / 3.0;
        self.header.frame = CGRectMake(0, line / 2.0, self.bounds.size.width, line);
        self.headerDescription.frame = CGRectMake(0, 1.5 * line, self.bounds.size.width, line);
    } else {
        self.header.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
        self.headerDescription.text = @"";
    }
}

@end
