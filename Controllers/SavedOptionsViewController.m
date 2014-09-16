//
//  SavedOptionsViewController.m
//  SDKSandbox
//
//  Created by Mukesh Patil on 05/09/14.
//  Copyright (c) 2014 CitrusPay. All rights reserved.
//

#import "SavedOptionsViewController.h"
#import "User.h"

@interface SavedOptionsViewController ()

@property (strong, nonatomic) NSArray *userdata;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

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
    
    if (_userdata) {
        _userdata = [[NSArray alloc] init];
    }
    
    profileLayer = [[CTSProfileLayer alloc] init];
    profileLayer.delegate = self;

    [self getUserRecords];

    [self fetchPaymentInformation];
}

-(void)getUserRecords
{
    // Doing something on the main thread
    dispatch_queue_t myQueue = dispatch_queue_create("My Queue",NULL);
    dispatch_async(myQueue, ^{
        // Perform long running process
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        // Add Entry to PhoneBook Data base and reset all fields
        self.managedObjectContext = appDelegate.managedObjectContext;
        
        // initializing NSFetchRequest
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        //Setting Entity to be Queried
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"User"
                                                  inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
        NSError* error;
        
        // Query on managedObjectContext With Generated fetchRequest
        self.userdata = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            // Update the UI
            if ([self.userdata count] > 0) {
                [self.tableView reloadData];
            }
        });
    });
}


- (void)saveData:(CTSProfilePaymentRes*) paymentInfo{
    // Doing something on the main thread
    dispatch_queue_t myQueue = dispatch_queue_create("My Queue",NULL);
    dispatch_async(myQueue, ^{
        // Perform long running process
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        // Store the data
        self.managedObjectContext = appDelegate.managedObjectContext;
        
        User * newEntry = [NSEntityDescription insertNewObjectForEntityForName:@"User"
                                                        inManagedObjectContext:self.managedObjectContext];
        
        for (CTSPaymentOption* option in paymentInfo.paymentOptions) {
            newEntry.username = option.name;
            newEntry.paymentType = option.type;
            newEntry.paymentOption = option.bank;
            NSError *error;
            if (![self.managedObjectContext save:&error]) {
                NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
            }
        }
        
        //
        [self getUserRecords];


//        //  2
//        newEntry.username = paymentOptions.name;
//        newEntry.paymentType = paymentOptions.type;
//        newEntry.paymentOption = paymentOptions.bank;
//        //  3
//        NSError *error;
//        if (![self.managedObjectContext save:&error]) {
//            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
//        }else{
//            [self getUserRecords];
//        }
        //  4
        [self.view endEditing:YES];
    });
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
        
//        for (CTSPaymentOption* option in paymentInfo.paymentOptions) {
//            [self saveData:option];
//        }
        
        [self saveData:paymentInfo];

//        paymentSavedResponse = paymentInfo;
//        self.userdata = paymentInfo.paymentOptions;
//        if ([self.userdata count] > 0) {
//            [self.tableView reloadData];
//        }
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
    
//    User *user = [self.userdata objectAtIndex:indexPath.row];
//    cell.textLabel.text = user.paymentOption;
//    cell.detailTextLabel.text = user.paymentType;
    
//    cell.textLabel.text = [[self.userdata objectAtIndex:indexPath.row] valueForKey:@"type"];
////    cell.textLabel.text = [[self.userdata objectAtIndex:indexPath.row] valueForKey:@"bank"];
//    cell.detailTextLabel.text = [[self.userdata objectAtIndex:indexPath.row] valueForKey:@"name"];
    
    User *paymentOption = [self.userdata objectAtIndex:indexPath.row];
    cell.textLabel.text = paymentOption.username;
    cell.detailTextLabel.text = paymentOption.paymentType;
    
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
