//
//  GuestPayViewController.m
//  SDKSandbox
//
//  Created by Mukesh Patil on 11/09/14.
//  Copyright (c) 2014 CitrusPay. All rights reserved.
//

#import "GuestPayViewController.h"
#import "NetBankingViewController.h"
#import "CardPayViewController.h"
#import "TestParams.h"

@interface GuestPayViewController ()

@property(strong) NetBankingViewController *netBankingViewController;
@property(strong) CardPayViewController *cardPayViewController;

@end

@implementation GuestPayViewController
@synthesize payType;

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
    
    self.title = @"Guest Pay";

    [self netBankingAction:nil];
}


-(IBAction)netBankingAction:(id)sender
{
    UIButton *button = (UIButton *)sender;
    if (button) {
        [button setBackgroundImage:[UIImage imageNamed:@"buttonbackground.png"] forState:UIControlStateNormal];
    }else{
        [netBankingButton setBackgroundImage:[UIImage imageNamed:@"buttonbackground.png"] forState:UIControlStateNormal];
    }
    
    //
    [debitCardButton setBackgroundImage:nil forState:UIControlStateNormal];
    [creditCardButton setBackgroundImage:nil forState:UIControlStateNormal];
    
    if ([self.cardPayViewController.view superview]) {
        [self.cardPayViewController dismissTextField];
        [self.cardPayViewController.view removeFromSuperview];
    }
    
    //
    self.netBankingViewController = [[NetBankingViewController alloc] initWithNibName:@"NetBankingViewController" bundle:nil];
    self.netBankingViewController.view.frame = CGRectMake(0.0f, 92.0f, 320, 448.0f);
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
    [creditCardButton setBackgroundImage:nil forState:UIControlStateNormal];
    
    //
    if ([self.netBankingViewController.view superview]) {
        [self.netBankingViewController.view removeFromSuperview];
    }
    
    
    //
    self.cardPayViewController = [[CardPayViewController alloc] initWithNibName:@"CardPayViewController" bundle:nil];
    self.cardPayViewController.view.frame = CGRectMake(0.0f, 92.0f, 320, 448.0f);
    self.cardPayViewController.cardType = DEBIT_CARD_TYPE;
    self.cardPayViewController.payType = self.payType;
    self.cardPayViewController.rootController = self;
    [self.view addSubview:self.cardPayViewController.view];
}

-(IBAction)creditCardAction:(id)sender
{
    UIButton *button = (UIButton *)sender;
    [button setBackgroundImage:[UIImage imageNamed:@"buttonbackground.png"] forState:UIControlStateNormal];
    
    //
    [netBankingButton setBackgroundImage:nil forState:UIControlStateNormal];
    [debitCardButton setBackgroundImage:nil forState:UIControlStateNormal];
    
    //
    if ([self.netBankingViewController.view superview]) {
        [self.netBankingViewController.view removeFromSuperview];
    }
    
    
    //
    self.cardPayViewController = [[CardPayViewController alloc] initWithNibName:@"CardPayViewController" bundle:nil];
    self.cardPayViewController.view.frame = CGRectMake(0.0f, 92.0f, 320, 448.0f);
    self.cardPayViewController.cardType = CREDIT_CARD_TYPE;
    self.cardPayViewController.payType = self.payType;
    self.cardPayViewController.rootController = self;
    [self.view addSubview:self.cardPayViewController.view];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
