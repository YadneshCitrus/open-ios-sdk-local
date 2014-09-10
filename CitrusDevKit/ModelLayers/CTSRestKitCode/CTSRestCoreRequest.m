//
//  CTSRestRequest.m
//  CTSRestKit
//
//  Created by Yadnesh Wankhede on 30/07/14.
//  Copyright (c) 2014 CitrusPay. All rights reserved.
//

#import "CTSRestCoreRequest.h"

@implementation CTSRestCoreRequest
@synthesize requestJson, urlPath, parameters, headers, requestId, httpMethod;

- (instancetype)initWithPath:(NSString*)path
                   requestId:(int)reqId
                     headers:(NSDictionary*)reqHeaders
                  parameters:(NSDictionary*)params
                        json:(NSString*)json
                  httpMethod:(HTTPMethod)method {
  self = [super init];
  if (self) {
    requestJson = json;
    urlPath = path;
    parameters = [params mutableCopy];
    headers = [reqHeaders mutableCopy];
    requestId = reqId;
    httpMethod = method;
  }
  return self;
}
@end
