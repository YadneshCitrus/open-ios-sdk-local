//
//  CTSRestRegister.m
//  RestFulltester
//
//  Created by Yadnesh Wankhede on 21/05/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import "CTSRestRegister.h"

@implementation CTSRestRegister
@synthesize path, httpMethod, requestMapping, responseMapping;

- (instancetype)initWithPath:(NSString*)urlPath
                  httpMethod:(HTTPMethod)method
              requestMapping:(CTSTypeToParameterMapping*)requestMappingArg
              responseMapping:(CTSTypeToParameterMapping*)responseMappingArg {
  self = [super init];
  if (self) {
    self.path = urlPath;
    self.httpMethod = method;
    self.requestMapping = requestMappingArg;
    self.responseMapping = responseMappingArg;
  }
  return self;
}

@end
