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

#define TEST_EMAIL @"testuser1@gmail.com"
#define TEST_PASSWORD @"testuser1@123"
#define TEST_MOBILE @"1234567890"

#define TEST_FIRST_NAME @"test"
#define TEST_LAST_NAME @"user"

#define TEST_CITY @"Mumbai"
#define TEST_COUNTRY @"India"
#define TEST_STATE @"Maharashtra"
#define TEST_STREET1 @"Golden Road"
#define TEST_STREET2 @"Pink City"
#define TEST_ZIP @"401209"

#define TEST_DEBIT_CARD_NUMBER @"4028-5300-5270-8001"
#define TEST_DEBIT_SCHEME @"visa"
#define TEST_DEBIT_CVV @"018"
#define TEST_OWNER_NAME @"Pappu Yadav"
#define TEST_DEBIT_CARD_EXPIRY @"12/15"
#define TEST_DEBIT_OWNER_NAME @"Yaddy"
#define TEST_DEBIT_CARD_BANK_NAME @"KOTAK"
#define TEST_DEBIT_CARD_TOKEN @""

#define TEST_CREDIT_CARD_NUMBER @"4028-5300-5270-8001"
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


#define DEBIT_CARD_TYPE @"DEBIT_CARD_TYPE"
#define CREDIT_CARD_TYPE @"CREDIT_CARD_TYPE"


#define GUEST_PAY_TYPE @"GUEST_PAY_TYPE"
#define MEMBER_PAY_TYPE @"MEMBER_PAY_TYPE"

//#define VISA @"VISA"
//#define MAESTRO @"MAESTRO"
//#define DISCOVER @"DISCOVER"
//#define JCB @"JCB"
//#define DINERCLUB @"DINERCLUB"
//#define MASTER @"MASTER"
//#define AMEX @"AMEX"

#define LAST_USER @"LAST_USER"


// card types
#define amex @[ @"34", @"37" ]
#define discover @[ @"60", @"62", @"64", @"65" ]
#define JCB @[ @"35" ]
#define DinerClub @[ @"30", @"36", @"38", @"39" ]
#define VISA @[ @"4" ]
#define MAESTRO \
@[            \
@"67",      \
@"56",      \
@"502260",  \
@"504433",  \
@"504434",  \
@"504435",  \
@"504437",  \
@"504645",  \
@"504681",  \
@"504753",  \
@"504775",  \
@"504809",  \
@"504817",  \
@"504834",  \
@"504848",  \
@"504884",  \
@"504973",  \
@"504993",  \
@"508125",  \
@"508126",  \
@"508159",  \
@"508192",  \
@"508227",  \
@"600206",  \
@"603123",  \
@"603741",  \
@"603845",  \
@"622018"   \
]
#define MASTER @[ @"5" ]


#endif
