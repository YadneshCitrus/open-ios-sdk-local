//
//  PayViewController.h
//  SDKSandbox
//
//  Created by Mukesh Patil on 05/09/14.
//  Copyright (c) 2014 CitrusPay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PayViewController : UIViewController
{
    IBOutlet UIButton *savedOptionButton;
    IBOutlet UIButton *netBankingButton;
    IBOutlet UIButton *debitCardButton;
    IBOutlet UIButton *creditCardButton;
    NSString *payType;
}
@property(nonatomic,strong) NSString *payType;
-(IBAction)savedOptionAction:(id)sender;

-(IBAction)netBankingAction:(id)sender;

-(IBAction)debitCardAction:(id)sender;

-(IBAction)creditCardAction:(id)sender;

@end
