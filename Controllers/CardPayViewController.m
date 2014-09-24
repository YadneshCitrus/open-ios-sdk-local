//
//  CardPayViewController.m
//  SDKSandbox
//
//  Created by Mukesh Patil on 08/09/14.
//  Copyright (c) 2014 CitrusPay. All rights reserved.
//

#import "CardPayViewController.h"
#import "CTSAlertView.h"
#import "MerchantConstants.h"
#import "TestParams.h"
#import "ServerSignature.h"
#import "WebViewViewController.h"
#import "AppDelegate.h"
#import "User.h"


#define REGEX_CARDNUMBER_LIMIT @"^.{19,19}$"

#define REGEX_EXPIRYDATE_LIMIT @"^.{5,5}$"
#define REGEX_EXPIRYDATE_FORMAT @"[0-9]{2}\\/[0-9]{2}"

#define REGEX_CVV @"^[0-9]*$"

#define REGEX_CARDHOLDER_NAME @"[A-Za-z ]{3,20}"
#define REGEX_CARDHOLDER_NAME_LIMIT @"^.{3,20}$"


@interface CardPayViewController ()
@property (nonatomic, strong)  CTSAlertView* alertView;
@end

@implementation CardPayViewController
@synthesize cardNumberTextField, expiryDateTextField, CVVNumberTextField, cardHolderNameTextField;
@synthesize cardType, rootController, payType, mLastInput, cardSchemeImage;
static NSInteger previouslength = 0;
static NSInteger creditPreviouslength = 0;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.expiryDateTextField addTarget:self
                                     action:@selector(textfieldTextchange:)
                           forControlEvents:UIControlEventEditingChanged];

    [self setupTextFieldValidation];

    [self initialize];
}

-(void)setupTextFieldValidation{
    [self.cardNumberTextField addRegx:REGEX_CARDNUMBER_LIMIT withMsg:@"Card number charaters limit should be come 16" tag:1 location:19 type:CARD_TYPE];
    
    [self.expiryDateTextField addRegx:REGEX_EXPIRYDATE_LIMIT withMsg:@"Expiry date charaters limit should be mm/yy format" tag:2 location:5 type:NUMERIC_TYPE];
    [self.expiryDateTextField addRegx:REGEX_EXPIRYDATE_FORMAT withMsg:@"Expiry date must be in proper format (eg. (mm/yy)."];

    [self.CVVNumberTextField addRegx:REGEX_CVV withMsg:@"Enter valid CVV." tag:0 location:0 type:CVV_TYPE];

    [self.cardHolderNameTextField addRegx:REGEX_CARDHOLDER_NAME_LIMIT withMsg:@"Card HolderName charaters limit should be come between 3-20"];
    [self.cardHolderNameTextField addRegx:REGEX_CARDHOLDER_NAME withMsg:@"Only alpha characters are allowed." tag:4 location:20 type:ALPHABETICAL_TYPE];
}


-(void)setTestData
{
    /**
     *  TestDatax
     *
     *  use testdata for SDKSandboxTestData applicatin Target
     */
#if defined (TESTDATA_VERSION)
    if ([self.cardType isEqualToString:DEBIT_CARD_TYPE]) {
        self.cardNumberTextField.text = TEST_DEBIT_CARD_NUMBER;
        self.expiryDateTextField.text = TEST_DEBIT_CARD_EXPIRY;
        self.CVVNumberTextField.text = TEST_DEBIT_CVV;
        self.cardHolderNameTextField.text = TEST_OWNER_NAME;
    }if ([self.cardType isEqualToString:CREDIT_CARD_TYPE]) {
        self.cardNumberTextField.text = TEST_CREDIT_CARD_NUMBER;
        self.expiryDateTextField.text = TEST_CREDIT_CARD_EXPIRY_DATE;
        self.CVVNumberTextField.text = TEST_CREDIT_CARD_CVV;
        self.cardHolderNameTextField.text = TEST_CREDIT_CARD_OWNER_NAME;
    }
    self.cardSchemeImage.image = [UIImage imageNamed:@"visa.png"];
#endif
}

