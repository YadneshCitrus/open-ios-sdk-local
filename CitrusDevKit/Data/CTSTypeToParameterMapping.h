//
//  CTSTypeToParameterMapping.h
//  RestFulltester
//
//  Created by Yadnesh Wankhede on 12/06/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CTSTypeToParameterMapping : NSObject
@property(strong) Class responseObjectType;
@property(strong) NSDictionary* parameterMapping;
- (instancetype)initWithType:(Class)type parameters:(NSDictionary*)mapping;
@end
