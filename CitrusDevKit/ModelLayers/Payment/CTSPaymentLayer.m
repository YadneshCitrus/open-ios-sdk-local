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
@property(strong) CTSPaymentDetailUpdate* paymentDetailInfo;
@property(strong) CTSContactUpdate* contactDetailInfo;
@property(strong) NSString* amount;
@property(strong) NSString* paymentTokenType;
@property(assign) BOOL isGuestCheout;
@property(strong) NSString* transactionId;
@property(strong) CTSPaymentDetailUpdate* paymentDetailUpdate;
@end

@implementation CTSPaymentLayer
@synthesize merchantTxnId;
@synthesize signature;
@synthesize objectManager;
@synthesize delegate;

- (NSArray*)formRegistrationArray {
  NSMutableArray* registrationArray = [[NSMutableArray alloc] init];
  [registrationArray
      addObject:
          [[CTSRestRegister alloc]
                 initWithPath:MLC_PAYMENT_GETSIGNATURE_PATH
                   httpMethod:MLC_OAUTH_TOKEN_SIGNUP_REQ_TYPE
               requestMapping:nil
              responseMapping:
                  [[CTSTypeToParameterMapping alloc]
                      initWithType:MLC_PAYMENT_RESPONSE_TYPE
                        parameters:MLC_PAYMENT_GET_SIGNATURE_RES_MAPPING]]];

  return registrationArray;
}
//- (void)getsignature:(NSString*)amount {
//  if ([CTSUtility readFromDisk:MLC_SIGNIN_ACCESS_OAUTH_TOKEN] == nil) {
//    [delegate
//        transactionInformation:nil
//                         error:[CTSError getErrorForCode:UserNotSignedIn]];
//    return;
//  }
//
//  OauthStatus* oauthStatus = [CTSOauthManager fetchOauthStatus];
//  NSString* oauthToken = oauthStatus.oauthToken;
//  if (oauthStatus.error != nil) {
//  }
//
//  NSDictionary* header = @{
//    @"Authorization" : [NSString
//        stringWithFormat:@"Bearer %@", [CTSOauthManager readOauthToken]]
//  };
//  NSString* oauthToken = [CTSOauthManager readOauthTokenWithExpiryCheck];
//  CTSRestCoreRequest* request = [[CTSRestCoreRequest alloc]
//      initWithPath:MLC_PAYMENT_GETSIGNATURE_PATH
//         requestId:PaymentGetSignatureReqId
//           headers:[CTSUtility readOauthTokenAsHeader:oauthToken]
//        parameters:@{
//          MLC_PAYMENT_QUERY_AMOUNT : amount,
//          MLC_PAYMENT_QUERY_CURRENCY : @"INR",
//          MLC_PAYMENT_QUERY_REDIRECT : MLC_PAYMENT_REDIRECT_URL
//        } json:nil
//        httpMethod:POST];
//  [restCore requestAsyncServer:request];
//}

