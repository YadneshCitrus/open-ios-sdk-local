//
//  ServerSignature.m
//  CTS iOS Sdk
//
//  Created by Yadnesh Wankhede on 02/09/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import "ServerSignature.h"

@implementation ServerSignature
+ (NSString*)getSignatureFromServerTxnId:(NSString*)txnId
                                  amount:(NSString*)amt {
    NSString* data =
    [NSString stringWithFormat:@"transactionId=%@&amount=%@", txnId, amt];
    NSURL* url = [[NSURL alloc]
                  initWithString:
                  [NSString
                   stringWithFormat:SIGNATURE_URL]];
    NSMutableURLRequest* urlReq = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlReq setHTTPBody:[data dataUsingEncoding:NSUTF8StringEncoding]];
    [urlReq setHTTPMethod:@"POST"];
    
    NSError* error = nil;
    
    NSData* signatureData = [NSURLConnection sendSynchronousRequest:urlReq
                                                  returningResponse:nil
                                                              error:&error];
    NSString* signature = [[NSString alloc] initWithData:signatureData
                                                encoding:NSUTF8StringEncoding];
    NSLog(@"signature %@ ", signature);
    return signature;
}

@end
