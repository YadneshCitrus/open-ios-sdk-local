//
//  ServerSignature.h
//  CTS iOS Sdk
//
//  Created by Yadnesh Wankhede on 02/09/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import <Foundation/Foundation.h>
#define SIGNATURE_URL @"http://sandbox.citruspay.com/namo/sign.php"
//#define SIGNATURE_URL                                   \
//  @"http://kangaroocabs.renewinfosys.in/renew/mycodes/" \
//  @"citruspay_sign_ios_api.php"

//#define SIGNATURE_URL @"http://localhost:8888/sign.php"

@interface ServerSignature : NSObject
+ (NSString*)getSignatureFromServerTxnId:(NSString*)txnId amount:(NSString*)amt;
@end
