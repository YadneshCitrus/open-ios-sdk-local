//
//  NetBankingViewController.m
//  SDKSandbox
//
//  Created by Mukesh Patil on 08/09/14.
//  Copyright (c) 2014 CitrusPay. All rights reserved.
//

#import "NetBankingViewController.h"
#import "MerchantConstants.h"
#import "TestParams.h"
#import "ServerSignature.h"
#import "CTSAlertView.h"
#import "WebViewViewController.h"
#import "AppDelegate.h"
#import "User.h"

@interface NetBankingViewController ()

@property (nonatomic, strong) UIPickerView *bankSelect;
@property (nonatomic, strong)  NSArray *pickerData;
@property (nonatomic, strong)  NSString *selectedbank;

@property (nonatomic, strong)  CTSAlertView* alertView;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@end

@implementation NetBankingViewController
@synthesize rootController, payType, issuerCode;

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
    
    //
    [self initialize];
    
    [self fetchContactInformation];

    [self fetchAddressInformation];

    [self fetchAvailableBanks];
}

- (void)initialize {
    // Do any additional setup after loading the view from its nib.
    
    self.alertView = [[CTSAlertView alloc] init];
    paymentlayerinfo = [[CTSPaymentLayer alloc] init];
    
    profileLayer = [[CTSProfileLayer alloc] init];
    profileLayer.delegate = self;
    
    /**
     *  TestData
     *
     *  use testdata for SDKSandboxTestData applicatin Target
     */
#if defined (TESTDATA_VERSION)
    [selectBankButton setTitle:TEST_NETBAK_NAME forState:UIControlStateNormal];
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

-(void)fetchAvailableBanks
{
    [selectBankButton setTitle:@"Select Bank      Loading" forState:UIControlStateNormal];
    selectBankButton.enabled = NO;
    [activityIndicatorView startAnimating];
    // Perform long running process
    self.pickerData = [[NSMutableArray alloc] init];
    
    [paymentlayerinfo requestMerchantPgSettings:VanityUrl
                          withCompletionHandler:^(CTSPgSettings* pgSettings,
                                                  NSError* error) {
                              LogTrace(@"pgSettings %@ ", pgSettings.netBanking);
                              LogTrace(@"error %@ ", error);
                              
                              dispatch_async(dispatch_get_main_queue(), ^{
                                  // Update the UI
                                  if (error == nil) {
                                      self.pickerData = pgSettings.netBanking;
                                      [activityIndicatorView stopAnimating];
                                      activityIndicatorView.hidden = YES;
                                      [selectBankButton setTitle:@"Select Bank" forState:UIControlStateNormal];
                                      selectBankButton.enabled = YES;
                                  }
                              });
                          }];
}


-(IBAction)selectBankAction:(id)senderx
{
    if ([self.pickerData count] > 0) {
        [self addPickerView];
    }
}

//
- (void)addPickerView
{
    self.bankSelect = [[UIPickerView alloc] initWithFrame:CGRectMake(10, 200, 300, 200)];
    self.bankSelect.showsSelectionIndicator = YES;
    self.bankSelect.hidden = NO;
    self.bankSelect.delegate = self;
    [self.view addSubview:self.bankSelect];
}

#pragma mark - UIPickerViewDataSource
//Columns in picker views
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView; {
    return 1;
}
//Rows in each Column

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component; {
    if(self.pickerData.count > 0){
        return [self.pickerData count];
    }
    return 0;
}


#pragma mark - UIPickerViewDelegate
// these methods return either a plain NSString, a NSAttributedString, or a view (e.g UILabel) to display the row for the component.
-(NSString*) pickerView:(UIPickerView*)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [[self.pickerData objectAtIndex:row] valueForKey:@"bankName"];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component;
{
    //Write the required logic here that should happen after you select a row in Picker View.
    [selectBankButton setTitle:[[self.pickerData objectAtIndex:row] valueForKey:@"bankName"] forState:UIControlStateNormal];
    [self.bankSelect setHidden:YES];
    self.selectedbank = [[self.pickerData objectAtIndex:row] valueForKey:@"bankName"];
    self.issuerCode = [[self.pickerData objectAtIndex:row] valueForKey:@"issuerCode"];
}

//
-(IBAction)netBankingAction:(id)sender
{
    //
    [self.alertView didPresentLoadingAlertView:@"Connecting..." withActivity:YES];
    
    /**
     *  TestData
     *
     *  use testdata for SDKSandboxTestData applicatin Target
     */
#if defined (TESTDATA_VERSION)
    self.selectedbank = TEST_NETBAK_NAME;
#endif

    if ([self.selectedbank length] != 0) {
        if ([self.payType isEqualToString:MEMBER_PAY_TYPE]) {
            [self doUserNetbankingPayment];
        }if ([self.payType isEqualToString:GUEST_PAY_TYPE]) {
            [self doGuestPaymentNetbanking];
        }
    }else{
        [self.alertView dismissLoadingAlertView:YES];
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Information" message:@"Input field can't be blank!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)doUserNetbankingPayment {
    //
    CTSPaymentDetailUpdate* netBankingPaymentInfo = [[CTSPaymentDetailUpdate alloc] init];
    
    //
    CTSNetBankingUpdate* netbank = [[CTSNetBankingUpdate alloc] init];
    
    /**
     *  TestData
     *
     *  use testdata for SDKSandboxTestData applicatin Target
     */
#if defined (TESTDATA_VERSION)
    netbank.code = TEST_NETBAK_CODE;
#else
    netbank.code = self.issuerCode;
#endif

    
    [netBankingPaymentInfo addNetBanking:netbank];
    
    NSString* txnId = [self createTXNId];
    
    [paymentlayerinfo
     makeUserPayment:netBankingPaymentInfo
     withContact:contactInfo
     withAddress:addressInfo
     amount:@"1"
     withReturnUrl:MLC_PAYMENT_REDIRECT_URLCOMPLETE
     withSignature:[ServerSignature getSignatureFromServerTxnId:txnId
                                                         amount:@"1"]
     withTxnId:txnId
     withCompletionHandler:^(CTSPaymentTransactionRes* paymentInfo,
                             NSError* error) {
         LogTrace(@"userName %@ ", paymentInfo);
         LogTrace(@"error %@ ", error);
         BOOL hasSuccess = ((paymentInfo != nil) && ([paymentInfo.pgRespCode integerValue] == 0) && (error == nil)) ? YES : NO;
         
         dispatch_async(dispatch_get_main_queue(), ^{
             [self.alertView dismissLoadingAlertView:YES];
             if (hasSuccess) {
                 [self.alertView dismissLoadingAlertView:YES];
                 [self.alertView didPresentLoadingAlertView:@"Connecting to the PG" withActivity:YES];
                 //
                 WebViewViewController* webViewViewController = [[WebViewViewController alloc] init];
                 webViewViewController.redirectURL = paymentInfo.redirectUrl;
                 [self.alertView dismissLoadingAlertView:YES];
                 [self.rootController.navigationController pushViewController:webViewViewController animated:YES];
                 if ([self.payType isEqualToString:MEMBER_PAY_TYPE]) {
                     [self saveData];
                 }
             }else{
                 [self.alertView dismissLoadingAlertView:YES];
                 UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:error.description delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                 [alertView show];
             }
         });
     }];
}


- (void)doGuestPaymentNetbanking {
    NSString* transactionId = [self createTXNId];
    NSLog(@"transactionId:%@", transactionId);
    NSString* signature =
    [ServerSignature getSignatureFromServerTxnId:transactionId amount:@"1"];
    
    CTSPaymentDetailUpdate* paymentInfo = [[CTSPaymentDetailUpdate alloc] init];
    CTSNetBankingUpdate* netBank = [[CTSNetBankingUpdate alloc] init];
    
    /**
     *  TestData
     *
     *  use testdata for SDKSandboxTestData applicatin Target
     */
#if defined (TESTDATA_VERSION)
    // Test data
    netBank.code = TEST_NETBAK_CODE;
#else
    netBank.code = self.issuerCode;
#endif

    [paymentInfo addNetBanking:netBank];
    
        [paymentlayerinfo makePaymentUsingGuestFlow:paymentInfo
                                        withContact:contactInfo
                                             amount:@"1"
                                        withAddress:addressInfo
                                      withReturnUrl:MLC_GUESTCHECKOUT_REDIRECTURL
                                      withSignature:signature
                                          withTxnId:transactionId
                              withCompletionHandler:^(CTSPaymentTransactionRes* paymentInfo,
                                                       NSError* error) {
                                  LogTrace(@"userName %@ ", paymentInfo);
                                  LogTrace(@"error %@ ", error);
                                  BOOL hasSuccess = ((paymentInfo != nil) && ([paymentInfo.pgRespCode integerValue] == 0) && (error == nil)) ? YES : NO;
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      // Update the UI
                                      [self.alertView dismissLoadingAlertView:YES];
                                      if (hasSuccess) {
                                          [self.alertView dismissLoadingAlertView:YES];
                                          [self.alertView didPresentLoadingAlertView:@"Connecting to the PG" withActivity:YES];
                                          //
                                          WebViewViewController* webViewViewController = [[WebViewViewController alloc] init];
                                          webViewViewController.redirectURL = paymentInfo.redirectUrl;
                                          [self.alertView dismissLoadingAlertView:YES];
                                          [self.rootController.navigationController pushViewController:webViewViewController animated:YES];
                                      }else{
                                          [self.alertView dismissLoadingAlertView:YES];
                                          UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:error.description delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                                          [alertView show];
                                      }
                                  });
                                  
                              }];
}

- (void)saveData {
    // Doing something on the main thread
    dispatch_queue_t myQueue = dispatch_queue_create("My Queue",NULL);
    dispatch_async(myQueue, ^{
        // Perform long running process
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        // Store the data
        self.managedObjectContext = appDelegate.managedObjectContext;
        
        //  1
        User * newEntry = [NSEntityDescription insertNewObjectForEntityForName:@"User"
                                                        inManagedObjectContext:self.managedObjectContext];
        //  2
        newEntry.username = @"username";
        newEntry.paymentType = self.selectedbank;
        newEntry.paymentOption = @"NETBANKING";
        //  3
        NSError *error;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
        //  4
        [self.view endEditing:YES];
    });
}

- (NSString*)createTXNId {
    NSString* transactionId;
    long long CurrentTime =
    (long long)([[NSDate date] timeIntervalSince1970] * 1000);
    transactionId = [NSString stringWithFormat:@"CTS%lld", CurrentTime];
    // transactionId = [NSString stringWithFormat:@"%lld", 820];
    
    return transactionId;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
