//
//  CTSPaymentDetailUpdate.m
//  RestFulltester
//
//  Created by Yadnesh Wankhede on 12/06/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import "CTSPaymentDetailUpdate.h"

@implementation CTSPaymentDetailUpdate
@synthesize type, paymentOptions, password,defaultOption;
- (instancetype)init {
    self = [super init];
    if (self) {
        type = MLC_PROFILE_GET_PAYMENT_QUERY_TYPE;
        paymentOptions =
        (NSMutableArray<CTSPaymentOption>*)[[NSMutableArray alloc] init];
        password = nil;
    }
    return self;
}

- (void)addCard:(CTSElectronicCardUpdate*)eCard {
    eCard.expiryDate = [CTSUtility correctExpiryDate:eCard.expiryDate];
    [paymentOptions addObject:[[CTSPaymentOption alloc] initWithCard:eCard]];
}

- (BOOL)addNetBanking:(CTSNetBankingUpdate*)netBankDetail {
    [paymentOptions
     addObject:[[CTSPaymentOption alloc] initWithNetBanking:netBankDetail]];
    return YES;
}
- (CTSErrorCode)validate {
    CTSErrorCode error = NoError;
    for (CTSPaymentOption* payment in paymentOptions) {
        error = [payment validate];
        if (error != NoError) {
            return error;
        }
    }
    return error;
}


- (CTSErrorCode)validateTokenized{
    CTSErrorCode error = NoError;
    for (CTSPaymentOption* payment in paymentOptions) {
        if(payment.token == nil)
            error = TokenMissing;
        break;
    }
    return error;
}

- (void)clearCVV {
    for (CTSPaymentOption* payment in paymentOptions) {
        payment.cvv = nil;
    }
}

- (void)clearNetbankCode {
    for (CTSPaymentOption* payment in paymentOptions) {
        payment.code = nil;
    }
}

@end
