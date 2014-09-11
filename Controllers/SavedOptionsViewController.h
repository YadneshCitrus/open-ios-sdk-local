//
//  SavedOptionsViewController.h
//  SDKSandbox
//
//  Created by Mukesh Patil on 05/09/14.
//  Copyright (c) 2014 CitrusPay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface SavedOptionsViewController : UIViewController
{
    IBOutlet __weak UITableView *tableView;
}
@property(nonatomic,weak) IBOutlet UITableView *tableView;
@property (strong, nonatomic) AppDelegate *appDelegate;

@end
