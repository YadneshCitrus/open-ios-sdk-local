//
//  CardPayViewController.h
//  SDKSandbox
//
//  Created by Mukesh Patil on 08/09/14.
//  Copyright (c) 2014 CitrusPay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CitrusSdk.h"
#import "CTSTextFieldValidator.h"

@interface CardPayViewController : UIViewController <CTSPaymentProtocol, CTSProfileProtocol,
                                                        UIWebViewDelegate>
{
    IBOutlet __weak CTSTextFieldValidator *cardNumberTextField;
    IBOutlet __weak CTSTextFieldValidator *expiryDateTextField;
    IBOutlet __weak CTSTextFieldValidator *CVVNumberTextField;
    IBOutlet __weak CTSTextFieldValidator *cardHolderNameTextField;
    IBOutlet __weak UIImageView *cardSchemeImage;

    CTSPaymentLayer* paymentlayerinfo;
    CTSContactUpdate* contactInfo;
    CTSUserAddress* addressInfo;
    CTSProfileLayer* profileLayer;
    CTSProfileContactRes* contactSavedResponse;

    UIViewController *rootController;
    NSString *cardType;
    NSString *payType;
    NSString* mLastInput;
}
@property(nonatomic,weak) IBOutlet CTSTextFieldValidator *cardNumberTextField;
@property(nonatomic,weak) IBOutlet CTSTextFieldValidator *expiryDateTextField;
@property(nonatomic,weak) IBOutlet CTSTextFieldValidator *CVVNumberTextField;
@property(nonatomic,weak) IBOutlet CTSTextFieldValidator *cardHolderNameTextField;

@property(nonatomic,weak) IBOutlet UIImageView *cardSchemeImage;

@property(nonatomic,strong) UIViewController *rootController;

@property(nonatomic,strong) NSString *cardType;
@property(nonatomic,strong) NSString *payType;
@property(nonatomic, strong) NSString* mLastInput;

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

-(IBAction)textfieldTextchange:(id)sender;
@end
