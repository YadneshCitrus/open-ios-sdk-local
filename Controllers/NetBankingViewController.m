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

@interface NetBankingViewController ()

@property (nonatomic, strong) UIPickerView *bankSelect;
@property (nonatomic, strong)  NSArray *pickerData;
@property (nonatomic, strong)  NSString *selectedbank;

@property (nonatomic, strong)  CTSAlertView* alertView;
@end

@implementation NetBankingViewController
@synthesize rootController, payType;

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
    
    [self initialize];
}

- (void)initialize {
    // Do any additional setup after loading the view from its nib.
    
    self.alertView = [[CTSAlertView alloc] init];
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

-(IBAction)selectBankAction:(id)senderx
{
    [self addPickerView];
}

//
- (void)addPickerView
{
    self.pickerData= [[NSMutableArray alloc] initWithObjects:@"AXIS Bank",@"Central Bank Of Inida",@"Fedral Bank",@"ICICI Bank",
                 @"Indian Overseas Bank",@"United Bank of India",@"Vijaya Bank", nil];
    
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
    return [self.pickerData count];
}


#pragma mark - UIPickerViewDelegate
// these methods return either a plain NSString, a NSAttributedString, or a view (e.g UILabel) to display the row for the component.
-(NSString*) pickerView:(UIPickerView*)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [self.pickerData objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component;
{
    //Write the required logic here that should happen after you select a row in Picker View.
    [selectBankButton setTitle:[self.pickerData objectAtIndex:row] forState:UIControlStateNormal];
    [self.bankSelect setHidden:YES];
    self.selectedbank = [self.pickerData objectAtIndex:row];
}

//
-(IBAction)netBankingAction:(id)sender
{
    //
    [self.alertView createProgressionAlertWithMessage:@"Connecting..." withActivity:YES];
    
    // Doing something on the main thread
    dispatch_queue_t myQueue = dispatch_queue_create("My Queue",NULL);
    dispatch_async(myQueue, ^{
        // Perform long running process
        if ([self.selectedbank length] != 0) {
            if ([self.payType isEqualToString:MEMBER_PAY_TYPE]) {
                [self doUserNetbankingPayment];
            }if ([self.payType isEqualToString:GUEST_PAY_TYPE]) {
                [self doGuestPaymentNetbanking];
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

- (void)doUserNetbankingPayment {
    //
    CTSPaymentDetailUpdate* netBankingPaymentInfo = [[CTSPaymentDetailUpdate alloc] init];
    
    //
    CTSNetBankingUpdate* netbank = [[CTSNetBankingUpdate alloc] init];
    netbank.code = @"CID001";
    
    [netBankingPaymentInfo addNetBanking:netbank];
    
    NSString* txnId = [self createTXNId];
    
    // Doing something on the main thread
    dispatch_queue_t myQueue = dispatch_queue_create("My Queue",NULL);
    dispatch_async(myQueue, ^{
        // Perform long running process
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
             sleep(3);

             dispatch_async(dispatch_get_main_queue(), ^{
                 // Update the UI
                 [self.alertView hideCTSAlertView:YES];
                 if (hasSuccess) {
                     [self.alertView hideCTSAlertView:YES];
                     [self.alertView createProgressionAlertWithMessage:@"Connecting to the PG" withActivity:YES];
                     //
                     WebViewViewController* webViewViewController = [[WebViewViewController alloc] init];
                     webViewViewController.redirectURL = paymentInfo.redirectUrl;
                     [self.alertView hideCTSAlertView:YES];
                     [self.rootController.navigationController pushViewController:webViewViewController animated:YES];
                     [self saveData];
                 }else{
                     [self.alertView hideCTSAlertView:YES];
                     UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:error.description delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                     [alertView show];
                 }
             });
         }];
    });
}


- (void)doGuestPaymentNetbanking {
    NSString* transactionId = [self createTXNId];
    NSLog(@"transactionId:%@", transactionId);
    NSString* signature =
    [ServerSignature getSignatureFromServerTxnId:transactionId amount:@"1"];
    
    CTSPaymentDetailUpdate* paymentInfo = [[CTSPaymentDetailUpdate alloc] init];
    CTSNetBankingUpdate* netBank = [[CTSNetBankingUpdate alloc] init];
    
    netBank.code = TEST_NETBAK_CODE;
    [paymentInfo addNetBanking:netBank];
    
    // Doing something on the main thread
    dispatch_queue_t myQueue = dispatch_queue_create("My Queue",NULL);
    dispatch_async(myQueue, ^{
        // Perform long running process
        [paymentlayerinfo makePaymentUsingGuestFlow:paymentInfo
                                        withContact:contactInfo
                                             amount:@"1"
                                        withAddress:addressInfo
                                      withReturnUrl:MLC_GUESTCHECKOUT_REDIRECTURL
                                      withSignature:signature
                                          withTxnId:transactionId
                                         isDoSignup:NO
                              withCompletionHandler:^(CTSPaymentTransactionRes* paymentInfo,
                                                       NSError* error) {
                                  LogTrace(@"userName %@ ", paymentInfo);
                                  LogTrace(@"error %@ ", error);
                                  BOOL hasSuccess = ((paymentInfo != nil) && ([paymentInfo.pgRespCode integerValue] == 0) && (error == nil)) ? YES : NO;
                                  sleep(3);

                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      // Update the UI
                                      [self.alertView hideCTSAlertView:YES];
                                      if (hasSuccess) {
                                          [self.alertView hideCTSAlertView:YES];
                                          [self.alertView createProgressionAlertWithMessage:@"Connecting to the PG" withActivity:YES];
                                          //
                                          WebViewViewController* webViewViewController = [[WebViewViewController alloc] init];
                                          webViewViewController.redirectURL = paymentInfo.redirectUrl;
                                          [self.alertView hideCTSAlertView:YES];
                                          [self.rootController.navigationController pushViewController:webViewViewController animated:YES];
                                          [self saveData];
                                      }else{
                                          [self.alertView hideCTSAlertView:YES];
                                          UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:error.description delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                                          [alertView show];
                                      }
                                  });
                                  
                              }];
    });
}

- (void)saveData {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    // Store the data
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:@"NETBANKING" forKey:@"paymentOptions"];
    [dict setValue:self.selectedbank forKey:@"paymentType"];
    [appDelegate.userdata addObject:dict];
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
