//
//  UIUtility.m
//  SDKSandbox
//
//  Created by Mukesh Patil on 24/09/14.
//  Copyright (c) 2014 CitrusPay. All rights reserved.
//

#import "UIUtility.h"
#import "CTSUtility.h"

#define LOADING_TITLE @"Please wait..."
#define ERROR_TITLE @"Error"
#define INFO_TITLE @"Information"

@implementation UIUtility
UIActivityIndicatorView* activityView;
UIAlertView* alertView;

+ (void)didPresentLoadingAlertView:(NSString *)message withActivity:(BOOL)activity
{
    if (activity) {
        alertView = [[UIAlertView alloc] initWithTitle:LOADING_TITLE
                                               message:message
                                              delegate:self
                                     cancelButtonTitle:nil
                                     otherButtonTitles:nil];
        
        activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        [alertView setValue:activityView forKey:@"accessoryView"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [activityView startAnimating];
        });
        [alertView show];
    }
}


+ (void)dismissLoadingAlertView:(BOOL)activity
{
    if (activity) {
        [alertView dismissWithClickedButtonIndex:0 animated:YES];
        [activityView stopAnimating];
    }
}


+ (void)didPresentErrorAlertView:(NSError*)error
{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:ERROR_TITLE message:[error.userInfo valueForKey:@"NSLocalizedDescription"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alertView show];
}

+ (void)didPresentInfoAlertView:(NSString*)message
{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:INFO_TITLE message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alertView show];
}

@end
