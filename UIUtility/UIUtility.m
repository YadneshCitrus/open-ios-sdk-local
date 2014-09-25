//
//  UIUtility.m
//  SDKSandbox
//
//  Created by Mukesh Patil on 24/09/14.
//  Copyright (c) 2014 CitrusPay. All rights reserved.
//

#import "UIUtility.h"
#import "CTSUtility.h"
#import "CTSError.h"
#import "CTSRestError.h"

#define LOADING_TITLE @"Please wait..."
#define ERROR_TITLE @"Error"
#define INFO_TITLE @"Information"

@implementation UIUtility
UIActivityIndicatorView* activityView;
UIAlertView* alertView;

/**
 *  show alertView with activity
 *
 *  @param alertView message
 *  @param show activity if YES
 */
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

/**
 *  dismiss alertView with activity
 *
 *  @param shdismissow activity if YES
 */
+ (void)dismissLoadingAlertView:(BOOL)activity
{
    if (activity) {
        [alertView dismissWithClickedButtonIndex:0 animated:YES];
        [activityView stopAnimating];
    }
}

/**
 *  dismiss alertView with error
 *
 *  @param alertView error
 */
+ (void)didPresentErrorAlertView:(NSError*)error
{
    NSDictionary *userInfo = [error userInfo];
    CTSRestError *citrusError = (CTSRestError *)[userInfo objectForKey:CITRUS_ERROR_DESCRIPTION_KEY];
    NSLog(@" citrusError type %@",citrusError.type);
    NSLog(@" citrusError description %@",citrusError.description);
    NSLog(@" citrusError error %@",citrusError.errorDescription);
    NSLog(@" citrusError serverResponse %@",citrusError.serverResponse);

    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:ERROR_TITLE message:citrusError.errorDescription delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alertView show];
}


/**
 *  dismiss alertView with message
 *
 *  @param alertView message
 */
+ (void)didPresentInfoAlertView:(NSString*)message
{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:INFO_TITLE message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alertView show];
}

@end
