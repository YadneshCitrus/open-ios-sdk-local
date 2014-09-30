//
//  NetBankingViewController.h
//  SDKSandbox
//
//  Created by Mukesh Patil on 08/09/14.
//  Copyright (c) 2014 CitrusPay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CitrusSdk.h"

@interface NetBankingViewController : UIViewController <CTSPaymentProtocol,
                                                        CTSProfileProtocol,
                                                        UIPickerViewDelegate,
                                                        UIPickerViewDataSource>
{
    CTSPaymentLayer* paymentlayerinfo;
    CTSContactUpdate* aContactInfo;
    CTSUserAddress* addressInfo;
    CTSProfileLayer* profileLayer;
    CTSProfileContactRes* contactSavedResponse;
    
    IBOutlet __weak UIButton *selectBankButton;
    IBOutlet __weak UIActivityIndicatorView *activityIndicatorView;
    UIViewController *rootController;
    NSString *payType;
    NSString *issuerCode;
}
@property(nonatomic,strong) UIViewController *rootController;
@property(nonatomic,strong) NSString *payType;
@property(nonatomic,strong) NSString *issuerCode;

/**
 *  called when user request to get bank type for net banking payment as a user or guest
 *
 *  @param dynamic object sender
 */
-(IBAction)selectBankAction:(id)sender;

/**
 *  called when user request to make net banking payment as a user or guest
 *
 *  @param dynamic object sender
 */
-(IBAction)netBankingAction:(id)sender;
@end
