//
//  CardPayViewController.h
//  SDKSandbox
//
//  Created by Mukesh Patil on 08/09/14.
//  Copyright (c) 2014 CitrusPay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CitrusSdk.h"

@interface CardPayViewController : UIViewController <CTSPaymentProtocol, CTSProfileProtocol,
                                                        UIWebViewDelegate>
{
    IBOutlet __weak UITextField *cardNumberTextField;
    IBOutlet __weak UITextField *expiryDateTextField;
    IBOutlet __weak UITextField *CVVNumberTextField;
    IBOutlet __weak UITextField *cardHolderNameTextField;
    IBOutlet __weak UIImageView *cardSchemeImage;

    CTSPaymentLayer* paymentlayerinfo;
    CTSContactUpdate* contactInfo;
    CTSUserAddress* addressInfo;
    CTSProfileLayer* profileLayer;
    CTSProfileContactRes* contactSavedResponse;

    UIViewController *rootController;
    NSString *cardType;
    NSString *payType;
}
@property(nonatomic,weak) IBOutlet UITextField *cardNumberTextField;
@property(nonatomic,weak) IBOutlet UITextField *expiryDateTextField;
@property(nonatomic,weak) IBOutlet UITextField *CVVNumberTextField;
@property(nonatomic,weak) IBOutlet UITextField *cardHolderNameTextField;

@property(nonatomic,weak) IBOutlet UIImageView *cardSchemeImage;

@property(nonatomic,strong) UIViewController *rootController;

@property(nonatomic,strong) NSString *cardType;
@property(nonatomic,strong) NSString *payType;

/**
 *  called when user request to make payment as a user or guest
 *
 *  @param dynamic object sender
 */
-(IBAction)cardAction:(id)sender;


/**
 *  called when user navigate from card payment view to other
 *
 */
- (void)dismissTextField;


/**
 *  called when user come to card payment view
 *
 */
-(void)setTestData;
@end
