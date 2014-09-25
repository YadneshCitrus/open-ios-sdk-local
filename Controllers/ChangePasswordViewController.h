//
//  ChangePasswordViewController.h
//  SDKSandbox
//
//  Created by Mukesh Patil on 16/09/14.
//  Copyright (c) 2014 CitrusPay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CitrusSdk.h"
#import "TestParams.h"
#import "CTSTextFieldValidator.h"

@interface ChangePasswordViewController : UIViewController
{
    IBOutlet __weak CTSTextFieldValidator *usernameTextField;
    IBOutlet __weak CTSTextFieldValidator *oldPasswordTextField;
    IBOutlet __weak CTSTextFieldValidator *passwordTextField;
    IBOutlet __weak CTSTextFieldValidator *confirmPasswordTextField;
    
    CTSAuthLayer* authLayer;
}
@property(nonatomic,weak) IBOutlet CTSTextFieldValidator *usernameTextField;
@property(nonatomic,weak) IBOutlet CTSTextFieldValidator *oldPasswordTextField;
@property(nonatomic,weak) IBOutlet CTSTextFieldValidator *passwordTextField;
@property(nonatomic,weak) IBOutlet CTSTextFieldValidator *confirmPasswordTextField;

/**
 *  to change the user password
 *
 *  @param dynamic object sender
 */
-(IBAction)changePasswordAction:(id)sender;

@end
