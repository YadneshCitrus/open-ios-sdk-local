//
//  CTSAlertView.m
//  SDKSandbox
//
//  Created by Mukesh Patil on 05/09/14.
//  Copyright (c) 2014 CitrusPay. All rights reserved.
//

#import "CTSAlertView.h"

#define TITLE @"Please wait..."

@interface CTSAlertView ()

@property(nonatomic,strong) UIActivityIndicatorView* activityView;

@end

@implementation CTSAlertView
@synthesize activityView;

- (id)initWithTitle:(NSString *)title
{
    if ( self = [super init] )
    {
        self.title = title;
        self.message = @"\n\n";
        
        [self setDelegate:self];
    }
    
    return self;
}

-(void)didPresentLoadingAlertView:(NSString *)message withActivity:(BOOL)activity
{
    // Create the progress bar and add it to the alert
    self.title = TITLE;
    self.message = message;
    if (activity) {
        self.activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        self.activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        [self setValue:self.activityView forKey:@"accessoryView"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.activityView startAnimating];
        });
        [self show];
    }
}


-(void)dismissLoadingAlertView:(BOOL)activity
{
    if (activity) {
        [self dismissWithClickedButtonIndex:0 animated:YES];
        [self.activityView stopAnimating];
    }
}

@end
