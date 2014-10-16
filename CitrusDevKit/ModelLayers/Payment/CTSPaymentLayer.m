//
//  CTSPaymentLayer.m
//  RestFulltester
//
//  Created by Raji Nair on 19/06/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//
#import "CTSPaymentDetailUpdate.h"
#import "CTSContactUpdate.h"
#import "CTSPaymentLayer.h"
#import "CTSPaymentMode.h"
#import "CTSPaymentRequest.h"
#import "CTSAmount.h"
#import "CTSPaymentToken.h"
#import "CTSPaymentMode.h"
#import "CTSUserDetails.h"
#import "CTSUserAddress.h"
#import "CTSPaymentTransactionRes.h"
#import "CTSGuestCheckout.h"
#import "CTSPaymentNetbankingRequest.h"
#import "CTSTokenizedCardPayment.h"
#import "CTSUtility.h"
#import "CTSError.h"
#import "CTSProfileLayer.h"
#import "CTSAuthLayer.h"
#import "CTSRestCoreRequest.h"
#import "CTSUtility.h"
#import "CTSOauthManager.h"
#import "CTSTokenizedPaymentToken.h"
#import "NSObject+logProperties.h"
#import "MerchantConstants.h"
#import "CTSUserAddress.h"
@interface CTSPaymentLayer ()
@end

@implementation CTSPaymentLayer
@synthesize merchantTxnId;
@synthesize signature;
@synthesize objectManager;
@synthesize delegate;

- (CTSPaymentRequest*)configureReqPayment:(CTSPaymentDetailUpdate*)paymentInfo
                                  contact:(CTSContactUpdate*)contact
                                  address:(CTSUserAddress*)address
                                   amount:(NSString*)amount
                                returnUrl:(NSString*)returnUrl
                                signature:(NSString*)signatureArg
                                    txnId:(NSString*)txnId {
  CTSPaymentRequest* paymentRequest = [[CTSPaymentRequest alloc] init];

  paymentRequest.amount = [self ctsAmountForAmount:amount];
  paymentRequest.merchantAccessKey = MerchantAccessKey;
  paymentRequest.merchantTxnId = txnId;
  paymentRequest.notifyUrl = @"";
  paymentRequest.requestSignature = signatureArg;
  paymentRequest.returnUrl = returnUrl;
  paymentRequest.paymentToken =
      [[paymentInfo.paymentOptions objectAtIndex:0] fetchPaymentToken];

  paymentRequest.userDetails =
      [[CTSUserDetails alloc] initWith:contact address:address];

  return paymentRequest;
}

- (CTSAmount*)ctsAmountForAmount:(NSString*)amount {
  CTSAmount* ctsAmount = [[CTSAmount alloc] init];
  ctsAmount.value = amount;
  ctsAmount.currency = CURRENCY_INR;
  return ctsAmount;
}

- (void)makeUserPayment:(CTSPaymentDetailUpdate*)paymentInfo
              withContact:(CTSContactUpdate*)contactInfo
              withAddress:(CTSUserAddress*)userAddress
                   amount:(NSString*)amount
            withReturnUrl:(NSString*)returnUrl
            withSignature:(NSString*)signatureArg
                withTxnId:(NSString*)merchantTxnIdArg
    withCompletionHandler:(ASMakeUserPaymentCallBack)callback {
  [self addCallback:callback forRequestId:PaymentUsingSignedInCardBankReqId];

  CTSPaymentRequest* paymentrequest =
      [self configureReqPayment:paymentInfo
                        contact:contactInfo
                        address:userAddress
                         amount:amount
                      returnUrl:returnUrl
                      signature:signatureArg
                          txnId:merchantTxnIdArg];

  CTSErrorCode error = [paymentInfo validate];

  LogTrace(@"validation error %d ", error);

  if (error != NoError) {
    [self makeUserPaymentHelper:nil error:[CTSError getErrorForCode:error]];
    return;
  }

  long index = [self addDataToCacheAtAutoIndex:paymentInfo];

  CTSRestCoreRequest* request =
      [[CTSRestCoreRequest alloc] initWithPath:MLC_CITRUS_SERVER_URL
                                     requestId:PaymentUsingSignedInCardBankReqId
                                       headers:nil
                                    parameters:nil
                                          json:[paymentrequest toJSONString]
                                    httpMethod:POST
                                     dataIndex:index];

  [restCore requestAsyncServer:request];
}

