//
//  CTSRestCoreResponse.h
//  CTSRestKit
//
//  Created by Yadnesh Wankhede on 30/07/14.
//  Copyright (c) 2014 CitrusPay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CTSRestCoreResponse : NSObject
@property(strong) NSString* responseString;
@property(assign) int requestId;
@property(strong) NSError* error;
@end
