//
//  User.h
//  SDKSandbox
//
//  Created by Mukesh Patil on 12/09/14.
//  Copyright (c) 2014 CitrusPay. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface User : NSManagedObject
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *paymentType;
@property (strong, nonatomic) NSString *paymentOption;
@end
