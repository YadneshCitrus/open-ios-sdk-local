//
//  HomeViewController.m
//  SDKSandbox
//
//  Created by Mukesh Patil on 05/09/14.
//  Copyright (c) 2014 CitrusPay. All rights reserved.
//

#import "HomeViewController.h"
#import "SignInViewController.h"
#import "SignUpViewController.h"
#import "PayViewController.h"
#import "TestParams.h"
#import "GuestPayViewController.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

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
    self.title = @"Home";
}




-(IBAction)signUpAction:(id)sender
{
    SignUpViewController* signUpViewController = [[SignUpViewController alloc] initWithNibName:@"SignUpViewController" bundle:nil];
    [self.navigationController pushViewController:signUpViewController animated:YES];
}

//
-(IBAction)signInAction:(id)sender
{
    SignInViewController* signInViewController = [[SignInViewController alloc] initWithNibName:@"SignInViewController" bundle:nil];
    [self.navigationController pushViewController:signInViewController animated:YES];
}

//
-(IBAction)guestPayAction:(id)sender
{
    GuestPayViewController* guestPayViewController = [[GuestPayViewController alloc] initWithNibName:@"GuestPayViewController" bundle:nil];
    guestPayViewController.payType = GUEST_PAY_TYPE;
    [self.navigationController pushViewController:guestPayViewController animated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