/*- (void)insertGuestValues:(CTSPaymentDetailUpdate*)paymentDetailInfo
              withContact:(CTSContactUpdate*)contactDetailInfo
              withAddress:(CTSUserAddress*)address
            withReturnUrl:(NSString*)returnUrl
                withTxnId:(NSString*)merchanttxnId
            withSignature:(NSString*)reqsignature
               withAmount:(NSString*)amt {
  CTSGuestCheckout* guestpayment = [[CTSGuestCheckout alloc] init];
  guestpayment.returnUrl = returnUrl;
  guestpayment.amount = amt;

  // Address can't be blank
  guestpayment.addressState = address.state;
  guestpayment.addressCity = address.city;
  guestpayment.addressZip = address.zip;
  guestpayment.address = @"";
  guestpayment.email = contactDetailInfo.email;
  guestpayment.firstName = contactDetailInfo.firstName;
  guestpayment.lastName = contactDetailInfo.lastName;
  guestpayment.mobile = contactDetailInfo.mobile;
  guestpayment.merchantTxnId = merchanttxnId;
  for (CTSPaymentOption* paymentOption in paymentDetailInfo.paymentOptions) {
    if ([paymentOption.type isEqualToString:MLC_PROFILE_PAYMENT_CREDIT_TYPE]) {
      guestpayment.paymentMode = @"CREDIT_CARD";
    } else if ([paymentOption.type
                   isEqualToString:MLC_PROFILE_PAYMENT_DEBIT_TYPE]) {
      guestpayment.paymentMode = @"DEBIT_CARD";
    } else if ([paymentOption.type
                   isEqualToString:MLC_PROFILE_PAYMENT_NETBANKING_TYPE]) {
      guestpayment.paymentMode = @"NET_BANKING";
    }
    if (paymentOption.expiryDate != nil) {
      NSArray* expiryDate =
          [paymentOption.expiryDate componentsSeparatedByString:@"/"];
      guestpayment.expiryMonth = [expiryDate objectAtIndex:0];
      guestpayment.expiryYear = [expiryDate objectAtIndex:1];
    }
    if (paymentOption.owner != nil) {
      guestpayment.cardHolderName = paymentOption.owner;
    }
    if (paymentOption.cvv != nil) {
      guestpayment.cvvNumber = paymentOption.cvv;
    }
    if (paymentOption.scheme != nil) {
      guestpayment.cardType = paymentOption.scheme;
    }
    if (paymentOption.number != nil) {
      guestpayment.cardNumber = paymentOption.number;
    }
    if (paymentOption.code != nil) {
      guestpayment.issuerCode = paymentOption.code;
    }
  }
  CTSErrorCode error = [paymentDetailInfo validate];
  if (error != NoError) {
    [self makeGuestPaymentHelper:nil error:[CTSError getErrorForCode:error]];

    return;
  }
  NSDictionary* header = @{
    @"access_key" : MLC_GUESTCHECKOUT_ACCESSKEY,
    @"Accept-Language" : @"en-US",
    @"Accept" : @"application/json",
    @"Content-Type" : @"application/json",
    @"Content-Type" : @"application/xml",
    @"signature" : reqsignature
  };
  NSLog(@"guest request:%@", guestpayment);
  CTSRestCoreRequest* request =
      [[CTSRestCoreRequest alloc] initWithPath:MLC_CITRUS_GUESTCHECKOUT_URL
                                     requestId:PaymentAsGuestReqId
                                       headers:header
                                    parameters:nil
                                          json:[guestpayment toJSONString]
                                    httpMethod:POST];
  [restCore requestAsyncServer:request];
}*/