- (void)makeTokenizedPayment:(CTSPaymentDetailUpdate*)paymentInfo
                 withContact:(CTSContactUpdate*)contactInfo
                 withAddress:(CTSUserAddress*)userAddress
                      amount:(NSString*)amount
               withReturnUrl:(NSString*)returnUrl
               withSignature:(NSString*)signatureArg
                   withTxnId:(NSString*)merchantTxnIdArg
       withCompletionHandler:(ASMakeTokenizedPaymentCallBack)callback {
  [self addCallback:callback forRequestId:PaymentUsingtokenizedCardBankReqId];

  CTSPaymentRequest* paymentrequest =
      [self configureReqPayment:paymentInfo
                        contact:contactInfo
                        address:userAddress
                         amount:amount
                      returnUrl:returnUrl
                      signature:signatureArg
                          txnId:merchantTxnIdArg];

  CTSErrorCode error = [paymentInfo validateTokenized];
  LogTrace(@" validation error %d ", error);

  if (error != NoError) {
    [self makeTokenizedPaymentHelper:nil
                               error:[CTSError getErrorForCode:error]];
    return;
  }

  CTSRestCoreRequest* request = [[CTSRestCoreRequest alloc]
      initWithPath:MLC_CITRUS_SERVER_URL
         requestId:PaymentUsingtokenizedCardBankReqId
           headers:nil
        parameters:nil
              json:[paymentrequest toJSONString]
        httpMethod:POST];
  [restCore requestAsyncServer:request];
}

