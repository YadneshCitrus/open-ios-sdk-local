//
//  PayViewController.m
//  SDKSandbox
//
//  Created by Mukesh Patil on 05/09/14.
//  Copyright (c) 2014 CitrusPay. All rights reserved.
//

#import "PayViewController.h"
#import "NetBankingViewController.h"
#import "CardPayViewController.h"
#import "TestParams.h"
#import "WebViewViewController.h"

@interface PayViewController ()

@property(strong) SavedOptionsViewController *savedOptionsViewController;
@property(strong) NetBankingViewController *netBankingViewController;
@property(strong) CardPayViewController *cardPayViewController;

@end

@implementation PayViewController
@synthesize payType;
@synthesize signOutDelegate;

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
    
    self.navigationItem.hidesBackButton = YES;

    UIBarButtonItem* logoutButton = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self
                                                                    action:@selector(barButtonLogoutPressed:)];
    self.navigationItem.rightBarButtonItem = logoutButton;
    
    [self savedOptionAction:nil];
}


-(void)barButtonLogoutPressed:(id)sender{
    if (signOutDelegate != nil && [signOutDelegate respondsToSelector:@selector(signOutDelegate)]){
        [signOutDelegate signOutDelegate];
    }
}

-(IBAction)savedOptionAction:(id)sender
{
    UIButton *button = (UIButton *)sender;
    if (button) {
        [button setBackgroundImage:[UIImage imageNamed:@"buttonbackground.png"] forState:UIControlStateNormal];
    }else{
        [savedOptionButton setBackgroundImage:[UIImage imageNamed:@"buttonbackground.png"] forState:UIControlStateNormal];
    }
    
    //
    [netBankingButton setBackgroundImage:nil forState:UIControlStateNormal];
    [debitCardButton setBackgroundImage:nil forState:UIControlStateNormal];
    [creditCardButton setBackgroundImage:nil forState:UIControlStateNormal];
    
    //
    if ([self.netBankingViewController.view superview]) {
        [self.netBankingViewController.view removeFromSuperview];
    }
    if ([self.cardPayViewController.view superview]) {
        [self.cardPayViewController dismissTextField];
        [self.cardPayViewController.view removeFromSuperview];
    }

    
    //    
    self.savedOptionsViewController = [[SavedOptionsViewController alloc] initWithNibName:@"SavedOptionsViewController" bundle:nil];
    self.savedOptionsViewController.savedOptionsDelegate = self;

    self.savedOptionsViewController.view.frame = CGRectMake(0.0f, 92.0f, 320, 476.0f);
    [self.view addSubview:self.savedOptionsViewController.view];
    
}

#pragma mark - SavedOptionsDelegate delegates

- (void)navigateToTargetController:(NSString*)redirectURL
{
    WebViewViewController* webViewViewController = [[WebViewViewController alloc] init];
    webViewViewController.redirectURL = redirectURL;
    [self.navigationController pushViewController:webViewViewController animated:YES];
}

-(IBAction)netBankingAction:(id)sender
{
    UIButton *button = (UIButton *)sender;
    [button setBackgroundImage:[UIImage imageNamed:@"buttonbackground.png"] forState:UIControlStateNormal];
    
    //
    [savedOptionButton setBackgroundImage:nil forState:UIControlStateNormal];
    [debitCardButton setBackgroundImage:nil forState:UIControlStateNormal];
    [creditCardButton setBackgroundImage:nil forState:UIControlStateNormal];
    
    //
    if ([self.savedOptionsViewController.view superview]) {
        [self.savedOptionsViewController.view removeFromSuperview];
    }
    if ([self.cardPayViewController.view superview]) {
        [self.cardPayViewController dismissTextField];
        [self.cardPayViewController.view removeFromSuperview];
    }
    
    //
    self.netBankingViewController = [[NetBankingViewController alloc] initWithNibName:@"NetBankingViewController" bundle:nil];
    self.netBankingViewController.view.frame = CGRectMake(0.0f, 92.0f, 320, 476.0f);
    self.netBankingViewController.payType = self.payType;
    self.netBankingViewController.rootController = self;
    [self.view addSubview:self.netBankingViewController.view];
}

-(IBAction)debitCardAction:(id)sender
{
    UIButton *button = (UIButton *)sender;
    [button setBackgroundImage:[UIImage imageNamed:@"buttonbackground.png"] forState:UIControlStateNormal];
    
    //
    [netBankingButton setBackgroundImage:nil forState:UIControlStateNormal];
    [savedOptionButton setBackgroundImage:nil forState:UIControlStateNormal];
    [creditCardButton setBackgroundImage:nil forState:UIControlStateNormal];
    
    //
    if ([self.savedOptionsViewController.view superview]) {
        [self.savedOptionsViewController.view removeFromSuperview];
    }
    if ([self.netBankingViewController.view superview]) {
        [self.netBankingViewController.view removeFromSuperview];
    }

    
    //
    self.cardPayViewController = [[CardPayViewController alloc] initWithNibName:@"CardPayViewController" bundle:nil];
    self.cardPayViewController.view.frame = CGRectMake(0.0f, 92.0f, 320, 476.0f);
    self.cardPayViewController.cardType = MLC_PROFILE_PAYMENT_DEBIT_TYPE;
    self.cardPayViewController.payType = self.payType;
    self.cardPayViewController.rootController = self;
    [self.cardPayViewController setTestData];
    [self.view addSubview:self.cardPayViewController.view];
}

-(IBAction)creditCardAction:(id)sender
{
    UIButton *button = (UIButton *)sender;
    [button setBackgroundImage:[UIImage imageNamed:@"buttonbackground.png"] forState:UIControlStateNormal];
    
    //
    [netBankingButton setBackgroundImage:nil forState:UIControlStateNormal];
    [debitCardButton setBackgroundImage:nil forState:UIControlStateNormal];
    [savedOptionButton setBackgroundImage:nil forState:UIControlStateNormal];
    
    //
    if ([self.savedOptionsViewController.view superview]) {
        [self.savedOptionsViewController.view removeFromSuperview];
    }
    if ([self.netBankingViewController.view superview]) {
        [self.netBankingViewController.view removeFromSuperview];
    }

    
    //
    self.cardPayViewController = [[CardPayViewController alloc] initWithNibName:@"CardPayViewController" bundle:nil];
    self.cardPayViewController.view.frame = CGRectMake(0.0f, 92.0f, 320, 476.0f);
    self.cardPayViewController.cardType = MLC_PROFILE_PAYMENT_CREDIT_TYPE;
    self.cardPayViewController.payType = self.payType;
    self.cardPayViewController.rootController = self;
    [self.cardPayViewController setTestData];
    [self.view addSubview:self.cardPayViewController.view];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
