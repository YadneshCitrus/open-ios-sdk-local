//
//  SavedOptionsViewController.h
//  SDKSandbox
//
//  Created by Mukesh Patil on 05/09/14.
//  Copyright (c) 2014 CitrusPay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "CitrusSdk.h"
#import "CTSTextFieldValidator.h"

@protocol SavedOptionsDelegate <NSObject>
@optional
- (void)navigateToTargetController:(NSString*)redirectURL selectedPaymentOption:(NSString*)selectedPaymentOption;
@end

@interface SavedOptionsViewController : UIViewController <CTSProfileProtocol,
                                                            CTSPaymentProtocol,
                                                            CTSProfileProtocol,
                                                            UITextFieldDelegate>
{
    IBOutlet __weak UITableView *tableView;
    UIViewController *rootController;
    CTSPaymentOption *selectedPaymentOption;
    
    CTSProfileLayer* profileLayer;
    CTSPaymentLayer* paymentlayerinfo;
    CTSContactUpdate* contactInfo;
    CTSUserAddress* addressInfo;
    CTSProfilePaymentRes* paymentSavedResponse;
    
    CTSTextFieldValidator *activeTextField;
    __weak id <SavedOptionsDelegate> savedOptionsDelegate;
}
@property(nonatomic,weak) IBOutlet UITableView *tableView;
@property(nonatomic,strong) UIViewController *rootController;
@property(nonatomic,strong) CTSPaymentOption *selectedPaymentOption;
@property(nonatomic,strong) CTSTextFieldValidator *activeTextField;
@property (nonatomic, weak) id <SavedOptionsDelegate> savedOptionsDelegate;

@end
