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

@interface CardPayViewController ()
@property (nonatomic, strong)  CTSAlertView* alertView;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@end

@implementation CardPayViewController
@synthesize cardNumberTextField, expiryDateTextField, CVVNumberTextField, cardHolderNameTextField, cardSchemeImage;
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
    
    [self initialize];
}

-(void)setTestData
{
    /**
     *  TestData
     *
     *  use testdata for SDKSandboxTestData applicatin Target
     */
#if defined (TESTDATA_VERSION)
    if ([self.cardType isEqualToString:DEBIT_CARD_TYPE]) {
        self.cardNumberTextField.text = TEST_DEBIT_CARD_NUMBER;
        self.expiryDateTextField.text = TEST_DEBIT_EXPIRY_DATE;
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
    LogTrace(@"didReceiveContactInfo");
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
    [self.alertView createProgressionAlertWithMessage:@"Connecting..." withActivity:YES];
    
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
        // Update the UI
        [self.alertView hideCTSAlertView:YES];
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Information" message:@"Input field can't be blank!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
    }
}


- (void)doUserDebitCardPayment {
    CTSPaymentDetailUpdate* debitCardInfo = [[CTSPaymentDetailUpdate alloc] init];
    CTSElectronicCardUpdate* debitCard =
    [[CTSElectronicCardUpdate alloc] initCreditCard];
    debitCard.number = self.cardNumberTextField.text;
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
    creditCard.number = self.cardNumberTextField.text;
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
    creditCard.number = self.cardNumberTextField.text;
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
    debitCard.number = self.cardNumberTextField.text;
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
            [self.alertView hideCTSAlertView:YES];
            [self.alertView createProgressionAlertWithMessage:@"Connecting to the PG" withActivity:YES];
            [self loadRedirectUrl:paymentInfo.redirectUrl];
            if ([self.payType isEqualToString:MEMBER_PAY_TYPE]) {
                [self saveData];
            }
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
        if (hasSuccess) {
            [self.alertView hideCTSAlertView:YES];
            [self.alertView createProgressionAlertWithMessage:@"Connecting to the PG" withActivity:YES];
            [self loadRedirectUrl:paymentInfo.redirectUrl];
            if ([self.payType isEqualToString:MEMBER_PAY_TYPE]) {
                [self saveData];
            }
        }else{
            [self.alertView hideCTSAlertView:YES];
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:error.description delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertView show];
        }
    });
    

}

- (void)saveData {
    // Doing something on the main thread
    dispatch_queue_t myQueue = dispatch_queue_create("My Queue",NULL);
    dispatch_async(myQueue, ^{
        // Perform long running process
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        //    // Store the data
        // Add Entry Data base and reset all fields
        self.managedObjectContext = appDelegate.managedObjectContext;
        
        //  1
        User * newEntry = [NSEntityDescription insertNewObjectForEntityForName:@"User"
                                                        inManagedObjectContext:self.managedObjectContext];
        //  2
        newEntry.username = @"username";
        if ([self.cardType isEqualToString:DEBIT_CARD_TYPE]) {
            newEntry.paymentOption = @"DEBIT";
            newEntry.paymentType = self.cardType;
        }if ([self.cardType isEqualToString:CREDIT_CARD_TYPE]) {
            newEntry.paymentOption = @"CREDIT";
            newEntry.paymentType = self.cardType;
        }
        //  3
        NSError *error;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
        //  4
        [self.view endEditing:YES];
    });

}


#pragma mark - helper methods

- (void)loadRedirectUrl:(NSString*)redirectURL {
    WebViewViewController* webViewViewController = [[WebViewViewController alloc] init];
    webViewViewController.redirectURL = redirectURL;
    [self.alertView hideCTSAlertView:YES];
    [self.rootController.navigationController pushViewController:webViewViewController animated:YES];
}

#pragma mark - UITextField delegates

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;   // return NO to not change text
{
    if ([self.cardNumberTextField isEqual:textField]) {
        NSString* cardScheme = [CTSUtility fetchCardSchemeForCardNumber:textField.text];
        if ([cardScheme isEqualToString:AMEX]) {
            //return @"AMEX";
            self.cardSchemeImage.image = [UIImage imageNamed:@"amex.png"];
        } else if ([cardScheme isEqualToString:DISCOVER]) {
            //return @"DISCOVER";
            self.cardSchemeImage.image = [UIImage imageNamed:@"discover"];
        } else if ([cardScheme isEqualToString:JCB]) {
            //return @"JCB";
            self.cardSchemeImage.image = [UIImage imageNamed:nil];
        } else if ([cardScheme isEqualToString:DINERCLUB]) {
            //return @"DINERCLUB";
            self.cardSchemeImage.image = [UIImage imageNamed:nil];
        } else if ([cardScheme isEqualToString:VISA]) {
            //return @"VISA";
            self.cardSchemeImage.image = [UIImage imageNamed:@"visa.png"];
        } else if ([cardScheme isEqualToString:MAESTRO]) {
            //return @"MAESTRO";
            self.cardSchemeImage.image = [UIImage imageNamed:@"maestro.png"];
        } else if ([cardScheme isEqualToString:MASTER]) {
            //return @"MASTER";
            self.cardSchemeImage.image = [UIImage imageNamed:@"mastercard.png"];
        }else{
            //return @"UNKNOWN";
            self.cardSchemeImage.image = [UIImage imageNamed:nil];
        }
    }
    return YES;
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
