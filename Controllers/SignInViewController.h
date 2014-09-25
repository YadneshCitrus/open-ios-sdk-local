//
//  SignInViewController.h
//  SDKSandbox
//
//  Created by Mukesh Patil on 08/09/14.
//  Copyright (c) 2014 CitrusPay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CitrusSdk.h"
#import "PayViewController.h"
#import "AppDelegate.h"
#import "CTSTextFieldValidator.h"

@interface SignInViewController : UIViewController <CTSAuthenticationProtocol,
                                                    UIAlertViewDelegate,
                                                     SignOutDelegate>
{
    IBOutlet __weak CTSTextFieldValidator *usernameTextField;
    IBOutlet __weak CTSTextFieldValidator *passwordTextField;
    
    CTSAuthLayer* authLayer;
}
@property(nonatomic,weak) IBOutlet CTSTextFieldValidator *usernameTextField;
@property(nonatomic,weak) IBOutlet CTSTextFieldValidator *passwordTextField;

/**
 *  sign in the user
 *
 *  @param dynamic object sender
 */
-(IBAction)signInAction:(id)sender;


/**
 *  in case of forget password, after recieving this server will send email to
 *this user to initiate the password reset
 *
 *  @param dynamic object sender
 */
-(IBAction)resetPasswordAction:(id)sender;

/**
 *  to change the user password
 *
 *  @param dynamic object sender
 */
-(IBAction)changePasswordAction:(id)sender;
@end
