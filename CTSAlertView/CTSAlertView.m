//
//  CTSAlertView.m
//  SDKSandbox
//
//  Created by Mukesh Patil on 05/09/14.
//  Copyright (c) 2014 CitrusPay. All rights reserved.
//

#import "CTSAlertView.h"

@interface CTSAlertView ()

@property(nonatomic,strong) UIActivityIndicatorView* activityView;

@end

@implementation CTSAlertView
@synthesize activityView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


-(void)createProgressionAlertWithMessage:(NSString *)message withActivity:(BOOL)activity
{
    // Create the progress bar and add it to the alert
    self.title = @"Please wait...";
    self.message = message;
    if (activity) {
        self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.activityView.center = CGPointMake(139.5, 75.5); // .5 so it doesn't blur
        [self addSubview:self.activityView];
        [self.activityView startAnimating];
}
    [self show];
}

-(void)hideCTSAlertView:(BOOL)activity
{
    // Create the progress bar and add it to the alert
    if (activity) {
        [self.activityView stopAnimating];
        [self dismissWithClickedButtonIndex:0 animated:NO];
    }
}




/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
