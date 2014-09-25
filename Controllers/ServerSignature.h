//
//  ServerSignature.h
//  CTS iOS Sdk
//
//  Created by Yadnesh Wankhede on 02/09/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import <Foundation/Foundation.h>
#define SIGNATURE_URL @"http://sandbox.citruspay.com/namo/sign.php"

@interface ServerSignature : NSObject
+ (NSString*)getSignatureFromServerTxnId:(NSString*)txnId amount:(NSString*)amt;
@end
