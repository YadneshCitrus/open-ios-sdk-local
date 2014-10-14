//
//  CTSPaymentLayerConstants.h
//  RestFulltester
//
//  Created by Raji Nair on 19/06/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#ifndef RestFulltester_CTSPaymentLayerConstants_h
#define RestFulltester_CTSPaymentLayerConstants_h

#define CURRENCY_INR @"INR"
#define TYPE_TOKENIZED @"paymentOptionIdToken"
#define TYPE_MEMBER @"paymentOptionToken"

#pragma - mark MLC_PROFILE_GET
#define MLC_PROFILE_UPDATE_Payment_PATH @"profile/me/payment"
#define MLC_PAYMENT_GETSIGNATURE_PATH @"/service/v2/mycard/load/extended"
#define MLC_PAYMENT_ACCESSKEY MerchantAccessKey
#define MLC_GET_Payment_METHOD GET
#define MLC_GET_PAYMENT_QUERY_TYPE @"payment"
#define CITRUS_PAYMENT_BASE_URL CITRUS_BASE_URL
//#define MLC_PAYMENT_BASE_URL @"https://stgadmin.citruspay.com/service"

#define MLC_PAYMENT_BASE_URL CITRUS_BASE_URL
#define MLC_GUEST_PAYMENT_BASE_URL CITRUS_BASE_URL
#define MLC_PAYMENT_UPDATE__REQUEST_TYPE [CTSPaymentUpdate class]
#define MLC_PAYMENT_RESPONSE_TYPE [CTSPaymentRes class]

#define MLC_CITRUS_SERVER_URL [@"/service/moto/authorize/struct/" stringByAppendingString:VanityUrl ]
#define MLC_CITRUS_GUESTCHECKOUT_URL @"/service/moto/authorize/struct/prepaid"

#define MLC_PAYMENT_GET_SIGNATURE_METHOD POST
#define MLC_PAYMENT_GET_SIGNATURE_INFO @"getSignature"
#define MLC_PAYMENT_SIGNATURE_REQUEST_MAPPING \
  @{                                          \
    @"amount" : @"amount",                    \
    @"currency" : @"currency",                \
    @"redirect" : @"redirec" @"t"             \
  }
#define MLC_PAYMENT_QUERY_AMOUNT @"amount"
#define MLC_PAYMENT_QUERY_CURRENCY @"currency"
#define MLC_PAYMENT_QUERY_REDIRECT @"redirect"

#define MLC_PAYMENT_GET_SIGNATURE_RES_MAPPING            \
  @{                                                     \
    @"merchantTransactionId" : @"merchantTransactionId", \
    @"merchant" : @"merchant",                           \
    @"customer" : @"customer",                           \
    @"amount" : @"amount",                               \
    @"description" : @"description",                     \
    @"signature" : @"signature"                          \
  }

// paymentcardmapping
#define MLC_PAYMENT_CARDOPTIONMAPPING \
  @{                                  \
    @"cvv" : @"cvv",                  \
    @"expiry" : @"expiry",            \
    @"holder" : @"holder",            \
    @"number" : @"number",            \
    @"scheme" : @"scheme",            \
    @"type" : @"type",                \
    @"code" : @"code"                 \
  }

#define MLC_PAYMENT_NETBANKINGOPTIONMAPPING \
  @{@"type" : @"type", @"code" : @"code"}

#define MLC_PAYMENT_ADDRESS  \
  @{                         \
    @"city" : @"city",       \
    @"country" : @"country", \
    @"state" : @"state",     \
    @"street1" : @"street1", \
    @"street2" : @"street2", \
    @"zip" : @"zip"          \
  }
#define MLC_PAYMENT                            \
  @{                                           \
    @"merchantKey" : @"merchantAccessKey",     \
    @"merchantTxnId" : @"merchantTxnId",       \
    @"notifyUrl" : @"notifyUrl",               \
    @"requestSignature" : @"requestSignature", \
    @"returnUrl" : @"returnUrl"                \
  }

#define MLC_PAYMENT_AMOUNT @{@"currency" : @"currency", @"value" : @"value"}
#define MLC_PAYMENT_TRANSACTION @"Transaction"
#define MLC_PAYMENT_TRANSACTION_RES_MAP \
  @{                                    \
    @"redirectUrl" : @"redirectUrl",    \
    @"pgRespCode" : @"pgRespCode",      \
    @"txMsg" : @"txMsg"                 \
  }

#define MLC_GUESTCHECKOUT_PAYMENT          \
  @{                                       \
    @"returnUrl" : @"returnUrl",           \
    @"expiryYear" : @"expiryYear",         \
    @"amount" : @"amount",                 \
    @"addressState" : @"addressState",     \
    @"paymentMode" : @"paymentMode",       \
    @"lastName" : @"lastName",             \
    @"addressCity" : @"addressCity",       \
    @"address" : @"address",               \
    @"email" : @"email",                   \
    @"cardHolderName" : @"cardHolderName", \
    @"firstName" : @"firstName",           \
    @"cvvNumber" : @"cvvNumber",           \
    @"cardType" : @"cardType",             \
    @"issuerCode" : @"issuerCode",         \
    @"merchantTxnId" : @"merchantTxnId",   \
    @"addressZip" : @"addressZip",         \
    @"expiryMonth" : @"expiryMonth",       \
    @"mobile" : @"mobile",                 \
    @"cardNumber" : @"cardNumber"          \
  }
#define MLC_GUESTCHECKOUT_ACCESSKEY MerchantAccessKey

#define MLC_PAYMENT_GUESTCHECKOUT @"guestCheckoutPayment"
#define MLC_GUESTCHECKOUT_SECRETKEY MerchantSecretKey

#pragma - mark MLC_PAYMENT_GET_PGSETTINGS
#define MLC_PAYMENT_GET_PGSETTINGS_PATH @"/service/v1/merchant/pgsetting"
#define MLC_PAYMENT_GET_PGSETTINGS_QUERY_VANITY @"vanity"
#define MLC_PAYMENT_GET_PGSETTINGS_NETBANKING_REQ_MAPPING \
  @{@"bankName" : @"bankName", @"issuerCode" : @"issuerCode"}

#endif
