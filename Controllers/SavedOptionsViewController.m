//
//  SavedOptionsViewController.m
//  SDKSandbox
//
//  Created by Mukesh Patil on 05/09/14.
//  Copyright (c) 2014 CitrusPay. All rights reserved.
//

#import "SavedOptionsViewController.h"
#import "TestParams.h"
#import "ServerSignature.h"
#import "WebViewViewController.h"
#import "UIUtility.h"


#define REGEX_CVV @"^[0-9]*$"

@interface SavedOptionsViewController ()
@property (strong, nonatomic) NSArray *userdata;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (assign, nonatomic) NSIndexPath *checkedIndexPath;
@end

@implementation SavedOptionsViewController
@synthesize tableView;
@synthesize selectedPaymentOption;
@synthesize savedOptionsDelegate;

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
    
    _userdata = [[NSArray alloc] init];
    
    [self getUserRecords];

    [self initialize];

    [self fetchPaymentInformation];
}

#pragma mark - initialize implementation

- (void)initialize {
    // Do any additional setup after loading the view from its nib.
    
    paymentlayerinfo = [[CTSPaymentLayer alloc] init];
    paymentlayerinfo.delegate = self;
    
    profileLayer = [[CTSProfileLayer alloc] init];
    profileLayer.delegate = self;
    
    [self fetchContactInformation];
    
    [self fetchAddressInformation];
    
}

-(void)fetchContactInformation
{
    aContactInfo = [[CTSContactUpdate alloc] init];
    
    /**
     *  TestData
     *
     *  use testdata for SDKSandboxTestData applicatin Target
     */
#if defined (TESTDATA_VERSION)
    aContactInfo.firstName = TEST_FIRST_NAME;
    aContactInfo.lastName = TEST_LAST_NAME;
    aContactInfo.email = TEST_EMAIL;
    aContactInfo.mobile = TEST_MOBILE;
#else
    [profileLayer requestContactInformationWithCompletionHandler:nil];
    
    aContactInfo.firstName = contactSavedResponse.firstName;
    aContactInfo.lastName = contactSavedResponse.lastName;
    aContactInfo.email = contactSavedResponse.email;
    aContactInfo.mobile = contactSavedResponse.mobile;
#endif
    
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

-(void)fetchPaymentInformation
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [profileLayer requestPaymentInformationWithCompletionHandler:nil];
}


#pragma mark - profile layer delegates

- (void)profile:(CTSProfileLayer*)profile
didReceiveContactInfo:(CTSProfileContactRes*)contactInfo
          error:(NSError*)error {
    LogTrace(@"didReceiveContactInfo");
    // LogTrace(@"contactInfo %@", contactInfo);
    //[contactInfo logProperties];
    
    contactSavedResponse = contactInfo;

    LogTrace(@"contactInfo %@", error);
}


- (void)profile:(CTSProfileLayer*)profile
didReceivePaymentInformation:(CTSProfilePaymentRes*)paymentInfo
          error:(NSError*)error {
    if (error == nil) {
        LogTrace(@" paymentInfo.type %@", paymentInfo.type);
        LogTrace(@" paymentInfo.defaultOption %@", paymentInfo.defaultOption);
        
        [self saveData:paymentInfo];
        
    } else {
        LogTrace(@"error received %@", error);
    }
}

- (void)profile:(CTSProfileLayer*)profile
didUpdateContactInfoError:(NSError*)error {
}

- (void)profile:(CTSProfileLayer*)profile
didUpdatePaymentInfoError:(NSError*)error {
    LogTrace(@"didUpdatePaymentInfoError error %@ ", error);
    [profileLayer requestPaymentInformationWithCompletionHandler:nil];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.userdata count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    CTSPaymentOption *paymentOption = [self.userdata objectAtIndex:indexPath.row];
    cell.textLabel.text = paymentOption.name;
    cell.detailTextLabel.text = paymentOption.type;
    
    if(self.checkedIndexPath != nil){
        if(indexPath.row == self.checkedIndexPath.row){
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }else{
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }

    return cell;
}



 #pragma mark - Table view delegate
 
 // In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
 - (void)tableView:(UITableView *)atableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CTSPaymentOption *paymentOption = [self.userdata objectAtIndex:indexPath.row];
    self.selectedPaymentOption = paymentOption;
    if ([paymentOption.type isEqualToString:MLC_PROFILE_PAYMENT_NETBANKING_TYPE]) {
        self.checkedIndexPath = indexPath;
        [tableView reloadData];

        [UIUtility didPresentLoadingAlertView:@"Connecting..." withActivity:YES];
        [self doTokenizedPaymentNetbanking:paymentOption.token];
    }else if ([paymentOption.type isEqualToString:MLC_PROFILE_PAYMENT_DEBIT_TYPE] || [paymentOption.type isEqualToString:MLC_PROFILE_PAYMENT_CREDIT_TYPE]) {
        [self didPresentInputAlertView:@"CVV" message:@"Enter CVV number."];
        self.checkedIndexPath = indexPath;
    }
}

