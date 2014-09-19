//
//  SignUpViewController.h
//  SDKSandbox
//
//  Created by Mukesh Patil on 08/09/14.
//  Copyright (c) 2014 CitrusPay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CitrusSdk.h"
#import "CTSTextFieldValidator.h"

@interface SignUpViewController : UIViewController <CTSAuthenticationProtocol,
                                                    CTSPaymentProtocol,
                                                    CTSProfileProtocol>
{
    IBOutlet __weak CTSTextFieldValidator *firstnameTextField;
    IBOutlet __weak CTSTextFieldValidator *lastnameTextField;
    IBOutlet __weak CTSTextFieldValidator *emailTextField;
    IBOutlet __weak CTSTextFieldValidator *mobileTextField;
    IBOutlet __weak CTSTextFieldValidator *passwordTextField;
    IBOutlet __weak CTSTextFieldValidator *confrimPasswordTextField;

    CTSAuthLayer* authLayer;
    CTSProfileLayer* profileLayer;
}
@property(nonatomic,weak) IBOutlet CTSTextFieldValidator *firstnameTextField;
@property(nonatomic,weak) IBOutlet CTSTextFieldValidator *lastnameTextField;
@property(nonatomic,weak) IBOutlet CTSTextFieldValidator *emailTextField;
@property(nonatomic,weak) IBOutlet CTSTextFieldValidator *mobileTextField;
@property(nonatomic,weak) IBOutlet CTSTextFieldValidator *passwordTextField;
@property(nonatomic,weak) IBOutlet CTSTextFieldValidator *confrimPasswordTextField;

/**
 *  to sign up the user
 *
 *  @param dynamic object sender
 */
-(IBAction)signUpAction:(id)sender;
@end
