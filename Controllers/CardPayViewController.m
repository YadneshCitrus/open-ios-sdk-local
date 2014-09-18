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

#define CHARACTERS          @" ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"


@interface CardPayViewController ()
@property (nonatomic, strong)  CTSAlertView* alertView;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@end

@implementation CardPayViewController
@synthesize cardNumberTextField, expiryDateTextField, CVVNumberTextField, cardHolderNameTextField;
@synthesize cardSchemeImage;
@synthesize cardType, rootController, payType, mLastInput;
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
    [self.alertView didPresentLoadingAlertView:@"Connecting..." withActivity:YES];
    
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
        [self.alertView dismissLoadingAlertView:YES];
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
            [self.alertView dismissLoadingAlertView:YES];
            [self.alertView didPresentLoadingAlertView:@"Connecting to the PG" withActivity:YES];
            [self loadRedirectUrl:paymentInfo.redirectUrl];
            if ([self.payType isEqualToString:MEMBER_PAY_TYPE]) {
                [self saveData];
            }
        }else{
            [self.alertView dismissLoadingAlertView:YES];
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
            [self.alertView dismissLoadingAlertView:YES];
            [self.alertView didPresentLoadingAlertView:@"Connecting to the PG" withActivity:YES];
            [self loadRedirectUrl:paymentInfo.redirectUrl];
            if ([self.payType isEqualToString:MEMBER_PAY_TYPE]) {
                [self saveData];
            }
        }else{
            [self.alertView dismissLoadingAlertView:YES];
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
    [self.alertView dismissLoadingAlertView:YES];
    [self.rootController.navigationController pushViewController:webViewViewController animated:YES];
}

#pragma mark - UITextField delegates

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


- (BOOL)hasPrefixArray:(NSArray*)array cardNumber:(NSString*)cardNumber {
    NSLog(@"cardNumber:%@", cardNumber);
    BOOL hasPrefix;
    
    for (int i = 0; i < [array count]; i++) {
        NSLog(@"array value:%@", [array objectAtIndex:i]);
        if ([cardNumber hasPrefix:[array objectAtIndex:i]]) {
            hasPrefix = YES;
            return hasPrefix;
        }
    }
    return NO;
}

- (NSString*)getScheme:(NSString*)cardNumber {
    NSString* testCardNumber;
    if ([cardNumber rangeOfString:@"-"].location != NSNotFound) {
        testCardNumber =
        [cardNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    } else {
        testCardNumber = cardNumber;
    }
    if ([self hasPrefixArray:amex cardNumber:testCardNumber]) {
        return @"AMEX";
    } else if ([self hasPrefixArray:discover cardNumber:testCardNumber]) {
        return @"DISCOVER";
    } else if ([self hasPrefixArray:JCB cardNumber:testCardNumber]) {
        return @"JCB";
    } else if ([self hasPrefixArray:DinerClub cardNumber:testCardNumber]) {
        return @"DINERCLUB";
    } else if ([self hasPrefixArray:VISA cardNumber:testCardNumber]) {
        return @"VISA";
    } else if ([self hasPrefixArray:MAESTRO cardNumber:testCardNumber]) {
        return @"MAESTRO";
    } else if ([self hasPrefixArray:MASTER cardNumber:testCardNumber]) {
        return @"MASTER";
    }
    return @"UNKNOWN";
}

- (BOOL)textFieldShouldBeginEditing:(UITextField*)textField {
    // Card scheme validation
    if (textField.tag == 1) {
        NSString* scheme = [self getScheme:textField.text];
        schemeType = [self getScheme:textField.text];
        if ([scheme caseInsensitiveCompare:@"amex"] == NSOrderedSame) {
            UIImageView* rightImageView =
            [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"amex.png"]];
            self.cardNumberTextField.rightView = rightImageView;
        } else if ([scheme caseInsensitiveCompare:@"discover"] == NSOrderedSame) {
            UIImageView* rightImageView = [[UIImageView alloc]
                                           initWithImage:[UIImage imageNamed:@"discover.png"]];
            self.cardNumberTextField.rightView = rightImageView;
            
        } else if ([scheme caseInsensitiveCompare:@"maestro"] == NSOrderedSame) {
            UIImageView* rightImageView = [[UIImageView alloc]
                                           initWithImage:[UIImage imageNamed:@"discover.png"]];
            self.cardNumberTextField.rightView = rightImageView;
        } else if ([scheme caseInsensitiveCompare:@"master"] == NSOrderedSame) {
            UIImageView* rightImageView = [[UIImageView alloc]
                                           initWithImage:[UIImage imageNamed:@"mastercard.png"]];
            self.cardNumberTextField.rightView = rightImageView;
        } else if ([scheme caseInsensitiveCompare:@"rupay"] == NSOrderedSame) {
            UIImageView* rightImageView =
            [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rupay.png"]];
            self.cardNumberTextField.rightView = rightImageView;
        } else if ([scheme caseInsensitiveCompare:@"visa"] == NSOrderedSame) {
            UIImageView* rightImageView =
            [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"visa.png"]];
            self.cardNumberTextField.rightView = rightImageView;
        }
    }
    return YES;
}