#pragma mark - UITextField delegate

- (BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)string {
    
    // CVV
    if (textField.tag == 100) {
        return [CTSUtility validateCVVNumber:textField  cardNumber:self.selectedPaymentOption.number replacementString:string shouldChangeCharactersInRange:range];
    }
    return YES;
}

#pragma mark - UIAlertView delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"OK"])
    {
        UITextField *CVVTextField = [alertView textFieldAtIndex:0];
        [CVVTextField resignFirstResponder];

        if([CVVTextField.text length] != 0){
            [tableView reloadData];

            [UIUtility didPresentLoadingAlertView:@"Connecting..." withActivity:YES];

            if ([self.selectedPaymentOption.type isEqualToString:MLC_PROFILE_PAYMENT_DEBIT_TYPE]) {
                [self doTokenizedPaymentDebitCard:self.selectedPaymentOption.token CVVNumber:CVVTextField.text];
            }else  if ([self.selectedPaymentOption.type isEqualToString:MLC_PROFILE_PAYMENT_CREDIT_TYPE]) {
                [self doTokenizedPaymentCreditCard:self.selectedPaymentOption.token CVVNumber:CVVTextField.text];
            }
        }else{
            [UIUtility didPresentInfoAlertView:@"Input field can't be blank!"];
        }
    }
}


#pragma mark - PaymentLayer implementation

- (void)doTokenizedPaymentNetbanking:(NSString*)token {
    NSString* transactionId = [CTSUtility createTXNId];
    NSLog(@"transactionId:%@", transactionId);
    NSString* signature = [ServerSignature getSignatureFromServerTxnId:transactionId amount:@"1"];
    CTSPaymentDetailUpdate* tokenizedNetbankingInfo = [[CTSPaymentDetailUpdate alloc] init];
    CTSNetBankingUpdate* tokenizednetbank = [[CTSNetBankingUpdate alloc] init];
    tokenizednetbank.token = token;
    [tokenizedNetbankingInfo addNetBanking:tokenizednetbank];
    
    [paymentlayerinfo makeTokenizedPayment:tokenizedNetbankingInfo
                               withContact:aContactInfo
                               withAddress:addressInfo
                                    amount:@"1"
                             withReturnUrl:MLC_PAYMENT_REDIRECT_URLCOMPLETE
                             withSignature:signature
                                 withTxnId:transactionId
                     withCompletionHandler:nil];
}

- (void)doTokenizedPaymentDebitCard:(NSString*)token CVVNumber:(NSString*)CVV {
    NSString* transactionId = [CTSUtility createTXNId];
    
    NSString* signature = [ServerSignature getSignatureFromServerTxnId:transactionId amount:@"1"];
    
    CTSPaymentDetailUpdate* tokenizedCardInfo = [[CTSPaymentDetailUpdate alloc] init];
    CTSElectronicCardUpdate* tokenizedCard = [[CTSElectronicCardUpdate alloc] initDebitCard];
    tokenizedCard.token = token;
    tokenizedCard.cvv = CVV;
    [tokenizedCardInfo addCard:tokenizedCard];
    
    [paymentlayerinfo makeTokenizedPayment:tokenizedCardInfo
                               withContact:aContactInfo
                               withAddress:addressInfo
                                    amount:@"1"
                             withReturnUrl:MLC_PAYMENT_REDIRECT_URLCOMPLETE
                             withSignature:signature
                                 withTxnId:transactionId
                     withCompletionHandler:nil];

}

- (void)doTokenizedPaymentCreditCard:(NSString*)token CVVNumber:(NSString*)CVV{
    NSString* transactionId = [CTSUtility createTXNId];
    NSLog(@"transactionId:%@", transactionId);
    
    NSString* signature = [ServerSignature getSignatureFromServerTxnId:transactionId amount:@"1"];
    
    CTSPaymentDetailUpdate* tokenizedCardInfo = [[CTSPaymentDetailUpdate alloc] init];
    CTSElectronicCardUpdate* tokenizedCard =
    [[CTSElectronicCardUpdate alloc] initCreditCard];
    tokenizedCard.token = token;
    tokenizedCard.cvv = CVV;
    [tokenizedCardInfo addCard:tokenizedCard];
    
    [paymentlayerinfo makeTokenizedPayment:tokenizedCardInfo
                               withContact:aContactInfo
                               withAddress:addressInfo
                                    amount:@"1"
                             withReturnUrl:MLC_PAYMENT_REDIRECT_URLCOMPLETE
                             withSignature:signature
                                 withTxnId:transactionId
                     withCompletionHandler:nil];
}

#pragma mark - Payment layer delegates

