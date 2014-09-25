//
//  PayViewController.h
//  SDKSandbox
//
//  Created by Mukesh Patil on 05/09/14.
//  Copyright (c) 2014 CitrusPay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CitrusSdk.h"
#import "SavedOptionsViewController.h"


@protocol SignOutDelegate <NSObject>
@optional
- (void)signOutDelegate;
@end

@interface PayViewController : UIViewController <SavedOptionsDelegate>
{
    IBOutlet UIButton *savedOptionButton;
    IBOutlet UIButton *netBankingButton;
    IBOutlet UIButton *debitCardButton;
    IBOutlet UIButton *creditCardButton;
    NSString *payType;
    __weak id <SignOutDelegate> signOutDelegate;
}
@property(nonatomic,strong) NSString *payType;
@property (nonatomic, weak) id <SignOutDelegate> signOutDelegate;

/**
 Use to perform saved option
 *
 *  @param dynamic object sender
 */
-(IBAction)savedOptionAction:(id)sender;

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
