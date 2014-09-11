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
    CTSContactUpdate* contactInfo;
    CTSUserAddress* addressInfo;
        
    IBOutlet __weak UIButton *selectBankButton;
    UIViewController *rootController;
    NSString *payType;
}
@property(nonatomic,strong) UIViewController *rootController;
@property(nonatomic,strong) NSString *payType;
-(IBAction)selectBankAction:(id)sender;
-(IBAction)netBankingAction:(id)sender;
@end