- (void)initialize {
    // Do any additional setup after loading the view from its nib.
    
    paymentlayerinfo = [[CTSPaymentLayer alloc] init];
    paymentlayerinfo.delegate = self;
    
    profileLayer = [[CTSProfileLayer alloc] init];
    profileLayer.delegate = self;

    [self fetchContactInformation];
    
    [self fetchAddressInformation];
    
}

-(void)fetchAddressInformation
{
    addressInfo = [[CTSUserAddress alloc] init];
    
    /**
     *  TestData
     *
     *  use testdata for SDKSandboxTestData applicatin Target
     */
#if defined (TESTDATA_VERSION)
    addressInfo.city = TEST_CITY;
    addressInfo.country = TEST_COUNTRY;
    addressInfo.state = TEST_STATE;
    addressInfo.street1 = TEST_STREET1;
    addressInfo.street2 = TEST_STREET2;
    addressInfo.zip = TEST_ZIP;
#else
    //
    
#endif
    
}

-(void)fetchContactInformation
{
    contactInfo = [[CTSContactUpdate alloc] init];
    
    /**
     *  TestData
     *
     *  use testdata for SDKSandboxTestData applicatin Target
     */
#if defined (TESTDATA_VERSION)
    contactInfo.firstName = TEST_FIRST_NAME;
    contactInfo.lastName = TEST_LAST_NAME;
    contactInfo.email = TEST_EMAIL;
    contactInfo.mobile = TEST_MOBILE;
#else
    [profileLayer requestContactInformationWithCompletionHandler:nil];
    
    contactInfo.firstName = contactSavedResponse.firstName;
    contactInfo.lastName = contactSavedResponse.lastName;
    contactInfo.email = contactSavedResponse.email;
    contactInfo.mobile = contactSavedResponse.mobile;
#endif
    
}

#pragma mark - profile layer delegates

- (void)profile:(CTSProfileLayer*)profile
didReceiveContactInfo:(CTSProfileContactRes*)contactInfo
          error:(NSError*)error {
    LogTrace(@"3");
    // LogTrace(@"contactInfo %@", contactInfo);
    //[contactInfo logProperties];
    LogTrace(@"contactInfo %@", error);
    
    contactSavedResponse = contactInfo;
}


-(IBAction)cardAction:(id)sender
{
    if ([self.cardNumberTextField isFirstResponder]) {
        [self.cardNumberTextField resignFirstResponder];
    }else if ([self.expiryDateTextField isFirstResponder]) {
        [self.expiryDateTextField resignFirstResponder];
    }else if ([self.CVVNumberTextField isFirstResponder]) {
        [self.CVVNumberTextField resignFirstResponder];
    }else if ([self.cardHolderNameTextField isFirstResponder]) {
        [self.cardHolderNameTextField resignFirstResponder];
    }
    
    //
    [self.alertView didPresentLoadingAlertView:@"Connecting..." withActivity:YES];
    
    if([self.cardNumberTextField validate] & [self.expiryDateTextField validate] & [self.CVVNumberTextField validate] & [self.cardHolderNameTextField validate])
    {
        if ([self.payType isEqualToString:MEMBER_PAY_TYPE]) {
            if ([self.cardType isEqualToString:DEBIT_CARD_TYPE]) {
                [self doUserDebitCardPayment];
            }if ([self.cardType isEqualToString:CREDIT_CARD_TYPE]) {
                [self doUserCreditCardPayment];
            }
        }if ([self.payType isEqualToString:GUEST_PAY_TYPE]) {
            if ([self.cardType isEqualToString:DEBIT_CARD_TYPE]) {
                [self doGuestPaymentDebitCard];
            }if ([self.cardType isEqualToString:CREDIT_CARD_TYPE]) {
                [self doGuestPaymentCreditCard];
            }
        }
    }else{
        // Update the UI
        [self.alertView dismissLoadingAlertView:YES];
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Information" message:@"Please enter valid input" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
    }
}