- (void)insertGuestValues:(CTSPaymentDetailUpdate*)paymentDetailInfo
              withContact:(CTSContactUpdate*)contactDetailInfo
              withAddress:(CTSUserAddress*)address
            withReturnUrl:(NSString*)returnUrl
                withTxnId:(NSString*)merchanttxnId
            withSignature:(NSString*)reqsignature
               withAmount:(NSString*)amt {
  CTSPaymentRequest* paymentrequest = [[CTSPaymentRequest alloc] init];
  paymentrequest.merchantAccessKey = MLC_PAYMENT_ACCESSKEY;
  paymentrequest.merchantTxnId = merchanttxnId;
  paymentrequest.requestSignature = reqsignature;
  paymentrequest.notifyUrl = @"";
  // paymentrequest.returnUrl = MLC_PAYMENT_REDIRECT_URLCOMPLETE;
  paymentrequest.returnUrl = returnUrl;
  CTSAmount* amount = [[CTSAmount alloc] init];
  amount.value = amt;
  amount.currency = @"INR";
  CTSPaymentToken* paymentToken = [[CTSPaymentToken alloc] init];
  paymentToken.type = self.paymentTokenType;
  CTSPaymentMode* paymentMode = [[CTSPaymentMode alloc] init];
  for (CTSPaymentOption* paymentOption in paymentDetailInfo.paymentOptions) {
    paymentMode.type = paymentOption.type;
    if (paymentOption.code != nil) {
      paymentMode.code = paymentOption.code;
    }
    if (paymentOption.name != nil) {
      paymentMode.holder = paymentOption.name;
    }
    if (paymentOption.expiryDate != nil) {
      paymentMode.expiry = paymentOption.expiryDate;
    }
    if (paymentOption.cvv != nil) {
      paymentMode.cvv = paymentOption.cvv;
    }
    if (paymentOption.number != nil) {
      paymentMode.number = paymentOption.number;
    }
    if (paymentOption.scheme != nil) {
      paymentMode.scheme = paymentOption.scheme;
    }
  }
  paymentToken.paymentMode = paymentMode;
  CTSUserDetails* userDetails = [[CTSUserDetails alloc] init];
  userDetails.email = contactDetailInfo.email;
  userDetails.firstName = contactDetailInfo.firstName;
  userDetails.lastName = contactDetailInfo.lastName;
  userDetails.mobileNo = contactDetailInfo.mobile;
  CTSUserAddress* userAddress = [[CTSUserAddress alloc] init];
  userAddress.city = address.city;
  userAddress.country = address.country;
  userAddress.state = address.state;
  userAddress.street1 = address.street1;
  userAddress.street2 = address.street2;
  userAddress.zip = address.zip;
  userDetails.address = userAddress;
  paymentrequest.amount = amount;
  paymentrequest.paymentToken = paymentToken;
  paymentrequest.userDetails = userDetails;

  NSDictionary* header = @{ @"Content-Type" : @"application/json" };
  NSLog(@"json request:%@", paymentrequest);
  NSLog(@"JSON STRING:%@", [paymentrequest toJSONString]);
  CTSRestCoreRequest* request =
      [[CTSRestCoreRequest alloc] initWithPath:MLC_CITRUS_SERVER_URL
                                     requestId:PaymentAsGuestReqId
                                       headers:header
                                    parameters:nil
                                          json:[paymentrequest toJSONString]
                                    httpMethod:POST];
  [restCore requestAsyncServer:request];
}
- (void)insertMemberValues:(CTSPaymentDetailUpdate*)paymentDetailInfo
               withContact:(CTSContactUpdate*)contactDetailInfo
               withAddress:(CTSUserAddress*)Address
             withReturnUrl:(NSString*)returnUrl
                 withTxnId:(NSString*)merchanttxnId
             withSignature:(NSString*)signatureArg
                withAmount:(NSString*)amt {
  for (CTSPaymentOption* paymentOption in paymentDetailInfo.paymentOptions) {
    if ([self.paymentTokenType isEqualToString:@"paymentOptionIdToken"]) {
      // tokenized
      CTSTokenizedCardPayment* tokenizedCardPaymentRequest =
          [[CTSTokenizedCardPayment alloc] init];
      tokenizedCardPaymentRequest.merchantAccessKey = MLC_PAYMENT_ACCESSKEY;
      tokenizedCardPaymentRequest.merchantTxnId = merchanttxnId;
      tokenizedCardPaymentRequest.notifyUrl = @"";
      tokenizedCardPaymentRequest.requestSignature = signatureArg;
      // tokenizedCardPaymentRequest.returnUrl =
      // MLC_PAYMENT_REDIRECT_URLCOMPLETE;
      tokenizedCardPaymentRequest.returnUrl = returnUrl;
      CTSAmount* amount = [[CTSAmount alloc] init];
      amount.value = amt;
      amount.currency = @"INR";
      CTSTokenizedPaymentToken* paymentToken =
          [[CTSTokenizedPaymentToken alloc] init];
      paymentToken.type = self.paymentTokenType;
      paymentToken.id = paymentOption.token;
      if (paymentOption.cvv != nil) {
        paymentToken.cvv = paymentOption.cvv;
      }
      CTSUserDetails* userDetails = [[CTSUserDetails alloc] init];
      userDetails.email = contactDetailInfo.email;
      userDetails.firstName = contactDetailInfo.firstName;
      userDetails.lastName = contactDetailInfo.lastName;
      userDetails.mobileNo = contactDetailInfo.mobile;
      CTSUserAddress* userAddress = [[CTSUserAddress alloc] init];
      userAddress.city = Address.city;
      userAddress.country = Address.country;
      userAddress.state = Address.state;
      userAddress.street1 = Address.street1;
      userAddress.street2 = Address.street2;
      userAddress.zip = userAddress.zip;
      userDetails.address = userAddress;
      tokenizedCardPaymentRequest.amount = amount;
      tokenizedCardPaymentRequest.paymentToken =
          (CTSPaymentToken<Optional>*)paymentToken;
      tokenizedCardPaymentRequest.userDetails = userDetails;
      OauthStatus* oauthStatus = [CTSOauthManager fetchSigninTokenStatus];
      if (oauthStatus.error != nil) {
        [self makeTokenizedPaymentHelper:nil
                                   error:[CTSError
                                             getErrorForCode:UserNotSignedIn]];

        return;
      }
      NSDictionary* header = @{ @"Content-Type" : @"application/json" };
      NSLog(@"json request:%@", tokenizedCardPaymentRequest);
      CTSRestCoreRequest* request = [[CTSRestCoreRequest alloc]
          initWithPath:MLC_CITRUS_SERVER_URL
             requestId:PaymentUsingtokenizedCardBankReqId
               headers:header
            parameters:nil
                  json:[tokenizedCardPaymentRequest toJSONString]
            httpMethod:POST];
      [restCore requestAsyncServer:request];
    } else {
      // user payment
      CTSPaymentRequest* paymentrequest = [[CTSPaymentRequest alloc] init];
      paymentrequest.merchantAccessKey = MLC_PAYMENT_ACCESSKEY;
      paymentrequest.merchantTxnId = merchanttxnId;
      paymentrequest.requestSignature = signatureArg;
      paymentrequest.notifyUrl = @"";
      // paymentrequest.returnUrl = MLC_PAYMENT_REDIRECT_URLCOMPLETE;
      paymentrequest.returnUrl = returnUrl;
      CTSAmount* amount = [[CTSAmount alloc] init];
      amount.value = amt;
      amount.currency = @"INR";
      CTSPaymentToken* paymentToken = [[CTSPaymentToken alloc] init];
      paymentToken.type = self.paymentTokenType;
      CTSPaymentMode* paymentMode = [[CTSPaymentMode alloc] init];
      for (
          CTSPaymentOption* paymentOption in paymentDetailInfo.paymentOptions) {
        paymentMode.type = paymentOption.type;
        if (paymentOption.code != nil) {
          paymentMode.code = paymentOption.code;
        }
        if (paymentOption.name != nil) {
          paymentMode.holder = paymentOption.name;
        }
        if (paymentOption.expiryDate != nil) {
          paymentMode.expiry = paymentOption.expiryDate;
        }
        if (paymentOption.cvv != nil) {
          paymentMode.cvv = paymentOption.cvv;
        }
        if (paymentOption.number != nil) {
          paymentMode.number = paymentOption.number;
        }
        if (paymentOption.scheme != nil) {
          paymentMode.scheme = paymentOption.scheme;
        }
      }
      paymentToken.paymentMode = paymentMode;
      CTSUserDetails* userDetails = [[CTSUserDetails alloc] init];
      userDetails.email = contactDetailInfo.email;
      userDetails.firstName = contactDetailInfo.firstName;
      userDetails.lastName = contactDetailInfo.lastName;
      userDetails.mobileNo = contactDetailInfo.mobile;
      CTSUserAddress* userAddress = [[CTSUserAddress alloc] init];
      userAddress.city = Address.city;
      userAddress.country = Address.country;
      userAddress.state = Address.state;
      userAddress.street1 = Address.street1;
      userAddress.street2 = Address.street2;
      userAddress.zip = Address.zip;
      userDetails.address = userAddress;
      paymentrequest.amount = amount;
      paymentrequest.paymentToken = paymentToken;
      paymentrequest.userDetails = userDetails;
      OauthStatus* oauthStatus = [CTSOauthManager fetchSigninTokenStatus];
      if (oauthStatus.error != nil) {
        [self makeUserPaymentHelper:nil
                              error:[CTSError getErrorForCode:UserNotSignedIn]];
        return;
      } else {
        CTSErrorCode error = [paymentDetailInfo validate];
        if (error != NoError) {
          /*[delegate transactionInformation:nil
           error:[CTSError getErrorForCode:error]];*/
          // return;
        }
      }
      NSDictionary* header = @{ @"Content-Type" : @"application/json" };
      NSLog(@"json request:%@", paymentrequest);
      NSLog(@"JSON STRING:%@", [paymentrequest toJSONString]);

      //      CTSRestCoreRequest* request = [[CTSRestCoreRequest alloc]
      //          initWithPath:MLC_CITRUS_SERVER_URL
      //             requestId:PaymentUsingSignedInCardBankReqId
      //               headers:header
      //            parameters:nil
      //                  json:[paymentrequest toJSONString]
      //            httpMethod:POST];
      long index = [self addDataToCacheAtAutoIndex:paymentDetailInfo];
      CTSRestCoreRequest* request = [[CTSRestCoreRequest alloc]
          initWithPath:MLC_CITRUS_SERVER_URL
             requestId:PaymentUsingSignedInCardBankReqId
               headers:header
            parameters:nil
                  json:[paymentrequest toJSONString]
            httpMethod:POST
             dataIndex:index];

      [restCore requestAsyncServer:request];
    }
  }
}

