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
#import "CTSAlertView.h"
#import "WebViewViewController.h"

#define REGEX_CVV @"^[0-9]*$"

@interface SavedOptionsViewController ()
@property (strong, nonatomic) NSArray *userdata;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong)  CTSAlertView* alertView;
@property(nonatomic,strong) UIActivityIndicatorView* activityView;

@end

@implementation SavedOptionsViewController
@synthesize tableView;
@synthesize rootController;
@synthesize selectedPaymentOption;
@synthesize activeTextField;
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
    
//    self.alertView = [[CTSAlertView alloc] init];
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
    [profileLayer requestPaymentInformationWithCompletionHandler:nil];
}


#pragma mark - profile layer delegates

- (void)profile:(CTSProfileLayer*)profile
didReceiveContactInfo:(CTSProfileContactRes*)contactInfo
          error:(NSError*)error {
    LogTrace(@"didReceiveContactInfo");
    // LogTrace(@"contactInfo %@", contactInfo);
    //[contactInfo logProperties];
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
    
    return cell;
}



 #pragma mark - Table view delegate
 
 // In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
 - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CTSPaymentOption *paymentOption = [self.userdata objectAtIndex:indexPath.row];
    self.selectedPaymentOption = paymentOption;
    if ([paymentOption.type isEqualToString:NETBANKING_TYPE]) {
        [self didPresentLoadingAlertView:@"Connecting..." withActivity:YES];
        [self doTokenizedPaymentNetbanking:paymentOption.token];
    }else if ([paymentOption.type isEqualToString:DEBIT_CARD_TYPE] || [paymentOption.type isEqualToString:CREDIT_CARD_TYPE]) {

        self.alertView = [[CTSAlertView alloc] initWithTitle:@"CVV"
                                                     message:@"Enter CVV number."
                                                    delegate:self
                                           cancelButtonTitle:@"Cancel"
                                           otherButtonTitles:@"OK", nil];
        self.alertView.alertViewStyle = UIAlertViewStyleSecureTextInput;
        UITextField *textField = [self.alertView textFieldAtIndex:0];
        textField.tag = 100;
        textField.delegate = self;
        textField.borderStyle = UITextBorderStyleRoundedRect;
        textField.placeholder = @"CVV";
        [self.alertView show];
    }
}

#pragma mark - UITextField delegate

- (BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)string {
    
    // CVV
    if (textField.tag == 100) {
        return [CTSUtility validateCVVNumber:textField replacementString:string shouldChangeCharactersInRange:range];
    }
    return YES;
}

#pragma mark - UIAlertView delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"OK"])
    {
        [self didPresentLoadingAlertView:@"Connecting..." withActivity:YES];
        UITextField *CVV = [alertView textFieldAtIndex:0];
        
        if ([CVV isFirstResponder]) {
            [CVV resignFirstResponder];
        }
        
        if ([self.selectedPaymentOption.type isEqualToString:DEBIT_CARD_TYPE]) {
            [self doTokenizedPaymentDebitCard:self.selectedPaymentOption.token CVVNumber:CVV.text];
        }else  if ([self.selectedPaymentOption.type isEqualToString:CREDIT_CARD_TYPE]) {
            [self doTokenizedPaymentCreditCard:self.selectedPaymentOption.token CVVNumber:CVV.text];
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
                               withContact:contactInfo
                               withAddress:addressInfo
                                    amount:@"1"
                             withReturnUrl:MLC_PAYMENT_REDIRECT_URLCOMPLETE
                             withSignature:signature
                                 withTxnId:transactionId
                     withCompletionHandler:nil];
}

- (void)doTokenizedPaymentDebitCard:(NSString*)token CVVNumber:(NSString*)CVV {
    CTSPaymentDetailUpdate* tokenizedCardInfo = [[CTSPaymentDetailUpdate alloc] init];
    CTSElectronicCardUpdate* tokenizedCard = [[CTSElectronicCardUpdate alloc] initDebitCard];
    tokenizedCard.token = token;
    tokenizedCard.cvv = TEST_TOKENIZED_CARD_CVV;
    [tokenizedCardInfo addCard:tokenizedCard];
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
                               withContact:contactInfo
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
    ((paymentInfo != nil) && ([paymentInfo.pgRespCode integerValue] == 0) &&
     (error == nil))
    ? YES
    : NO;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // Update the UI
        if (hasSuccess) {
            [self dismissLoadingAlertView:YES];
            [self didPresentLoadingAlertView:@"Connecting to the PG" withActivity:YES];
            [self loadRedirectUrl:paymentInfo.redirectUrl];
        }else{
            [self dismissLoadingAlertView:YES];
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[error.userInfo valueForKey:@"NSLocalizedDescription"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertView show];
        }
    });
}

#pragma mark - helper methods

- (void)loadRedirectUrl:(NSString*)redirectURL {
    [self dismissLoadingAlertView:YES];

    if (savedOptionsDelegate != nil && [savedOptionsDelegate respondsToSelector:@selector(navigateToTargetController:selectedPaymentOption:)]){
        [savedOptionsDelegate navigateToTargetController:redirectURL selectedPaymentOption:self.selectedPaymentOption.type];
    }
}


#pragma mark - CTSAlertView implementation

-(void)didPresentLoadingAlertView:(NSString *)message withActivity:(BOOL)activity
{
    self.alertView = [[CTSAlertView alloc] initWithTitle:@"Please wait..."
                                                 message:message
                                                delegate:self
                                       cancelButtonTitle:nil
                                       otherButtonTitles:nil];

    // Create the progress bar and add it to the alert
    if (activity) {
        self.activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        self.activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        [self.alertView setValue:self.activityView forKey:@"accessoryView"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.activityView startAnimating];
        });
        [self.alertView show];
    }
}


-(void)dismissLoadingAlertView:(BOOL)activity
{
    if (activity) {
        [self.alertView dismissWithClickedButtonIndex:0 animated:YES];
        [self.activityView stopAnimating];
    }
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
