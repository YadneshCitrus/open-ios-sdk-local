//
//  UIUtility.h
//  SDKSandbox
//
//  Created by Mukesh Patil on 24/09/14.
//  Copyright (c) 2014 CitrusPay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIUtility : NSObject <UITextFieldDelegate>
/**
 *  show alertView with activity
 *
 *  @param alertView message
 *  @param show activity if YES
 */
+(void)didPresentLoadingAlertView:(NSString *)message withActivity:(BOOL)activity;

/**
 *  dismiss alertView with activity
 *
 *  @param shdismissow activity if YES
 */
+(void)dismissLoadingAlertView:(BOOL)activity;

/**
 *  dismiss alertView with error
 *
 *  @param alertView error
 */
+ (void)didPresentErrorAlertView:(NSError*)error;

/**
 *  dismiss alertView with message
 *
 *  @param alertView message
 */
+ (void)didPresentInfoAlertView:(NSString*)message;
@end