- (BOOL)textField:(UITextField*)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString*)string {
    
    // CVV validation
    // if amex allow 4 digits, if non amex only 3 should allowed.
    if (textField.tag == 3) {
        NSInteger textfieldLength = textField.text.length - range.length + string.length;
        NSCharacterSet* myCharSet =
        [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
        for (int i = 0; i < [string length]; i++) {
            unichar c = [string characterAtIndex:i];
            if ([myCharSet characterIsMember:c]) {
                if ([schemeType caseInsensitiveCompare:@"amex"] == NSOrderedSame) {
                    if (textfieldLength > 4) {
                        return NO;
                    } else {
                        return YES;
                    }
                } else if ([schemeType caseInsensitiveCompare:@"amex"] !=
                           NSOrderedSame) {
                    if (textfieldLength > 3) {
                        return NO;
                    } else {
                        return YES;
                    }
                }
                
            } else {
                return NO;
            }
        }
    }
    
    // CVV sholud allow number only
    if (textField.tag == 3) {
        NSInteger textfieldLength = textField.text.length - range.length + string.length;
        NSCharacterSet* myCharSet =
        [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
        for (int i = 0; i < [string length]; i++) {
            unichar c = [string characterAtIndex:i];
            if ([myCharSet characterIsMember:c]) {
                if (textfieldLength > 4) {
                    return NO;
                } else {
                    return YES;
                }
            } else {
                return NO;
            }
        }
    }
    
    // Cardnumber
    // at the max 16 digits (editing should be blocked after that)
    // card scheme should be shown at runtime(while user is enter the numbers)
    if (textField.tag == 1) {
        if (string.length == 0 && textField.text.length == 1) {
            textField.rightView = nil;
        } else {
            NSString* scheme = [self getScheme:textField.text];
            if ([scheme caseInsensitiveCompare:@"amex"] == NSOrderedSame) {
                UIImageView* rightImageView = [[UIImageView alloc]
                                               initWithImage:[UIImage imageNamed:@"amex.png"]];
                textField.rightView = rightImageView;
            } else if ([scheme caseInsensitiveCompare:@"discover"] == NSOrderedSame) {
                UIImageView* rightImageView = [[UIImageView alloc]
                                               initWithImage:[UIImage imageNamed:@"discover.png"]];
                textField.rightView = rightImageView;
                
            } else if ([scheme caseInsensitiveCompare:@"maestro"] == NSOrderedSame) {
                UIImageView* rightImageView = [[UIImageView alloc]
                                               initWithImage:[UIImage imageNamed:@"maestro.png"]];
                textField.rightView = rightImageView;
            } else if ([scheme caseInsensitiveCompare:@"master"] == NSOrderedSame) {
                UIImageView* rightImageView = [[UIImageView alloc]
                                               initWithImage:[UIImage imageNamed:@"mastercard.png"]];
                textField.rightView = rightImageView;
            } else if ([scheme caseInsensitiveCompare:@"rupay"] == NSOrderedSame) {
                UIImageView* rightImageView = [[UIImageView alloc]
                                               initWithImage:[UIImage imageNamed:@"rupay.png"]];
                textField.rightView = rightImageView;
            } else if ([scheme caseInsensitiveCompare:@"visa"] == NSOrderedSame) {
                UIImageView* rightImageView = [[UIImageView alloc]
                                               initWithImage:[UIImage imageNamed:@"visa.png"]];
                textField.rightView = rightImageView;
            }
        }
        
        // All digits entered
        if (range.location == 19) {
            return NO;
        }
        
        // Reject appending non-digit characters
        if (range.length == 0 &&
            ![[NSCharacterSet decimalDigitCharacterSet]
              characterIsMember:[string characterAtIndex:0]]) {
                return NO;
            }
        
        // Auto-add hyphen before appending 4rd or 7th digit
        if (range.length == 0 &&
            (range.location == 4 || range.location == 9 || range.location == 14)) {
            textField.text =
            [NSString stringWithFormat:@"%@-%@", textField.text, string];
            return NO;
        }
        
        // Delete hyphen when deleting its trailing digit
        if (range.length == 1 &&
            (range.location == 5 || range.location == 10 || range.location == 15)) {
            range.location--;
            range.length = 2;
            textField.text = [textField.text stringByReplacingCharactersInRange:range
                                                                     withString:@""];
            return NO;
        }
    }
    
    // Expirydate sholud allow number only
    if (textField.tag == 2) {
        if (range.location == 5) {
            return NO;
        }
        NSCharacterSet* myCharSet =
        [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
        for (int i = 0; i < [string length]; i++) {
            unichar c = [string characterAtIndex:i];
            if ([myCharSet characterIsMember:c]) {
                return YES;
            } else {
                return NO;
            }
        }
    }
    
    // Card holder name sholud allow character only
    if (textField.tag == 4) {
        NSCharacterSet* myCharSet =
        [NSCharacterSet characterSetWithCharactersInString:CHARACTERS];
        for (int i = 0; i < [string length]; i++) {
            unichar c = [string characterAtIndex:i];
            if ([myCharSet characterIsMember:c]) {
                return YES;
            } else {
                return NO;
            }
        }
    }
    return YES;
}


-(IBAction)textfieldTextchange:(id)sender;
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