- (void)doUserDebitCardPayment {
    CTSPaymentDetailUpdate* debitCardInfo = [[CTSPaymentDetailUpdate alloc] init];
    CTSElectronicCardUpdate* debitCard =
    [[CTSElectronicCardUpdate alloc] initCreditCard];
    debitCard.number = [self.cardNumberTextField.text stringByReplacingOccurrencesOfString:@"-" withString:@""];
    debitCard.expiryDate = self.expiryDateTextField.text;
    debitCard.scheme = [CTSUtility fetchCardSchemeForCardNumber:debitCard.number];
    debitCard.ownerName = self.cardHolderNameTextField.text;
#if defined (TESTDATA_VERSION)
    debitCard.name = TEST_DEBIT_CARD_BANK_NAME;
#endif
    debitCard.cvv = self.CVVNumberTextField.text;
    [debitCardInfo addCard:debitCard];
    NSString* txnId = [self createTXNId];
    
    [paymentlayerinfo
     makeUserPayment:debitCardInfo
     withContact:contactInfo
     withAddress:addressInfo
     amount:@"1"
     withReturnUrl:MLC_PAYMENT_REDIRECT_URLCOMPLETE
     withSignature:[ServerSignature getSignatureFromServerTxnId:txnId
                                                         amount:@"1"]
     withTxnId:txnId
     withCompletionHandler:nil];
}


- (void)doUserCreditCardPayment {
    CTSPaymentDetailUpdate* creditCardInfo =
    [[CTSPaymentDetailUpdate alloc] init];
    CTSElectronicCardUpdate* creditCard =
    [[CTSElectronicCardUpdate alloc] initCreditCard];
    creditCard.number = [self.cardNumberTextField.text stringByReplacingOccurrencesOfString:@"-" withString:@""];
    creditCard.expiryDate = self.expiryDateTextField.text;
    creditCard.scheme = [CTSUtility fetchCardSchemeForCardNumber:creditCard.number];
    creditCard.ownerName = self.cardHolderNameTextField.text;
#if defined (TESTDATA_VERSION)
    creditCard.name = TEST_CREDIT_CARD_BANK_NAME;
#endif
    
    creditCard.cvv = self.CVVNumberTextField.text;
    [creditCardInfo addCard:creditCard];
    
    NSString* transactionId;
    
    transactionId = [self createTXNId];
    NSLog(@"transactionId:%@", transactionId);
    NSString* signature =
    [ServerSignature getSignatureFromServerTxnId:transactionId amount:@"1"];
    
    [paymentlayerinfo makeUserPayment:creditCardInfo
                          withContact:contactInfo
                          withAddress:addressInfo
                               amount:@"1"
                        withReturnUrl:MLC_PAYMENT_REDIRECT_URLCOMPLETE
                        withSignature:signature
                            withTxnId:transactionId
                withCompletionHandler:nil];
}


- (void)doGuestPaymentCreditCard {
    NSString* transactionId = [self createTXNId];
    
    NSString* signature =
    [ServerSignature getSignatureFromServerTxnId:transactionId amount:@"1"];
    
    CTSPaymentDetailUpdate* paymentInfo = [[CTSPaymentDetailUpdate alloc] init];
    
    CTSElectronicCardUpdate* creditCard =
    [[CTSElectronicCardUpdate alloc] initCreditCard];
    creditCard.number = [self.cardNumberTextField.text stringByReplacingOccurrencesOfString:@"-" withString:@""];
    creditCard.expiryDate = self.expiryDateTextField.text;
    creditCard.scheme = [CTSUtility fetchCardSchemeForCardNumber:creditCard.number];
    creditCard.cvv = self.CVVNumberTextField.text;
    creditCard.ownerName = self.cardHolderNameTextField.text;
    
    [paymentInfo addCard:creditCard];
    
    [paymentlayerinfo makePaymentUsingGuestFlow:paymentInfo
                                    withContact:contactInfo
                                         amount:@"1"
                                    withAddress:addressInfo
                                  withReturnUrl:MLC_GUESTCHECKOUT_REDIRECTURL
                                  withSignature:signature
                                      withTxnId:transactionId
                          withCompletionHandler:nil];
}

