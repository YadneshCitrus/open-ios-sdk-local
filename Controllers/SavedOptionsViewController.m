//
//  SavedOptionsViewController.m
//  SDKSandbox
//
//  Created by Mukesh Patil on 05/09/14.
//  Copyright (c) 2014 CitrusPay. All rights reserved.
//

#import "SavedOptionsViewController.h"
#import "CTSAlertView.h"

@interface SavedOptionsViewController ()

@property (strong, nonatomic) NSArray *userdata;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong)  CTSAlertView* alertView;

@end

@implementation SavedOptionsViewController
@synthesize tableView;

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
    
    profileLayer = [[CTSProfileLayer alloc] init];
    profileLayer.delegate = self;

    [self getUserRecords];

    [self fetchPaymentInformation];
}

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
                [self.alertView dismissLoadingAlertView:YES];
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


-(void)fetchPaymentInformation
{
    [self.alertView didPresentLoadingAlertView:@"Syncing data..." withActivity:YES];

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


/*
 #pragma mark - Table view delegate
 
 // In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
 - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Navigation logic may go here, for example:
 // Create the next view controller.
 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
 
 // Pass the selected object to the new view controller.
 
 // Push the view controller.
 [self.navigationController pushViewController:detailViewController animated:YES];
 }
 */

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
