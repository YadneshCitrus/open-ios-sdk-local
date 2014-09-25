//
//  SignUpViewController.m
//  SDKSandbox
//
//  Created by Mukesh Patil on 08/09/14.
//  Copyright (c) 2014 CitrusPay. All rights reserved.
//

#import "SignUpViewController.h"
#import "PayViewController.h"
#import "UIUtility.h"
#import "TestParams.h"

#define REGEX_USER_NAME_LIMIT @"^.{3,10}$"
#define REGEX_USER_NAME @"[A-Za-z0-9]{3,10}"
#define REGEX_EMAIL @"[A-Z0-9a-z._%+-]{3,}+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
#define REGEX_PASSWORD_LIMIT @"^.{8,16}$"
#define REGEX_PASSWORD @"[A-Za-z0-9!@#$%"@"^&*]{8,16}"
#define REGEX_PHONE_DEFAULT @"[0-9]{3}\\-[0-9]{3}\\-[0-9]{4}"
#define REGEX_PHONE_DEFAULT_LIMIT @"^.{12,12}$"

@interface SignUpViewController ()
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property(strong) PayViewController *payViewController;

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

    self.payViewController = [[PayViewController alloc] initWithNibName:@"PayViewController" bundle:nil];
    self.payViewController.signOutDelegate = self;

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
    
    [UIUtility didPresentLoadingAlertView:@"Checking user" withActivity:YES];
    
    
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
                                    [UIUtility dismissLoadingAlertView:YES];
                                    
                                    [UIUtility didPresentInfoAlertView:@"Email Id is already registered as a citrus member. You can do Sign In directly."];

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
                                                        [UIUtility dismissLoadingAlertView:YES];
                                                        
                                                        if (error == nil) {
                                                            self.payViewController.payType = MEMBER_PAY_TYPE;
                                                            [self.navigationController pushViewController:self.payViewController animated:YES];
                                                            [self updateContactInformation];
                                                        }else{
                                                            [UIUtility didPresentErrorAlertView:error];
                                                        }
                                                    });
                                                    
                                                }];
                            }
                        }];
        
    }else{
        // Update the UI
        [UIUtility dismissLoadingAlertView:YES];
        
        [UIUtility didPresentInfoAlertView:@"Please enter valid input"];
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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
