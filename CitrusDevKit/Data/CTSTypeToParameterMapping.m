//
//  CTSTypeToParameterMapping.m
//  RestFulltester
//
//  Created by Yadnesh Wankhede on 12/06/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import "CTSTypeToParameterMapping.h"

@implementation CTSTypeToParameterMapping
@synthesize responseObjectType, parameterMapping;
- (instancetype)initWithType:(Class)type parameters:(NSDictionary*)mapping {
  self = [super init];
  if (self) {
    responseObjectType = type;
    parameterMapping = mapping;
  }
  return self;
}
@end