- (void)payment:(CTSPaymentLayer*)layer
didMakeTokenizedPayment:(CTSPaymentTransactionRes*)paymentInfo
          error:(NSError*)error {
    NSLog(@"%@", paymentInfo);
    LogTrace(@" %@ ", error);
    BOOL hasSuccess =
    ((paymentInfo != nil) && ([paymentInfo.pgRespCode integerValue] == 0) && (error == nil)) ? YES : NO;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // Update the UI
        [UIUtility dismissLoadingAlertView:YES];
        if (hasSuccess && error.code != ServerErrorWithCode) {
            [UIUtility didPresentLoadingAlertView:@"Connecting to the PG" withActivity:YES];
            [self loadRedirectUrl:paymentInfo.redirectUrl];
        }else{
            [UIUtility didPresentErrorAlertView:error];
        }
    });
}

#pragma mark - helper methods

- (void)loadRedirectUrl:(NSString*)redirectURL {
    [UIUtility dismissLoadingAlertView:YES];

    if (savedOptionsDelegate != nil && [savedOptionsDelegate respondsToSelector:@selector(navigateToTargetController:)]){
        [savedOptionsDelegate navigateToTargetController:redirectURL];
    }
}


#pragma mark - AlertView implementation

-(void)didPresentInputAlertView:(NSString *)title message:(NSString *)message
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                           message:message
                                          delegate:self
                                 cancelButtonTitle:@"Cancel"
                                 otherButtonTitles:@"OK", nil];
    alertView.alertViewStyle = UIAlertViewStyleSecureTextInput;
    UITextField *textField = [alertView textFieldAtIndex:0];
    textField.tag = 100;
    textField.delegate = self;
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.placeholder = title;
    [alertView show];
}


#pragma mark - UITextField delegates

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - core data implementation

-(void)getUserRecords
{
    // Doing something on the main thread
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        // Perform long running process
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        // Add Entry to PhoneBook Data base and reset all fields
        self.managedObjectContext = appDelegate.managedObjectContext;
        
        // initializing NSFetchRequest
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        //Setting Entity to be Queried
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"CTSPaymentOption"
                                                  inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
        NSError* error;
        
        // Query on managedObjectContext With Generated fetchRequest
        self.userdata = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            // Update the UI
            if ([self.userdata count]) {
                [self.tableView reloadData];
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            }
        });
    });
}


- (void)saveData:(CTSProfilePaymentRes*) paymentInfo{
    // Doing something on the main thread
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        // Perform long running process
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        // Store the data
        self.managedObjectContext = appDelegate.managedObjectContext;
        
        // initializing NSFetchRequest
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        //Setting Entity to be Queried
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"CTSPaymentOption"
                                                  inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
        NSError* error;
        // Query on managedObjectContext With Generated fetchRequest
        NSArray *array = [[NSArray alloc] init];
        array = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        BOOL isNewRecord = NO;
        if ([array count]) {
            for (int i = 0; i < [paymentInfo.paymentOptions count]; i++) {
                CTSPaymentOption *localOption;
                if ([array count]>i) {
                    localOption = [array objectAtIndex:i];
                }
                CTSPaymentOption *responseOption = [paymentInfo.paymentOptions objectAtIndex:i];
                if (![localOption.token isEqualToString:responseOption.token]) {
                    [self insertObject:responseOption];
                    isNewRecord = YES;
                }
            }
        }else{
            for (int i = 0; i < [paymentInfo.paymentOptions count]; i++) {
                CTSPaymentOption *responseOption = [paymentInfo.paymentOptions objectAtIndex:i];
                [self insertObject:responseOption];
                isNewRecord = YES;
            }
        }
        if (isNewRecord) {
            [self getUserRecords];
        }
    });
}


- (void)insertObject:(CTSPaymentOption*) paymentInfo{
    
    @try {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        // Store the data
        self.managedObjectContext = appDelegate.managedObjectContext;
        
        CTSPaymentOption * newEntry = [NSEntityDescription insertNewObjectForEntityForName:@"CTSPaymentOption"
                                                                    inManagedObjectContext:self.managedObjectContext];
        newEntry.type = paymentInfo.type;
        newEntry.name = paymentInfo.name;
        newEntry.owner = paymentInfo.owner;
        newEntry.bank = paymentInfo.bank;
        newEntry.number = paymentInfo.number;
        newEntry.expiryDate = paymentInfo.expiryDate;
        newEntry.scheme = paymentInfo.scheme;
        newEntry.token = paymentInfo.token;
        newEntry.mmid = paymentInfo.mmid;
        newEntry.impsRegisteredMobile = paymentInfo.impsRegisteredMobile;
        newEntry.cvv = paymentInfo.cvv;
        newEntry.code = paymentInfo.code;
        
        NSError *error;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
        [self.view endEditing:YES];
    }
    @catch (NSException *exception) {
        LogTrace(@"NSException %@",exception);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
