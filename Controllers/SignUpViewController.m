//
//  SignUpViewController.m
//  SDKSandbox
//
//  Created by Mukesh Patil on 08/09/14.
//  Copyright (c) 2014 CitrusPay. All rights reserved.
//

#import "SignUpViewController.h"
#import "PayViewController.h"
#import "CTSAlertView.h"
#import "TestParams.h"

@interface SignUpViewController ()

@end

@implementation SignUpViewController
@synthesize emailTextField, mobileTextField, passwordTextField, firstnameTextField, lastnameTextField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Sign Up";
    
    
    // Test data
    self.emailTextField.text = TEST_EMAIL;
    self.mobileTextField.text = TEST_MOBILE;
    self.passwordTextField.text = TEST_PASSWORD;

    [self initialize];
}


//
- (void)initialize {
    authLayer = [[CTSAuthLayer alloc] init];
//    authLayer.delegate = self;
    
    profileLayer = [[CTSProfileLayer alloc] init];
    profileLayer.delegate = self;
}

-(IBAction)signUpAction:(id)sender
{
    if ([self.emailTextField isFirstResponder]) {
        [self.emailTextField resignFirstResponder];
    }else if ([self.mobileTextField isFirstResponder]) {
        [self.mobileTextField resignFirstResponder];
    }else if ([self.emailTextField isFirstResponder]) {
        [self.passwordTextField resignFirstResponder];
    }
    
    //
    CTSAlertView* alertView = [[CTSAlertView alloc] init];
    [alertView createProgressionAlertWithMessage:@"Checking user" withActivity:YES];
    
    
    if ([self.emailTextField.text length] != 0 && [self.mobileTextField.text length] != 0 && [self.passwordTextField.text length] != 0) {
        //
        [authLayer requestSignUpWithEmail:self.emailTextField.text
                                   mobile:self.mobileTextField.text
                                 password:self.passwordTextField.text
                        completionHandler:^(NSString* userName,
                                            NSString* token,
                                            NSError* error) {
                            LogTrace(@"userName %@ ", userName);
                            LogTrace(@"token %@ ", token);
                            LogTrace(@"error %@ ", error);
                            
                            // Update the UI
                            [alertView hideCTSAlertView:YES];
                            
                            if (error == nil) {
                                PayViewController* payViewController = [[PayViewController alloc] initWithNibName:@"PayViewController" bundle:nil];
                                [self.navigationController pushViewController:payViewController animated:YES];
                                [self updateContactInformation];
                            }else{
                                UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:error.description delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                                [alertView show];
                            }
                        }];
    }else{
        // Update the UI
        [alertView hideCTSAlertView:YES];
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Information" message:@"Input field can't be blank!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
    }
}


- (void)updateContactInformation {
    CTSContactUpdate* contactUpdate = [[CTSContactUpdate alloc] init];
    contactUpdate.firstName = self.firstnameTextField.text;
    contactUpdate.lastName = self.lastnameTextField.text;
    contactUpdate.mobile = self.mobileTextField.text;
    contactUpdate.email = self.emailTextField.text;

    [profileLayer
     updateContactInformation:contactUpdate
     withCompletionHandler:^(NSError* error) {
         [profileLayer requestContactInformationWithCompletionHandler:nil];
     }];
}



#pragma mark - UITextField delegates

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