- (CTSPaymentRequest*)configureReqPayment:(CTSPaymentDetailUpdate*)paymentInfo
                                  contact:(CTSContactUpdate*)contact
                                  address:(CTSUserAddress*)address
                                   amount:(NSString*)amount
                                returnUrl:(NSString*)returnUrl
                                signature:(NSString*)signatureArg
                                    txnId:(NSString*)txnId {
  CTSPaymentRequest* paymentRequest = [[CTSPaymentRequest alloc] init];

  // paymentRequest.amount = amount;

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
  self.paymentTokenType = @"paymentOptionToken";
  //  [self insertMemberValues:paymentInfo
  //               withContact:contactInfo
  //                 withTxnId:merchantTxnId
  //             withSignature:signature
  //                withAmount:amount];

  [self insertMemberValues:paymentInfo
               withContact:contactInfo
               withAddress:userAddress
             withReturnUrl:returnUrl
                 withTxnId:merchantTxnIdArg
             withSignature:signatureArg
                withAmount:amount];

  //
  //  CTSPaymentRequest* paymentrequest =
  //      [self configureReqPayment:paymentInfo
  //                        contact:contactInfo
  //                        address:userAddress
  //                         amount:amount
  //                      returnUrl:returnUrl
  //                      signature:signatureArg
  //                          txnId:merchantTxnIdArg];
  OauthStatus* oauthStatus = [CTSOauthManager fetchSigninTokenStatus];
  // NSString* oauthToken = oauthStatus.oauthToken;
  if (oauthStatus.error != nil) {
    [self makeUserPaymentHelper:nil
                          error:[CTSError getErrorForCode:UserNotSignedIn]];

    return;
  } else {
    CTSErrorCode error = [paymentInfo validate];
    if (error != NoError) {
      /*[delegate transactionInformation:nil
       error:[CTSError getErrorForCode:error]];*/
      // return;
    }
  }
  //  NSLog(@"json request:%@", paymentrequest);
  //  NSLog(@"JSON STRING:%@", [paymentrequest toJSONString]);
  //  CTSRestCoreRequest* request =
  //      [[CTSRestCoreRequest alloc] initWithPath:MLC_CITRUS_SERVER_URL
  //                                     requestId:PaymentUsingSignedInCardBankReqId
  //                                       headers:nil
  //                                    parameters:nil
  //                                          json:[paymentrequest toJSONString]
  //                                    httpMethod:POST];
  //  [restCore requestAsyncServer:request];
}

