//
//  SignUpViewController.h
//  SDKSandbox
//
//  Created by Mukesh Patil on 08/09/14.
//  Copyright (c) 2014 CitrusPay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CitrusSdk.h"

@interface SignUpViewController : UIViewController <CTSAuthenticationProtocol,
                                                    CTSPaymentProtocol>
{
    IBOutlet __weak UITextField *firstnameTextField;
    IBOutlet __weak UITextField *lastnameTextField;
    IBOutlet __weak UITextField *emailTextField;
    IBOutlet __weak UITextField *mobileTextField;
    IBOutlet __weak UITextField *passwordTextField;
    
    CTSAuthLayer* authLayer;
    CTSProfileLayer* profileLayer;
}
@property(nonatomic,weak) IBOutlet UITextField *firstnameTextField;
@property(nonatomic,weak) IBOutlet UITextField *lastnameTextField;
@property(nonatomic,weak) IBOutlet UITextField *emailTextField;
@property(nonatomic,weak) IBOutlet UITextField *mobileTextField;
@property(nonatomic,weak) IBOutlet UITextField *passwordTextField;


-(IBAction)signUpAction:(id)sender;
@end
