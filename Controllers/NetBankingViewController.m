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
#import "UIUtility.h"
#import "WebViewViewController.h"
#import "AppDelegate.h"

@interface NetBankingViewController ()

@property (nonatomic, strong) UIPickerView *bankSelect;
@property (nonatomic, strong)  NSArray *pickerData;
@property (nonatomic, strong)  NSString *selectedbank;
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
    if (!self.bankSelect) {
        self.bankSelect = [[UIPickerView alloc] initWithFrame:CGRectMake(10, 200, 300, 200)];
        self.bankSelect.showsSelectionIndicator = YES;
        self.bankSelect.hidden = NO;
        self.bankSelect.delegate = self;
        [self.view addSubview:self.bankSelect];
    }else{
        [self.bankSelect setHidden:NO];
    }
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
    
    if ([self.selectedbank length] != 0) {
        [self.bankSelect setHidden:YES];
        [UIUtility didPresentLoadingAlertView:@"Connecting..." withActivity:YES];

        if ([self.payType isEqualToString:MEMBER_PAY_TYPE]) {
            [self doUserNetbankingPayment];
        }if ([self.payType isEqualToString:GUEST_PAY_TYPE]) {
            [self doGuestPaymentNetbanking];
        }
    }else{
        [UIUtility didPresentInfoAlertView:@"Input field can't be blank!"];
    }
}

- (void)doUserNetbankingPayment {
    //
    CTSPaymentDetailUpdate* netBankingPaymentInfo = [[CTSPaymentDetailUpdate alloc] init];
    
    //
    CTSNetBankingUpdate* netbank = [[CTSNetBankingUpdate alloc] init];
    
    netbank.code = self.issuerCode;
    netbank.bank = self.selectedbank;
    
    [netBankingPaymentInfo addNetBanking:netbank];
    
    NSString* txnId = [CTSUtility createTXNId];
    
    [paymentlayerinfo
     makeUserPayment:netBankingPaymentInfo
     withContact:aContactInfo
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
             [UIUtility dismissLoadingAlertView:YES];
             if (hasSuccess && error.code != ServerErrorWithCode) {
                 [UIUtility didPresentLoadingAlertView:@"Connecting to the PG" withActivity:YES];
                 WebViewViewController* webViewViewController = [[WebViewViewController alloc] init];
                 webViewViewController.redirectURL = paymentInfo.redirectUrl;
                 [UIUtility dismissLoadingAlertView:YES];
                 [self.rootController.navigationController pushViewController:webViewViewController animated:YES];
             }else{
                 [UIUtility didPresentErrorAlertView:error];
             }
         });
     }];
}


- (void)doGuestPaymentNetbanking {
    NSString* transactionId = [CTSUtility createTXNId];
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
                                        withContact:aContactInfo
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
                                      [UIUtility dismissLoadingAlertView:YES];
                                      if (hasSuccess && error.code != ServerErrorWithCode) {
                                          [UIUtility didPresentLoadingAlertView:@"Connecting to the PG" withActivity:YES];
                                          WebViewViewController* webViewViewController = [[WebViewViewController alloc] init];
                                          webViewViewController.redirectURL = paymentInfo.redirectUrl;
                                          [UIUtility dismissLoadingAlertView:YES];
                                          [self.rootController.navigationController pushViewController:webViewViewController animated:YES];
                                      }else{                                          
                                          [UIUtility didPresentErrorAlertView:error];
                                      }
                                  });
                                  
                              }];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
