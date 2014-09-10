//
//  CTSProfileLayer.h
//  RestFulltester
//
//  Created by Yadnesh Wankhede on 04/06/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CTSContactUpdate.h"
#import "CTSProfileContactRes.h"
#import "CTSProfilePaymentRes.h"
#import "CTSPaymentDetailUpdate.h"
#import "CTSRestCoreResponse.h"
#import "CTSRestPluginBase.h"
#import "CTSProfileLayerConstants.h"
@class CTSProfileLayer;
@protocol CTSProfileProtocol
/**
 *  called when client requests for contact information
 *
 *  @param contactInfo nil in case of error
 *  @param error       nil when successful
 */
- (void)profile:(CTSProfileLayer*)profile
    didReceiveContactInfo:(CTSProfileContactRes*)contactInfo
                    error:(NSError*)error;
/**
 *  called when client requests for payment information
 *
 *  @param contactInfo nil in case of error
 *  @param error       nil when succesful
 */
- (void)profile:(CTSProfileLayer*)profile
    didReceivePaymentInformation:(CTSProfilePaymentRes*)contactInfo
                           error:(NSError*)error;
/**
 *  when contact information is updated to server
 *
 *  @param error error if happned
 */
- (void)profile:(CTSProfileLayer*)profile
    didUpdateContactInfoError:(NSError*)error;

/**
 *  when payment information is updated on server
 *
 *  @param error nil when successful
 */
- (void)profile:(CTSProfileLayer*)profile
    didUpdatePaymentInfoError:(NSError*)error;

@end

/**
 *  user profile related services
 */
@interface CTSProfileLayer : CTSRestPluginBase {
}
@property(weak) id<CTSProfileProtocol> delegate;

typedef void (^ASGetContactInfoCallBack)(CTSProfileContactRes* contactInfo,
                                         NSError* error);

typedef void (^ASGetPaymentInfoCallBack)(CTSProfilePaymentRes* paymentInfo,
                                         NSError* error);

typedef void (^ASUpdatePaymentInfoCallBack)(NSError* error);

typedef void (^ASUpdateContactInfoCallBack)(NSError* error);

/**
 *  update contact related information
 *
 *  @param contactInfo actual information to be updated
 */
- (void)updateContactInformation:(CTSContactUpdate*)contactInfo
           withCompletionHandler:(ASUpdateContactInfoCallBack)callback;

/**
 *  update payment related information
 *
 *  @param paymentInfo payment information
 */
- (void)updatePaymentInformation:(CTSPaymentDetailUpdate*)paymentInfo
           withCompletionHandler:(ASUpdatePaymentInfoCallBack)callback;

/**
 *  to request contact related information
 */
- (void)requestContactInformationWithCompletionHandler:
        (ASGetContactInfoCallBack)callback;

/**
 *  request user's payment information
 */
- (void)requestPaymentInformationWithCompletionHandler:
        (ASGetPaymentInfoCallBack)callback;
@end
