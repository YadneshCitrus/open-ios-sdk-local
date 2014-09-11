//
//  CTSPaymentDetailUpdate.h
//  RestFulltester
//
//  Created by Yadnesh Wankhede on 12/06/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CTSElectronicCardUpdate.h"
#import "CTSNetBankingUpdate.h"
#import "CTSPaymentOption.h"
#import "JSONModel.h"

@interface CTSPaymentDetailUpdate : JSONModel
@property(nonatomic, strong) NSString* type;
@property(nonatomic, strong) NSString<Optional>* password;
@property(nonatomic, strong) NSMutableArray<CTSPaymentOption>* paymentOptions;

/**
 *  to add card to the object, internally stored in an array to send to
 *server,card is validated before they are added to the array
 *
 *  @param card object of type CTSElectronicCardUpdate
 *
 *  @return returns SUCESS of type CardValidationError , else corrospding error
 *of type CardValidationError is returned
 */
- (void)addCard:(CTSElectronicCardUpdate*)card;

/**
 *  to add netbanking detail to the object, internally stored in an array to
 *send to server,currently no validation
 *
 *  @param netBankDetail : the detail related to bank
 *
 *  @return always returns true
 */
- (BOOL)addNetBanking:(CTSNetBankingUpdate*)netBankDetail;

- (CTSErrorCode)validate;

- (void)clearCVV;

- (void)clearNetbankCode;
@end