- (void)makePaymentUsingGuestFlow:(CTSPaymentDetailUpdate*)paymentInfo
                      withContact:(CTSContactUpdate*)contactInfo
                           amount:(NSString*)amount
                      withAddress:(CTSUserAddress*)userAddress
                    withReturnUrl:(NSString*)returnUrl
                    withSignature:(NSString*)signatureArg
                        withTxnId:(NSString*)merchantTxnIdArg
            withCompletionHandler:(ASMakeGuestPaymentCallBack)callback {
  [self addCallback:callback forRequestId:PaymentAsGuestReqId];

  CTSErrorCode error = [paymentInfo validate];
  LogTrace(@"validation error %d ", error);

  if (error != NoError) {
    [self makeGuestPaymentHelper:nil
                               error:[CTSError getErrorForCode:error]];
    return;
  }
  CTSAuthLayer* authLayer = [[CTSAuthLayer alloc] init];
  __block CTSPaymentDetailUpdate* _paymentDetailUpdate = paymentInfo;
  __block NSString* email = contactInfo.email;
  __block NSString* mobile = contactInfo.mobile;
  __block NSString* password = contactInfo.password;
  dispatch_queue_t backgroundQueue =
      dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

  dispatch_async(backgroundQueue, ^(void) {
      [authLayer
          requestSignUpWithEmail:email
                          mobile:mobile
                        password:password
               completionHandler:^(NSString* userName,
                                   NSString* token,
                                   NSError* error) {
                   if (error == nil) {
                     dispatch_queue_t backgroundQueueBlock =
                         dispatch_get_global_queue(
                             DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

                     dispatch_async(backgroundQueueBlock, ^(void) {
                         CTSProfileLayer* profileLayer =
                             [[CTSProfileLayer alloc] init];
                         [profileLayer
                             updatePaymentInformation:_paymentDetailUpdate
                                withCompletionHandler:nil];
                         _paymentDetailUpdate = nil;
                     });
                   }
               }];
  });

  CTSPaymentRequest* paymentrequest =
      [self configureReqPayment:paymentInfo
                        contact:contactInfo
                        address:userAddress
                         amount:amount
                      returnUrl:returnUrl
                      signature:signatureArg
                          txnId:merchantTxnIdArg];

  CTSRestCoreRequest* request =
      [[CTSRestCoreRequest alloc] initWithPath:MLC_CITRUS_SERVER_URL
                                     requestId:PaymentAsGuestReqId
                                       headers:nil
                                    parameters:nil
                                          json:[paymentrequest toJSONString]
                                    httpMethod:POST];
  [restCore requestAsyncServer:request];
}

- (void)requestMerchantPgSettings:(NSString*)vanityUrl
            withCompletionHandler:(ASGetMerchantPgSettingsCallBack)callback {
  [self addCallback:callback forRequestId:PaymentPgSettingsReqId];

  if (vanityUrl == nil) {
    [self getMerchantPgSettingsHelper:nil
                                error:[CTSError
                                          getErrorForCode:InvalidParameter]];
  }

  CTSRestCoreRequest* request = [[CTSRestCoreRequest alloc]
      initWithPath:MLC_PAYMENT_GET_PGSETTINGS_PATH
         requestId:PaymentPgSettingsReqId
           headers:nil
        parameters:@{
          MLC_PAYMENT_GET_PGSETTINGS_QUERY_VANITY : vanityUrl
        } json:nil
        httpMethod:POST];
  [restCore requestAsyncServer:request];
}

#pragma mark - authentication protocol mehods
- (void)signUp:(BOOL)isSuccessful
    accessToken:(NSString*)token
          error:(NSError*)error {
  if (isSuccessful) {
  }
}

enum {
  PaymentAsGuestReqId,
  PaymentUsingtokenizedCardBankReqId,
  PaymentUsingSignedInCardBankReqId,
  PaymentPgSettingsReqId
};
- (instancetype)init {
  NSDictionary* dict = @{
    toNSString(PaymentAsGuestReqId) : toSelector(handleReqPaymentAsGuest
                                                 :),
    toNSString(PaymentUsingtokenizedCardBankReqId) :
        toSelector(handleReqPaymentUsingtokenizedCardBank
                   :),
    toNSString(PaymentUsingSignedInCardBankReqId) :
        toSelector(handlePaymentUsingSignedInCardBank
                   :),
    toNSString(PaymentPgSettingsReqId) : toSelector(handleReqPaymentPgSettings
                                                    :)
  };
  self = [super initWithRequestSelectorMapping:dict
                                       baseUrl:CITRUS_PAYMENT_BASE_URL];
  return self;
}

#pragma mark - response handlers methods
- (void)handleReqPaymentAsGuest:(CTSRestCoreResponse*)response {
  NSError* error = response.error;
  JSONModelError* jsonError;
  CTSPaymentTransactionRes* payment = nil;
  if (error == nil) {
    payment =
        [[CTSPaymentTransactionRes alloc] initWithString:response.responseString
                                                   error:&jsonError];

    [payment logProperties];
    //    [delegate payment:self
    //        didMakePaymentUsingGuestFlow:resultObject
    //                               error:error];
  }
  [self makeGuestPaymentHelper:payment error:error];
}

- (void)handleReqPaymentUsingtokenizedCardBank:(CTSRestCoreResponse*)response {
  NSError* error = response.error;
  JSONModelError* jsonError;
  CTSPaymentTransactionRes* payment = nil;
  if (error == nil) {
    NSLog(@"error:%@", jsonError);
    payment =
        [[CTSPaymentTransactionRes alloc] initWithString:response.responseString
                                                   error:&jsonError];
    [payment logProperties];
  }
  [self makeTokenizedPaymentHelper:payment error:error];
}

- (void)handlePaymentUsingSignedInCardBank:(CTSRestCoreResponse*)response {
  NSError* error = response.error;
  JSONModelError* jsonError;
  CTSPaymentTransactionRes* payment = nil;
  if (response.indexData > -1) {
    CTSPaymentDetailUpdate* paymentDetail =
        [self fetchAndRemoveDataFromCache:response.indexData];
    [paymentDetail logProperties];
    __block CTSProfileLayer* profile = [[CTSProfileLayer alloc] init];
    [profile updatePaymentInformation:paymentDetail
                withCompletionHandler:^(NSError* error) {
                    LogTrace(@" error %@ ", error);
                }];

    payment =
        [[CTSPaymentTransactionRes alloc] initWithString:response.responseString
                                                   error:&jsonError];
  }
  [self makeUserPaymentHelper:payment error:error];
}

- (void)handleReqPaymentPgSettings:(CTSRestCoreResponse*)response {
  NSError* error = response.error;
  JSONModelError* jsonError;
  CTSPgSettings* pgSettings = nil;
  if (error == nil) {
    pgSettings = [[CTSPgSettings alloc] initWithString:response.responseString
                                                 error:&jsonError];
    [pgSettings logProperties];
  }
  [self getMerchantPgSettingsHelper:pgSettings error:error];
}

#pragma mark -helper methods
- (void)makeUserPaymentHelper:(CTSPaymentTransactionRes*)payment
                        error:(NSError*)error {
  ASMakeUserPaymentCallBack callback = [self
      retrieveAndRemoveCallbackForReqId:PaymentUsingSignedInCardBankReqId];

  if (callback != nil) {
    callback(payment, error);
  } else {
    [delegate payment:self didMakeUserPayment:payment error:error];
  }
}

- (void)makeTokenizedPaymentHelper:(CTSPaymentTransactionRes*)payment
                             error:(NSError*)error {
  ASMakeTokenizedPaymentCallBack callback = [self
      retrieveAndRemoveCallbackForReqId:PaymentUsingtokenizedCardBankReqId];
  if (callback != nil) {
    callback(payment, error);
  } else {
    [delegate payment:self didMakeTokenizedPayment:payment error:error];
  }
}

- (void)makeGuestPaymentHelper:(CTSPaymentTransactionRes*)payment
                         error:(NSError*)error {
  ASMakeGuestPaymentCallBack callback =
      [self retrieveAndRemoveCallbackForReqId:PaymentAsGuestReqId];
  if (callback != nil) {
    callback(payment, error);
  } else {
    [delegate payment:self didMakePaymentUsingGuestFlow:payment error:error];
  }
}

- (void)getMerchantPgSettingsHelper:(CTSPgSettings*)pgSettings
                              error:(NSError*)error {
  ASGetMerchantPgSettingsCallBack callback =
      [self retrieveAndRemoveCallbackForReqId:PaymentPgSettingsReqId];
  if (callback != nil) {
    callback(pgSettings, error);
  } else {
    [delegate payment:self didRequestMerchantPgSettings:pgSettings error:error];
  }
}
@end
