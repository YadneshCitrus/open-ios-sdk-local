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


@interface SignInViewController : UIViewController <CTSAuthenticationProtocol,
                                                    UIAlertViewDelegate,
                                                     SignOutDelegate>
{
    IBOutlet __weak UITextField *usernameTextField;
    IBOutlet __weak UITextField *passwordTextField;
    
    CTSAuthLayer* authLayer;
}
@property(nonatomic,weak) IBOutlet UITextField *usernameTextField;
@property(nonatomic,weak) IBOutlet UITextField *passwordTextField;

-(IBAction)signInAction:(id)sender;
-(IBAction)resetPasswordAction:(id)sender;
@end
