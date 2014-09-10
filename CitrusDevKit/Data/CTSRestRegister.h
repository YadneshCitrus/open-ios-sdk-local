//
//  CTSRestRegister.h
//  RestFulltester
//
//  Created by Yadnesh Wankhede on 21/05/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RestLayerConstants.h"
#import "CTSTypeToParameterMapping.h"

@interface CTSRestRegister : NSObject
@property(strong) NSString* path;
@property(nonatomic, assign) HTTPMethod httpMethod;
@property(nonatomic, strong) CTSTypeToParameterMapping* requestMapping;
@property(nonatomic, strong) CTSTypeToParameterMapping* responseMapping;

- (instancetype)initWithPath:(NSString*)urlPath
                  httpMethod:(HTTPMethod)method
              requestMapping:(CTSTypeToParameterMapping*)requestMappingArg
             responseMapping:(CTSTypeToParameterMapping*)responseMappingArg;
@end
