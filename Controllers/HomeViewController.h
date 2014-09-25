//
//  HomeViewController.h
//  SDKSandbox
//
//  Created by Mukesh Patil on 05/09/14.
//  Copyright (c) 2014 CitrusPay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CitrusSdk.h"

@interface HomeViewController : UIViewController
/**
 Use to perform sign up
 *
 *  @param dynamic object sender
 */
-(IBAction)signUpAction:(id)sender;

/**
 Use to perform sign in
 *
 *  @param dynamic object sender
 */
-(IBAction)signInAction:(id)sender;

/**
 Use to perform guest payment
 *
 *  @param dynamic object sender
 */
-(IBAction)guestPayAction:(id)sender;
@end