//- (void)makeUserPayment:(CTSPaymentDetailUpdate*)paymentInfo
//            withContact:(CTSContactUpdate*)contactInfo
//            withAddress:(CTSUserAddress*)userAddress
//                 amount:(NSString*)amount
//          withReturnUrl:(NSString*)returnUrl
//          withSignature:(NSString*)signatureArg
//              withTxnId:(NSString*)merchantTxnIdArg
//  withCompletionHandler:(ASMakeUserPaymentCallBack)callback {
//    [self addCallback:callback
//    forRequestId:PaymentUsingSignedInCardBankReqId];
//    self.paymentTokenType = @"paymentOptionToken";
//
//      CTSPaymentRequest* paymentrequest =
//          [self configureReqPayment:paymentInfo
//                            contact:contactInfo
//                            address:userAddress
//                             amount:amount
//                          returnUrl:returnUrl
//                          signature:signatureArg
//                              txnId:merchantTxnIdArg];
//    OauthStatus* oauthStatus = [CTSOauthManager fetchSigninTokenStatus];
//    // NSString* oauthToken = oauthStatus.oauthToken;
//    if (oauthStatus.error != nil) {
//        [self makeUserPaymentHelper:nil
//                              error:[CTSError
//                              getErrorForCode:UserNotSignedIn]];
//
//        return;
//    } else {
//        CTSErrorCode error = [paymentInfo validate];
//        if (error != NoError) {
//            /*[delegate transactionInformation:nil
//             error:[CTSError getErrorForCode:error]];*/
//            // return;
//        }
//    }
//     NSLog(@"json request:%@", paymentrequest);
//      NSLog(@"JSON STRING:%@", [paymentrequest toJSONString]);
//      CTSRestCoreRequest* request =
//          [[CTSRestCoreRequest alloc] initWithPath:MLC_CITRUS_SERVER_URL
//                                        requestId:PaymentUsingSignedInCardBankReqId
//                                           headers:nil
//                                        parameters:nil
//                                              json:[paymentrequest
//                                              toJSONString]
//                                        httpMethod:POST];
//      [restCore requestAsyncServer:request];
//}

