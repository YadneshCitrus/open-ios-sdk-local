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

#define REGEX_USER_NAME_LIMIT @"^.{3,10}$"
#define REGEX_USER_NAME @"[A-Za-z0-9]{3,10}"
#define REGEX_EMAIL @"[A-Z0-9a-z._%+-]{3,}+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
#define REGEX_PASSWORD_LIMIT @"^.{8,16}$"
#define REGEX_PASSWORD @"[A-Za-z0-9!@#$%"@"^&*]{8,16}"
#define REGEX_PHONE_DEFAULT @"[0-9]{3}\\-[0-9]{3}\\-[0-9]{4}"
#define REGEX_PHONE_DEFAULT_LIMIT @"^.{12,12}$"

@interface SignUpViewController ()

@end

@implementation SignUpViewController
@synthesize firstnameTextField, lastnameTextField, emailTextField, mobileTextField, passwordTextField, confirmPasswordTextField;

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

    [self setupTextFieldValidation];

    [self initialize];
}


-(void)setupTextFieldValidation{
    [self.firstnameTextField addRegx:REGEX_USER_NAME_LIMIT withMsg:@"User name charaters limit should be come between 3-10" tag:1 location:10];
    [self.firstnameTextField addRegx:REGEX_USER_NAME withMsg:@"Only alpha numeric characters are allowed."];
    self.firstnameTextField.isMandatory = NO;
    
    [self.lastnameTextField addRegx:REGEX_USER_NAME_LIMIT withMsg:@"User name charaters limit should be come between 3-10" tag:2 location:10];
    [self.lastnameTextField addRegx:REGEX_USER_NAME withMsg:@"Only alpha numeric characters are allowed."];
    self.lastnameTextField.isMandatory = NO;
    
    [self.emailTextField addRegx:REGEX_EMAIL withMsg:@"Enter valid email."];
    
    [self.mobileTextField addRegx:REGEX_PHONE_DEFAULT withMsg:@"Phone number must be in proper format (eg. ###-###-####)"];
    [self.mobileTextField addRegx:REGEX_PHONE_DEFAULT_LIMIT withMsg:@"Phone number charaters limit should be come 10" tag:4 location:12 type:MOBILE_TYPE];

    [self.passwordTextField addRegx:REGEX_PASSWORD withMsg:@"Password must contain alpha numeric characters."];
    [self.passwordTextField addRegx:REGEX_PASSWORD_LIMIT withMsg:@"8 to 16 with at least one alphabet and one "
     @"number. Special characters allowed - (! @ # $ % " @"^ & *)." tag:5 location:16];
    
    [self.confirmPasswordTextField addConfirmValidationTo:self.passwordTextField withMsg:@"Confirm password didn't match."];
}

//
- (void)initialize {
    authLayer = [[CTSAuthLayer alloc] init];
    authLayer.delegate = self;
    
    profileLayer = [[CTSProfileLayer alloc] init];
    profileLayer.delegate = self;
}