- (void)doGuestPaymentDebitCard {
    NSString* transactionId = [self createTXNId];
    
    NSString* signature =
    [ServerSignature getSignatureFromServerTxnId:transactionId amount:@"1"];
    
    CTSPaymentDetailUpdate* paymentInfo = [[CTSPaymentDetailUpdate alloc] init];
    
    CTSElectronicCardUpdate* debitCard =
    [[CTSElectronicCardUpdate alloc] initDebitCard];
    debitCard.number = [self.cardNumberTextField.text stringByReplacingOccurrencesOfString:@"-" withString:@""];
    debitCard.expiryDate = self.expiryDateTextField.text;
    debitCard.scheme = [CTSUtility fetchCardSchemeForCardNumber:debitCard.number];
    debitCard.cvv = self.CVVNumberTextField.text;
    debitCard.ownerName = self.cardHolderNameTextField.text;
    
    [paymentInfo addCard:debitCard];
    
    [paymentlayerinfo makePaymentUsingGuestFlow:paymentInfo
                                    withContact:contactInfo
                                         amount:@"1"
                                    withAddress:addressInfo
                                  withReturnUrl:MLC_GUESTCHECKOUT_REDIRECTURL
                                  withSignature:signature
                                      withTxnId:transactionId
                          withCompletionHandler:nil];
}



- (NSString*)createTXNId {
    NSString* transactionId;
    long long CurrentTime =
    (long long)([[NSDate date] timeIntervalSince1970] * 1000);
    transactionId = [NSString stringWithFormat:@"CTS%lld", CurrentTime];
    // transactionId = [NSString stringWithFormat:@"%lld", 820];
    
    return transactionId;
}


#pragma mark - Payment layer delegates

- (void)payment:(CTSPaymentLayer*)layer
didMakeUserPayment:(CTSPaymentTransactionRes*)paymentInfo
          error:(NSError*)error {
    NSLog(@"%@", paymentInfo);
    LogTrace(@" %@ ", error);
    BOOL hasSuccess =
    ((paymentInfo != nil) && ([paymentInfo.pgRespCode integerValue] == 0) &&
     (error == nil))
    ? YES
    : NO;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // Update the UI
        if (hasSuccess) {
            [self.alertView dismissLoadingAlertView:YES];
            [self.alertView didPresentLoadingAlertView:@"Connecting to the PG" withActivity:YES];
            [self loadRedirectUrl:paymentInfo.redirectUrl];
        }else{
            [self.alertView dismissLoadingAlertView:YES];
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[error.userInfo valueForKey:@"NSLocalizedDescription"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertView show];
        }
    });
    

}

- (void)payment:(CTSPaymentLayer*)layer
didMakePaymentUsingGuestFlow:(CTSPaymentTransactionRes*)paymentInfo
          error:(NSError*)error {
    NSLog(@"%@", paymentInfo);
    LogTrace(@" %@ ", error);
    BOOL hasSuccess =
    ((paymentInfo != nil) && ([paymentInfo.pgRespCode integerValue] == 0) &&
     (error == nil))
    ? YES
    : NO;
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // Update the UI
        if (hasSuccess) {
            [self.alertView dismissLoadingAlertView:YES];
            [self.alertView didPresentLoadingAlertView:@"Connecting to the PG" withActivity:YES];
            [self loadRedirectUrl:paymentInfo.redirectUrl];
        }else{
            [self.alertView dismissLoadingAlertView:YES];
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[error.userInfo valueForKey:@"NSLocalizedDescription"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertView show];
        }
    });
}

