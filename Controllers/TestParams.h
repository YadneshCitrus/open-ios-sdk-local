//
//  TestParams.h
//  RestFulltester
//
//  Created by Yadnesh Wankhede on 11/06/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#ifndef RestFulltester_TestParams_h
#define RestFulltester_TestParams_h
// TestParams.h should be populated according to your needs

#define TEST_EMAIL @"pappu.a.Yadav5@gmail.com"
#define TEST_PASSWORD @"tester@123"
#define TEST_MOBILE @"1234567890"

#define TEST_FIRST_NAME @"dongGing"
#define TEST_LAST_NAME @"wankhede"

//#define TEST_DEBIT_CARD_NUMBER @"4028530012345678"
#define TEST_DEBIT_CARD_NUMBER @"4028530052708001"

#define TEST_DEBIT_EXPIRY_DATE @"03/2015"
#define TEST_DEBIT_SCHEME @"visa"
#define TEST_DEBIT_CVV @"018"
#define TEST_OWNER_NAME @"Pappu Yadav"

#define TEST_DEBIT_CARD_EXPIRY @"12/15"
#define TEST_DEBIT_SCHEME @"visa"
#define TEST_DEBIT_OWNER_NAME @"Yaddy"
#define TEST_DEBIT_CARD_BANK_NAME @"KOTAK"
#define TEST_DEBIT_CARD_TOKEN @""
#define TEST_DEBIT_CVV @"018"

#define TEST_CREDIT_CARD_NUMBER @"4028530052708001"
#define TEST_CREDIT_CARD_EXPIRY_DATE @"03/15"
#define TEST_CREDIT_CARD_SCHEME @"visa"
#define TEST_CREDIT_CARD_OWNER_NAME @"Jitendra Gupta"
#define TEST_CREDIT_CARD_BANK_NAME @"ICICI"
#define TEST_CREDIT_CARD_CVV @"018"

#define TEST_NETBAK_CODE @"CID002"
#define TEST_NETBAK_OWNER_NAME @"Yadnesh Wankhede"
#define TEST_NETBAK_NAME @"Axis Bank"

// sample value
#define TEST_TOKENIZED_PAYBANK_TOKEN @"frfr6arrabcrrrrfee5ec787ad61f8bm"

// sample value
#define TEST_TOKENIZED_CARD_TOKEN @"abcdef4446e0d9d7b34d7a7968123456"

#define TEST_TOKENIZED_CARD_CVV @"000"

#define MLC_GUESTCHECKOUT_REDIRECTURL @"http://103.13.97.20/citrus/index.php"
#define MLC_PAYMENT_REDIRECT_URL \
  @"https://stgadmin.citruspay.com/prepaid/resources/mobile/onload.html"
#define MLC_PAYMENT_REDIRECT_URLCOMPLETE \
  @"https://stgadmin.citruspay.com/service/v2/mycard/load/complete"

#endif