-(IBAction)signUpAction:(id)sender
{
    if ([self.firstnameTextField isFirstResponder]) {
        [self.firstnameTextField resignFirstResponder];
    }else if ([self.lastnameTextField isFirstResponder]) {
        [self.lastnameTextField resignFirstResponder];
    }else if ([self.emailTextField isFirstResponder]) {
        [self.emailTextField resignFirstResponder];
    }else if ([self.mobileTextField isFirstResponder]) {
        [self.mobileTextField resignFirstResponder];
    }else if ([self.passwordTextField isFirstResponder]) {
        [self.passwordTextField resignFirstResponder];
    }
    
    //
    CTSAlertView* alertView = [[CTSAlertView alloc] init];
    [alertView didPresentLoadingAlertView:@"Checking user" withActivity:YES];
    
    
    if([self.firstnameTextField validate] & [self.lastnameTextField validate] & [self.emailTextField validate] & [self.mobileTextField validate] & [self.passwordTextField validate])
    {
        //
        [authLayer requestIsUserCitrusMemberUsername:self.emailTextField.text
                        completionHandler:^(BOOL isUserCitrusMember,
                                            NSError* error) {
                            LogTrace(@"isUserCitrusMember %i ", isUserCitrusMember);
                            LogTrace(@"error %@ ", error);
                            
                            
                            if (isUserCitrusMember && error == nil) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    // Update the UI
                                    [alertView dismissLoadingAlertView:YES];
                                    
                                    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Information" message:@"Email Id is already registered as a citrus member. You can do Sign In directly." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                                    [alertView show];
                                    
                                    if ([self.firstnameTextField text]) {
                                        self.firstnameTextField.text = @"";
                                    }
                                    if ([self.lastnameTextField text]) {
                                        self.lastnameTextField.text = @"";
                                    }
                                    if ([self.emailTextField text]) {
                                        self.emailTextField.text = @"";
                                    }
                                    if ([self.mobileTextField text]) {
                                        self.mobileTextField.text = @"";
                                    }
                                    if ([self.passwordTextField text]) {
                                        self.passwordTextField.text = @"";
                                    }

                                });
                            }else{
                                //
                                [authLayer requestSignUpWithEmail:self.emailTextField.text
                                                           mobile:[self.mobileTextField.text stringByReplacingOccurrencesOfString:@"-" withString:@""]
                                                         password:self.passwordTextField.text
                                                completionHandler:^(NSString* userName,
                                                                    NSString* token,
                                                                    NSError* error) {
                                                    LogTrace(@"userName %@ ", userName);
                                                    LogTrace(@"token %@ ", token);
                                                    LogTrace(@"error %@ ", error);
                                                    
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        
                                                        // Update the UI
                                                        [alertView dismissLoadingAlertView:YES];
                                                        
                                                        if (error == nil) {
                                                            PayViewController* payViewController = [[PayViewController alloc] initWithNibName:@"PayViewController" bundle:nil];
                                                            [self.navigationController pushViewController:payViewController animated:YES];
                                                            [self updateContactInformation];
                                                        }else{
                                                            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[error.userInfo valueForKey:@"NSLocalizedDescription"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                                                            [alertView show];
                                                        }
                                                    });
                                                    
                                                }];
                            }
                        }];
        
    }else{
        // Update the UI
        [alertView dismissLoadingAlertView:YES];
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Information" message:@"Please enter valid input" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
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

#pragma mark - profile layer delegates

- (void)profile:(CTSProfileLayer*)profile
didReceiveContactInfo:(CTSProfileContactRes*)contactInfo
          error:(NSError*)error {
    LogTrace(@"didReceiveContactInfo");
    // LogTrace(@"contactInfo %@", contactInfo);
    //[contactInfo logProperties];
    LogTrace(@"contactInfo %@", error);
}
- (void)profile:(CTSProfileLayer*)profile
didReceivePaymentInformation:(CTSProfilePaymentRes*)paymentInfo
          error:(NSError*)error {
    if (error == nil) {
        LogTrace(@" paymentInfo.type %@", paymentInfo.type);
        LogTrace(@" paymentInfo.defaultOption %@", paymentInfo.defaultOption);
        
//        for (CTSPaymentOption* option in paymentInfo.paymentOptions) {
//            [option logProperties];
//        }
        
//        paymentSavedResponse = paymentInfo;
    } else {
        LogTrace(@"error received %@", error);
    }
}

- (void)profile:(CTSProfileLayer*)profile
didUpdateContactInfoError:(NSError*)error {
}

- (void)profile:(CTSProfileLayer*)profile
didUpdatePaymentInfoError:(NSError*)error {
    LogTrace(@"didUpdatePaymentInfoError error %@ ", error);
    [profileLayer requestPaymentInformationWithCompletionHandler:nil];
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