- (void)payment:(CTSPaymentLayer*)layer
didMakeTokenizedPayment:(CTSPaymentTransactionRes*)paymentInfo
          error:(NSError*)error {
    NSLog(@"%@", paymentInfo);
    LogTrace(@" %@ ", error);
    BOOL hasSuccess =
    ((paymentInfo != nil) && ([paymentInfo.pgRespCode integerValue] == 0) &&
     (error == nil))
    ? YES
    : NO;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // Update the UI
        if (hasSuccess) {
            [self.alertView dismissLoadingAlertView:YES];
            [self.alertView didPresentLoadingAlertView:@"Connecting to the PG" withActivity:YES];
            [self loadRedirectUrl:paymentInfo.redirectUrl];
        }else{
            [self.alertView dismissLoadingAlertView:YES];
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[error.userInfo valueForKey:@"NSLocalizedDescription"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertView show];
        }
    });
}


#pragma mark - helper methods

- (void)loadRedirectUrl:(NSString*)redirectURL {
    WebViewViewController* webViewViewController = [[WebViewViewController alloc] init];
    webViewViewController.redirectURL = redirectURL;
    webViewViewController.cardType = self.cardType;
    [self.alertView dismissLoadingAlertView:YES];
    [self.rootController.navigationController pushViewController:webViewViewController animated:YES];
}

#pragma mark - UITextField delegates

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}



- (BOOL)textFieldShouldBeginEditing:(UITextField*)textField {
    // Cardnumber
    // card scheme should be shown at runtime(while user is enter the numbers)
    if (textField.tag == 1) {
        self.cardSchemeImage.image = [CTSUtility getSchmeTypeImage:textField.text];
    }
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField*)textField {
    // Cardnumber
    // card scheme should be shown at runtime(while user is enter the numbers)
    if (textField.tag == 1) {
        self.cardSchemeImage.image = [CTSUtility getSchmeTypeImage:textField.text];
    }
    return YES;
}

- (BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)string {
    
    // Cardnumber
    // card scheme should be shown at runtime(while user is enter the numbers)
    if (textField.tag == 1) {
        self.cardSchemeImage.image = [CTSUtility getSchmeTypeImage:textField.text];
    }
    return YES;
}

 

