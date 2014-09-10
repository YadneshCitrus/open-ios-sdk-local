//
//  CTSRestPluginBase.h
//  CTSRestKit
//
//  Created by Yadnesh Wankhede on 30/07/14.
//  Copyright (c) 2014 CitrusPay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CTSRestCore.h"
#import "CTSOauthTokenRes.h"

#define toNSString(cts) [NSString stringWithFormat:@"%d", cts]
#define toSelector(cts) [NSValue valueWithPointer:@selector(cts)]

@interface CTSRestPluginBase : NSObject<CTSRestCoreDelegate> {
  NSDictionary* requestSelectorMap;

  CTSRestCore* restCore;
}
@property(strong) NSMutableDictionary* requestBlockCallbackMap;

- (instancetype)initWithRequestSelectorMapping:(NSDictionary*)mapping
                                       baseUrl:(NSString*)baseUrl;
- (void)addCallback:(id)callBack forRequestId:(int)reqId;
- (id)retrieveAndRemoveCallbackForReqId:(int)reqId;
@end
