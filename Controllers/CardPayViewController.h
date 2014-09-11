//
//  CardPayViewController.h
//  SDKSandbox
//
//  Created by Mukesh Patil on 08/09/14.
//  Copyright (c) 2014 CitrusPay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CitrusSdk.h"

@interface CardPayViewController : UIViewController <CTSPaymentProtocol,
                                                        UIWebViewDelegate>
{
    IBOutlet __weak UITextField *cardNumberTextField;
    IBOutlet __weak UITextField *expiryDateTextField;
    IBOutlet __weak UITextField *CVVNumberTextField;
    IBOutlet __weak UITextField *cardHolderNameTextField;
    
    CTSPaymentLayer* paymentlayerinfo;
    CTSContactUpdate* contactInfo;
    CTSUserAddress* addressInfo;
    
    UIViewController *rootController;
    NSString *cardType;
    NSString *payType;
}
@property(nonatomic,weak) IBOutlet UITextField *cardNumberTextField;
@property(nonatomic,weak) IBOutlet UITextField *expiryDateTextField;
@property(nonatomic,weak) IBOutlet UITextField *CVVNumberTextField;
@property(nonatomic,weak) IBOutlet UITextField *cardHolderNameTextField;
@property(nonatomic,strong) UIViewController *rootController;
@property(nonatomic,strong) NSString *cardType;
@property(nonatomic,strong) NSString *payType;

-(IBAction)cardAction:(id)sender;
@end
