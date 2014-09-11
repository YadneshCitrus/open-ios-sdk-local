//
//  SignInViewController.m
//  SDKSandbox
//
//  Created by Mukesh Patil on 08/09/14.
//  Copyright (c) 2014 CitrusPay. All rights reserved.
//

#import "SignInViewController.h"
#import "PayViewController.h"
#import "CTSAlertView.h"
#import "TestParams.h"

@interface SignInViewController ()

@end

@implementation SignInViewController
@synthesize usernameTextField, passwordTextField;
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
    self.title = @"Sign In";
    
    // Test data
    self.usernameTextField.text = TEST_EMAIL;
    self.passwordTextField.text = TEST_PASSWORD;

    //
    [self initialize];
}


//
- (void)initialize {
    authLayer = [[CTSAuthLayer alloc] init];
    authLayer.delegate = self;
}


//
-(IBAction)signInAction:(id)sender
{
    if ([self.usernameTextField isFirstResponder]) {
        [self.usernameTextField resignFirstResponder];
    }else if ([self.passwordTextField isFirstResponder]) {
        [self.passwordTextField resignFirstResponder];
    }

    //
    CTSAlertView* alertView = [[CTSAlertView alloc] init];
    [alertView createProgressionAlertWithMessage:@"Checking user" withActivity:YES];

    // Doing something on the main thread
    dispatch_queue_t myQueue = dispatch_queue_create("My Queue",NULL);
    dispatch_async(myQueue, ^{
        // Perform long running process
        if ([self.usernameTextField.text length] != 0 && [self.passwordTextField.text length] != 0) {
            //
            [authLayer requestSigninWithUsername:self.usernameTextField.text
                                        password:self.passwordTextField.text
                               completionHandler:^(NSString* userName,
                                                   NSString* token,
                                                   NSError* error) {
                                   LogTrace(@"userName %@ ", userName);
                                   LogTrace(@"token %@ ", token);
                                   LogTrace(@"error %@ ", error);
                                   
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       // Update the UI
                                       [alertView hideCTSAlertView:YES];
                                       if (error == NULL) {
                                           PayViewController* payViewController = [[PayViewController alloc] initWithNibName:@"PayViewController" bundle:nil];
                                           payViewController.payType = MEMBER_PAY_TYPE;
                                           [self.navigationController pushViewController:payViewController animated:YES];
                                       }else{
                                           UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:error.description delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                                           [alertView show];
                                       }
                                   });
                               }];
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                // Update the UI
                [alertView hideCTSAlertView:YES];
                UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Information" message:@"Input field can't be blank!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alertView show];
            });
        }
    });
}



-(IBAction)resetPasswordAction:(id)sender
{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Reset Password?" message:[NSString stringWithFormat:@"An email will be sent to %@",self.usernameTextField.text] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok",nil];
    alertView.tag = 100;
    [alertView show];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 100 && buttonIndex == 1)
    {
        //Do something
        [self requestResetPassword];
    }
}


-(void)requestResetPassword
{
    //
    CTSAlertView* alertView = [[CTSAlertView alloc] init];
    [alertView createProgressionAlertWithMessage:@"Requesting" withActivity:YES];
    
    // Doing something on the main thread
    dispatch_queue_t myQueue = dispatch_queue_create("My Queue",NULL);
    dispatch_async(myQueue, ^{
        // Perform long running process
        if ([self.usernameTextField.text length] != 0 && [self.passwordTextField.text length] != 0) {
            //
            [authLayer requestResetPassword:self.usernameTextField.text
                          completionHandler:^(NSError* error) {
                              LogTrace(@"error %@ ", error);
                              
                              dispatch_async(dispatch_get_main_queue(), ^{
                                  // Update the UI
                                  [alertView hideCTSAlertView:YES];
                                  if (error == NULL) {
                                      UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Information" message:@"An email sent successfully" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                                      [alertView show];
                                  }
                              });
                          }];
        }
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
