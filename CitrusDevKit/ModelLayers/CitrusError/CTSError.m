//
//  CTSError.m
//  CTS iOS Sdk
//
//  Created by Yadnesh Wankhede on 26/06/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import "CTSError.h"

@implementation CTSError

+ (NSError*)getErrorForCode:(CTSErrorCode)code {
  NSString* errorDescription = @"CitrusDefaultError";

  switch (code) {
    case UserNotSignedIn:
      errorDescription = @"This proccess cannot be completed without signing "
          @"in,please signin";
      break;
    case EmailNotValid:
      errorDescription =
          @"email adress format not valid,expected e.g. rob@gmail.com";
      break;
    case MobileNotValid:
      errorDescription = @"mobile number not valid, expected 10 digits";
      break;
    case CvvNotValid:
      errorDescription = @"cvv format not valid, expected 3 digits for non "
          @"amex and 4 for amex";
      break;
    case CardNumberNotValid:
      errorDescription = @"card number not valid";
      break;
    case ExpiryDateNotValid:
      errorDescription = @"wrong expiry date format,expected - \"mm/yyyy\" ";
      break;
    case ServerErrorWithCode:
      errorDescription = @"server sent error code";
    case InvalidParameter:
      errorDescription = @"invalid parameter passed to method";
    case OauthTokenExpired:
      errorDescription = @"Oauth Token expired, Please refresh it from server";
    case CantFetchSignupToken:
      errorDescription = @"Can not fetch Signup Oauth token from merchant";
      case TokenMissing:
          errorDescription = @"Token for payment is missing";

    default:
      break;
  }
  NSDictionary* userInfo = @{NSLocalizedDescriptionKey : errorDescription};

  return
      [NSError errorWithDomain:CITRUS_ERROR_DOMAIN code:code userInfo:userInfo];
}

+ (NSError*)getServerErrorWithCode:(int)errorCode
                          withInfo:(NSDictionary*)information {
  NSMutableDictionary* userInfo =
      [[NSMutableDictionary alloc] initWithDictionary:information];

  [userInfo addEntriesFromDictionary:@{
    NSLocalizedDescriptionKey :
        [NSString stringWithFormat:@"Server threw an error,code %d", errorCode]
        }];

  return [NSError errorWithDomain:CITRUS_ERROR_DOMAIN
                             code:ServerErrorWithCode
                         userInfo:userInfo];
}


+(NSString *)getFakeJsonForCode:(CTSErrorCode)errorCode{
    NSString* fakeErrorJson = nil;
    
    switch (errorCode) {
        case InternetDown:
            fakeErrorJson = @"{\"description\":\"could not connect to internet\",\"type\":\"server error\"}";
            break;

        default:
            fakeErrorJson = @"{\"description\":\"NA\",\"type\":\"NA\"}";

            break;
    }
    return fakeErrorJson;

}


@end
