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

@interface CardPayViewController ()
@property (nonatomic, strong)  CTSAlertView* alertView;
@end

@implementation CardPayViewController
@synthesize cardNumberTextField, expiryDateTextField, CVVNumberTextField, cardHolderNameTextField;
@synthesize cardType, rootController, payType;

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
    
    self.cardNumberTextField.text = TEST_EMAIL;
    self.expiryDateTextField.text = TEST_DEBIT_EXPIRY_DATE;
    self.CVVNumberTextField.text = TEST_DEBIT_CVV;
    self.cardHolderNameTextField.text = TEST_DEBIT_OWNER_NAME;

    [self initialize];
}


- (void)initialize {
    // Do any additional setup after loading the view from its nib.
    
    paymentlayerinfo = [[CTSPaymentLayer alloc] init];
    paymentlayerinfo.delegate = self;
    
    contactInfo = [[CTSContactUpdate alloc] init];
    contactInfo.firstName = TEST_FIRST_NAME;
    contactInfo.lastName = TEST_LAST_NAME;
    contactInfo.email = TEST_EMAIL;
    contactInfo.mobile = TEST_MOBILE;
    
    addressInfo = [[CTSUserAddress alloc] init];
    addressInfo.city = @"Mumbai";
    addressInfo.country = @"India";
    addressInfo.state = @"Maharashtra";
    addressInfo.street1 = @"Golden Road";
    addressInfo.street2 = @"Pink City";
    addressInfo.zip = @"401209";
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
    [self.alertView createProgressionAlertWithMessage:@"Connecting..." withActivity:YES];
    
    // Doing something on the main thread
    dispatch_queue_t myQueue = dispatch_queue_create("My Queue",NULL);
    dispatch_async(myQueue, ^{
        // Perform long running process
        if ([self.cardNumberTextField.text length] != 0 && [self.expiryDateTextField.text length] != 0 && [self.CVVNumberTextField.text length] != 0 && [self.cardHolderNameTextField.text length] != 0) {
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
            dispatch_async(dispatch_get_main_queue(), ^{
                // Update the UI
                [self.alertView hideCTSAlertView:YES];
                UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Information" message:@"Input field can't be blank!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alertView show];
            });
        }
    });
}


- (void)doUserDebitCardPayment {
    CTSPaymentDetailUpdate* debitCardInfo = [[CTSPaymentDetailUpdate alloc] init];
    CTSElectronicCardUpdate* debitCard =
    [[CTSElectronicCardUpdate alloc] initCreditCard];
    debitCard.number = self.cardNumberTextField.text;
    debitCard.expiryDate = self.expiryDateTextField.text;
    debitCard.scheme = TEST_DEBIT_SCHEME;
    debitCard.ownerName = self.CVVNumberTextField.text;
    debitCard.name = TEST_DEBIT_CARD_BANK_NAME;
    debitCard.cvv = self.cardHolderNameTextField.text;
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
    creditCard.number = self.cardNumberTextField.text;
    creditCard.expiryDate = self.expiryDateTextField.text;
    creditCard.scheme = TEST_CREDIT_CARD_SCHEME;
    creditCard.ownerName = self.cardHolderNameTextField.text;
    creditCard.name = TEST_CREDIT_CARD_BANK_NAME;
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
    creditCard.number = TEST_CREDIT_CARD_NUMBER;
    creditCard.expiryDate = TEST_CREDIT_CARD_EXPIRY_DATE;
    creditCard.scheme =
    [CTSUtility fetchCardSchemeForCardNumber:creditCard.number];
    creditCard.cvv = TEST_CREDIT_CARD_CVV;
    creditCard.ownerName = TEST_CREDIT_CARD_OWNER_NAME;
    
    [paymentInfo addCard:creditCard];
    
    [paymentlayerinfo makePaymentUsingGuestFlow:paymentInfo
                                    withContact:contactInfo
                                         amount:@"1"
                                    withAddress:addressInfo
                                  withReturnUrl:MLC_GUESTCHECKOUT_REDIRECTURL
                                  withSignature:signature
                                      withTxnId:transactionId
                                     isDoSignup:NO
                          withCompletionHandler:nil];
}

- (void)doGuestPaymentDebitCard {
    NSString* transactionId = [self createTXNId];
    
    NSString* signature =
    [ServerSignature getSignatureFromServerTxnId:transactionId amount:@"1"];
    
    CTSPaymentDetailUpdate* paymentInfo = [[CTSPaymentDetailUpdate alloc] init];
    
    CTSElectronicCardUpdate* debitCard =
    [[CTSElectronicCardUpdate alloc] initDebitCard];
    debitCard.number = TEST_DEBIT_CARD_NUMBER;
    debitCard.expiryDate = TEST_DEBIT_EXPIRY_DATE;
    debitCard.scheme = TEST_DEBIT_SCHEME;
    debitCard.cvv = TEST_DEBIT_CVV;
    debitCard.ownerName = TEST_OWNER_NAME;
    
    [paymentInfo addCard:debitCard];
    
    [paymentlayerinfo makePaymentUsingGuestFlow:paymentInfo
                                    withContact:contactInfo
                                         amount:@"1"
                                    withAddress:addressInfo
                                  withReturnUrl:MLC_GUESTCHECKOUT_REDIRECTURL
                                  withSignature:signature
                                      withTxnId:transactionId
                                     isDoSignup:NO
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
        sleep(5);
        
        // Update the UI
        if (hasSuccess) {
            [self.alertView hideCTSAlertView:YES];
            [self.alertView createProgressionAlertWithMessage:@"Connecting to the PG" withActivity:YES];
            [self loadRedirectUrl:paymentInfo.redirectUrl];
            [self saveData];
        }else{
            [self.alertView hideCTSAlertView:YES];
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:error.description delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
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
        sleep(5);
        if (hasSuccess) {
            [self.alertView hideCTSAlertView:YES];
            [self.alertView createProgressionAlertWithMessage:@"Connecting to the PG" withActivity:YES];
            [self loadRedirectUrl:paymentInfo.redirectUrl];
            [self saveData];
        }else{
            [self.alertView hideCTSAlertView:YES];
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:error.description delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertView show];
        }
    });
}

- (void)saveData {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    // Store the data
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    if ([self.cardType isEqualToString:DEBIT_CARD_TYPE]) {
        [dict setValue:@"DEBIT" forKey:@"paymentOptions"];
    }if ([self.cardType isEqualToString:CREDIT_CARD_TYPE]) {
        [dict setValue:@"CREDIT" forKey:@"paymentOptions"];
    }
    [dict setValue:self.cardType forKey:@"paymentType"];
    [appDelegate.userdata addObject:dict];
}


#pragma mark - helper methods

- (void)loadRedirectUrl:(NSString*)redirectURL {
    WebViewViewController* webViewViewController = [[WebViewViewController alloc] init];
    webViewViewController.redirectURL = redirectURL;
    [self.alertView hideCTSAlertView:YES];
    [self.rootController.navigationController pushViewController:webViewViewController animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
