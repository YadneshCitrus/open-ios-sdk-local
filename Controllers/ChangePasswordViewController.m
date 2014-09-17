//
//  ChangePasswordViewController.m
//  SDKSandbox
//
//  Created by Mukesh Patil on 16/09/14.
//  Copyright (c) 2014 CitrusPay. All rights reserved.
//

#import "ChangePasswordViewController.h"

@interface ChangePasswordViewController ()

@end

@implementation ChangePasswordViewController
@synthesize usernameTextField, oldPasswordTextField, passwordTextField;

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
    /**
     *  TestData
     *
     *  use testdata for SDKSandboxTestData applicatin Target
     */
#if defined (TESTDATA_VERSION)
    self.usernameTextField.text = TEST_EMAIL;
    self.oldPasswordTextField.text = TEST_PASSWORD;
    self.passwordTextField.text = TEST_PASSWORD;
#else
    NSString *username = [self getLastUser];
    self.usernameTextField.text = username;
#endif
}

-(IBAction)changePasswordAction:(id)sender
{
    [self requestResetPassword];
}

- (NSString*)getLastUser {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    return [prefs valueForKey:LAST_USER];
}


-(void)requestResetPassword
{
    CTSAlertView* alertView = [[CTSAlertView alloc] init];
    [alertView didPresentLoadingAlertView:@"Requesting" withActivity:YES];
    
    if ([self.usernameTextField.text length] != 0 && [self.oldPasswordTextField.text length] != 0 && [self.passwordTextField.text length] != 0) {
        [authLayer requestChangePasswordUserName:self.usernameTextField.text
                               oldPassword:(NSString*)self.oldPasswordTextField.text
                               newPassword:(NSString*)self.passwordTextField.text
                      completionHandler:^(NSError* error) {
                          LogTrace(@"error %@ ", error);
                          
                          dispatch_async(dispatch_get_main_queue(), ^{
                              // Update the UI
                              [alertView dismissLoadingAlertView:YES];
                              if (error == nil) {
                                  UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Information" message:@"Your password has been updated successfully! " delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                                  [alertView show];
#if !defined (TESTDATA_VERSION)
                                  if ([self.oldPasswordTextField text]) {
                                      self.oldPasswordTextField.text = @"";
                                  }
                                  if ([self.passwordTextField text]) {
                                      self.passwordTextField.text = @"";
                                  }
#endif
                              }
                          });
                      }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
