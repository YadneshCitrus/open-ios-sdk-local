//
//  CTSAlertView.h
//  SDKSandbox
//
//  Created by Mukesh Patil on 05/09/14.
//  Copyright (c) 2014 CitrusPay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CTSAlertView : UIAlertView

-(void)hideCTSAlertView:(BOOL)activity;
-(void)createProgressionAlertWithMessage:(NSString *)message withActivity:(BOOL)activity;
@end
