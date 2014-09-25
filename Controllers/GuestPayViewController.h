//
//  GuestPayViewController.h
//  SDKSandbox
//
//  Created by Mukesh Patil on 11/09/14.
//  Copyright (c) 2014 CitrusPay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GuestPayViewController : UIViewController
{
    IBOutlet UIButton *netBankingButton;
    IBOutlet UIButton *debitCardButton;
    IBOutlet UIButton *creditCardButton;
    NSString *payType;
}
@property (strong, nonatomic) NSString *payType;

/**
 Use to perform net banking
 *
 *  @param dynamic object sender
 */
-(IBAction)netBankingAction:(id)sender;

/**
 Use to perform debit card
 *
 *  @param dynamic object sender
 */
-(IBAction)debitCardAction:(id)sender;

/**
 Use to perform credit card
 *
 *  @param dynamic object sender
 */
-(IBAction)creditCardAction:(id)sender;

@end
