//
//  ChangePasswordViewController.h
//  SDKSandbox
//
//  Created by Mukesh Patil on 16/09/14.
//  Copyright (c) 2014 CitrusPay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CitrusSdk.h"
#import "CTSAlertView.h"
#import "TestParams.h"

@interface ChangePasswordViewController : UIViewController
{
    IBOutlet __weak UITextField *usernameTextField;
    IBOutlet __weak UITextField *oldPasswordTextField;
    IBOutlet __weak UITextField *passwordTextField;
    
    CTSAuthLayer* authLayer;
}
@property(nonatomic,weak) IBOutlet UITextField *usernameTextField;
@property(nonatomic,weak) IBOutlet UITextField *oldPasswordTextField;
@property(nonatomic,weak) IBOutlet UITextField *passwordTextField;

/**
 *  to change the user password
 *
 *  @param dynamic object sender
 */
-(IBAction)changePasswordAction:(id)sender;

@end