- (void)makeTokenizedPayment:(CTSPaymentDetailUpdate*)paymentInfo
                 withContact:(CTSContactUpdate*)contactInfo
                 withAddress:(CTSUserAddress*)userAddress
                      amount:(NSString*)amount
               withReturnUrl:(NSString*)returnUrl
               withSignature:(NSString*)signatureArg
                   withTxnId:(NSString*)merchantTxnIdArg
       withCompletionHandler:(ASMakeTokenizedPaymentCallBack)callback {
  [self addCallback:callback forRequestId:PaymentUsingtokenizedCardBankReqId];
  self.paymentTokenType = @"paymentOptionIdToken";
  //  [self insertMemberValues:paymentInfo
  //               withContact:contactInfo
  //                 withTxnId:merchantTxnId
  //             withSignature:signature
  //                withAmount:amount];

  [self insertMemberValues:paymentInfo
               withContact:contactInfo
               withAddress:userAddress
             withReturnUrl:returnUrl
                 withTxnId:merchantTxnIdArg
             withSignature:signatureArg
                withAmount:amount];
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
  self.paymentTokenType = @"paymentOptionToken";
  CTSAuthLayer* authLayer = [[CTSAuthLayer alloc] init];
  authLayer.delegate = self;
  _paymentDetailUpdate = paymentInfo;
  __block NSString* email = contactInfo.email;
  __block NSString* mobile = contactInfo.mobile;
  __block NSString* password = contactInfo.password;
  dispatch_queue_t backgroundQueue =
      dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

  dispatch_async(backgroundQueue, ^(void) {
      [authLayer requestSignUpWithEmail:email
                                 mobile:mobile
                               password:password
                      completionHandler:^(NSString* userName,
                                          NSString* token,
                                          NSError* error) {

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
                      }];
  });

  [self insertGuestValues:paymentInfo
              withContact:contactInfo
              withAddress:userAddress
            withReturnUrl:returnUrl
                withTxnId:merchantTxnIdArg
            withSignature:signatureArg
               withAmount:amount];
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
  if (error == nil) {
    if (response.indexData > -1) {
      CTSPaymentDetailUpdate* paymentDetail =
          [self fetchAndRemoveDataFromCache:response.indexData];
      [paymentDetail logProperties];
      __block CTSProfileLayer* profile = [[CTSProfileLayer alloc] init];
      [profile updatePaymentInformation:paymentDetail
                  withCompletionHandler:^(NSError* error) {
                      LogTrace(@" error %@ ", error);
                  }];
    }

    payment =
        [[CTSPaymentTransactionRes alloc] initWithString:response.responseString
                                                   error:&jsonError];
    [payment logProperties];

    // CTSProfileLayer *profileLayer = [[CTSProfileLayer alloc] init];
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
