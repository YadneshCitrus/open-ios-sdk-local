//
//  SignInViewController.m
//  SDKSandbox
//
//  Created by Mukesh Patil on 08/09/14.
//  Copyright (c) 2014 CitrusPay. All rights reserved.
//

#import "SignInViewController.h"
#import "CTSAlertView.h"
#import "TestParams.h"
#import "User.h"
#import "ChangePasswordViewController.h"

#define REGEX_EMAIL @"[A-Z0-9a-z._%+-]{3,}+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
#define REGEX_PASSWORD_LIMIT @"^.{8,16}$"
#define REGEX_PASSWORD @"[A-Za-z0-9!@#$%"@"^&*]{8,16}"

@interface SignInViewController ()

@property(strong) PayViewController *payViewController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
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
    
    self.payViewController = [[PayViewController alloc] initWithNibName:@"PayViewController" bundle:nil];
    self.payViewController.signOutDelegate = self;

    /**
     *  TestData
     *
     *  use testdata for SDKSandboxTestData applicatin Target
     */
#if defined (TESTDATA_VERSION)
    self.usernameTextField.text = TEST_EMAIL;
    self.passwordTextField.text = TEST_PASSWORD;
#else
    NSString *username = [self getLastUser];
    self.usernameTextField.text = username;
#endif

    [self setupTextFieldValidation];

    //
    [self initialize];
}

-(void)setupTextFieldValidation{
    [self.usernameTextField addRegx:REGEX_EMAIL withMsg:@"Enter valid email."];
    [self.passwordTextField addRegx:REGEX_PASSWORD withMsg:@"8 to 16 with at least one alphabet and one "
     @"number. Special characters allowed - (! @ # $ % " @"^ & *)."];
    [self.passwordTextField addRegx:REGEX_PASSWORD_LIMIT withMsg:@"8 to 16 with at least one alphabet and one "
     @"number. Special characters allowed - (! @ # $ % " @"^ & *)." tag:2 location:16];
}


//
- (void)initialize {
    authLayer = [[CTSAuthLayer alloc] init];
//    authLayer.delegate = self;
    
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
    [alertView didPresentLoadingAlertView:@"Checking user" withActivity:YES];
    
    if([self.usernameTextField validate] & [self.passwordTextField validate])
    {
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
                                   [alertView dismissLoadingAlertView:YES];
                                   if (error == nil) {
                                       self.payViewController.payType = MEMBER_PAY_TYPE;
                                       [self.navigationController pushViewController:self.payViewController animated:YES];
                                       [self setLastUser];
                                   }else{
                                       UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[error.userInfo valueForKey:@"NSLocalizedDescription"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                                       [alertView show];
                                   }
                                });
                           }];
    }else{
        // Update the UI
        [alertView dismissLoadingAlertView:YES];
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Information" message:@"Please enter valid input" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
    }
}



-(IBAction)resetPasswordAction:(id)sender
{
    if ([self.usernameTextField isFirstResponder]) {
        [self.usernameTextField resignFirstResponder];
    }else if ([self.passwordTextField isFirstResponder]) {
        [self.passwordTextField resignFirstResponder];
    }

    if ([self.usernameTextField.text length] != 0) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Reset Password?" message:[NSString stringWithFormat:@"An email will be sent to %@",self.usernameTextField.text] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok",nil];
        alertView.tag = 100;
        [alertView show];
    }else{
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Information" message:@"Username field can't be blank!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
    }
}


-(IBAction)changePasswordAction:(id)sender
{
    if ([self.usernameTextField isFirstResponder]) {
        [self.usernameTextField resignFirstResponder];
    }else if ([self.passwordTextField isFirstResponder]) {
        [self.passwordTextField resignFirstResponder];
    }

    ChangePasswordViewController* changePasswordViewController = [[ChangePasswordViewController alloc] initWithNibName:@"ChangePasswordViewController" bundle:nil];
    [self.navigationController pushViewController:changePasswordViewController animated:YES];
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
    [alertView didPresentLoadingAlertView:@"Requesting" withActivity:YES];
    
    // Perform long running process
    if ([self.usernameTextField.text length] != 0 && [self.passwordTextField.text length] != 0) {
        //
        [authLayer requestResetPassword:self.usernameTextField.text
                      completionHandler:^(NSError* error) {
                          LogTrace(@"error %@ ", error);
                          
                          // Update the UI
                          [alertView dismissLoadingAlertView:YES];
                          if (error == nil) {
                              UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Information" message:@"An email sent successfully" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                              [alertView show];
                          }
                      }];
    }
}

#pragma mark - SignOutDelegate delegates

- (void)signOutDelegate
{
    if ([authLayer signOut]) {
        [self.navigationController popToRootViewControllerAnimated:YES];
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        // Store the data
        self.managedObjectContext = appDelegate.managedObjectContext;
        [self deleteAllObjects:@"CTSPaymentOption"];
    }
}

- (void) deleteAllObjects: (NSString *) entityDescription  {
    // Doing something on the main thread
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        @try {
            // Perform long running process
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity = [NSEntityDescription entityForName:entityDescription inManagedObjectContext:_managedObjectContext];
            [fetchRequest setEntity:entity];
            
            NSError *error;
            NSArray *items = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
            
            for (NSManagedObject *managedObject in items) {
                [_managedObjectContext deleteObject:managedObject];
                NSLog(@"%@ object deleted",entityDescription);
            }
            if (![_managedObjectContext save:&error]) {
                NSLog(@"Error deleting %@ - error:%@",entityDescription,error);
            }

        }
        @catch (NSException *exception) {
            LogTrace(@"NSException %@",exception);
        }
    });
}

#pragma mark - UITextField delegates

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


- (void)setLastUser {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:self.usernameTextField.text forKey:LAST_USER];
    [prefs synchronize];
}

- (NSString*)getLastUser {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    return [prefs valueForKey:LAST_USER];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