-(IBAction)textfieldTextchange:(id)sender
{
    // Expirydate for DEBIT_CARD_TYPE
    NSInteger textfieldval = [sender tag];
    if (textfieldval == 2 && [self.cardType isEqualToString:DEBIT_CARD_TYPE]) {
        if (self.expiryDateTextField.text.length < previouslength) {
            previouslength--;
        } else {
            NSString* input = self.expiryDateTextField.text;
            NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"MM/yy"];
            
            if (self.expiryDateTextField.text.length == 2 &&
                ![mLastInput rangeOfString:@"/"].location != NSNotFound) {
                int month = [input intValue];
                if (month <= 12) {
                    self.expiryDateTextField.text =
                    [NSString stringWithFormat:@"%@/", self.expiryDateTextField.text];
                    previouslength = self.expiryDateTextField.text.length;
                } else {
                    self.expiryDateTextField.text = @"";
                    previouslength = self.expiryDateTextField.text.length;
                    
                    UIAlertView* alert =
                    [[UIAlertView alloc] initWithTitle:@"Citrus Cash"
                                               message:@"Enter a valid month"
                                              delegate:nil
                                     cancelButtonTitle:@"Ok"
                                     otherButtonTitles:nil];
                    [alert show];
                }
            } else if (self.expiryDateTextField.text.length == 2 &&
                       [mLastInput rangeOfString:@"/"].location != NSNotFound) {
                int month = [self.expiryDateTextField.text intValue];
                if (month <= 12) {
                    self.expiryDateTextField.text = [self.expiryDateTextField.text
                                                    substringWithRange:NSMakeRange(0, 1)];
                    previouslength = self.expiryDateTextField.text.length;
                    
                } else {
                    self.expiryDateTextField.text = @"";
                    UIAlertView* alert =
                    [[UIAlertView alloc] initWithTitle:@"Citrus Cash"
                                               message:@"Enter a valid month"
                                              delegate:nil
                                     cancelButtonTitle:@"Ok"
                                     otherButtonTitles:nil];
                    [alert show];
                }
            } else if (self.expiryDateTextField.text.length == 1) {
                int month = [self.expiryDateTextField.text intValue];
                if (month > 1) {
                    self.expiryDateTextField.text =
                    [NSString stringWithFormat:@"0%@/", self.expiryDateTextField.text];
                    previouslength = self.expiryDateTextField.text.length;
                }
            } else {
                mLastInput = self.expiryDateTextField.text;
                return;
            }
        }
    }
    // Expirydate for CREDIT_CARD_TYPE
    if (textfieldval == 2 && [self.cardType isEqualToString:CREDIT_CARD_TYPE]) {
        if (self.expiryDateTextField.text.length < creditPreviouslength) {
            creditPreviouslength--;
        } else {
            NSString* input = self.expiryDateTextField.text;
            NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"MM/yy"];
            if (self.expiryDateTextField.text.length == 2 &&
                ![mLastInput rangeOfString:@"/"].location != NSNotFound) {
                int month = [input intValue];
                if (month <= 12) {
                    self.expiryDateTextField.text =
                    [NSString stringWithFormat:@"%@/", self.expiryDateTextField.text];
                    creditPreviouslength = self.expiryDateTextField.text.length;
                } else {
                    self.expiryDateTextField.text = @"";
                    creditPreviouslength = self.expiryDateTextField.text.length;
                    
                    UIAlertView* alert =
                    [[UIAlertView alloc] initWithTitle:@"Citrus Cash"
                                               message:@"Enter a valid month"
                                              delegate:nil
                                     cancelButtonTitle:@"Ok"
                                     otherButtonTitles:nil];
                    [alert show];
                }
            } else if (self.expiryDateTextField.text.length == 2 &&
                       [mLastInput rangeOfString:@"/"].location != NSNotFound) {
                int month = [self.expiryDateTextField.text intValue];
                if (month <= 12) {
                    self.expiryDateTextField.text = [self.expiryDateTextField.text
                                                   substringWithRange:NSMakeRange(0, 1)];
                    creditPreviouslength = self.expiryDateTextField.text.length;
                    
                } else {
                    self.expiryDateTextField.text = @"";
                    UIAlertView* alert =
                    [[UIAlertView alloc] initWithTitle:@"Citrus Cash"
                                               message:@"Enter a valid month"
                                              delegate:nil
                                     cancelButtonTitle:@"Ok"
                                     otherButtonTitles:nil];
                    [alert show];
                }
            } else if (self.expiryDateTextField.text.length == 1) {
                int month = [self.expiryDateTextField.text intValue];
                if (month > 1) {
                    self.expiryDateTextField.text =
                    [NSString stringWithFormat:@"0%@/", self.expiryDateTextField.text];
                    creditPreviouslength = self.expiryDateTextField.text.length;
                }
            } else {
                mLastInput = self.expiryDateTextField.text;
                return;
            }
        }
    }
}




- (void)dismissTextField
{
    if ([self.cardNumberTextField isFirstResponder]) {
        [self.cardNumberTextField resignFirstResponder];
    }else if ([self.expiryDateTextField isFirstResponder]) {
        [self.expiryDateTextField resignFirstResponder];
    }else if ([self.CVVNumberTextField isFirstResponder]) {
        [self.CVVNumberTextField resignFirstResponder];
    }else if ([self.cardHolderNameTextField isFirstResponder]) {
        [self.cardHolderNameTextField resignFirstResponder];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
