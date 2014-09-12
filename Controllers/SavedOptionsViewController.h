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

@interface SavedOptionsViewController : UIViewController <CTSPaymentProtocol>
{
    IBOutlet __weak UITableView *tableView;
    CTSProfileLayer* profileLayer;
    
    CTSProfilePaymentRes* paymentSavedResponse;
}
@property(nonatomic,weak) IBOutlet UITableView *tableView;

@end
