//
//  CTSAlertView.h
//  SDKSandbox
//
//  Created by Mukesh Patil on 05/09/14.
//  Copyright (c) 2014 CitrusPay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CTSAlertView : UIAlertView <UITextFieldDelegate>

/**
 *  show alertView with activity
 *
 *  @param alertView message
 *  @param show activity if YES
 */
- (void)didPresentLoadingAlertView:(NSString *)message withActivity:(BOOL)activity;

/**
 *  dismiss alertView with activity
 *
 *  @param shdismissow activity if YES
 */
- (void)dismissLoadingAlertView:(BOOL)activity;

/**
 *  show alertView with input
 *
 *  @param alertView title
 *  @param alertView message
 */
-(void)didPresentInputAlertView:(NSString *)title message:(NSString*)message;
@end
