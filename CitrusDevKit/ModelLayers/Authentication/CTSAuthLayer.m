//
//  CTSAuthLayer.m
//  RestFulltester
//
//  Created by Yadnesh Wankhede on 23/05/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import "CTSAuthLayer.h"
#import "RestLayerConstants.h"
#import "CTSAuthLayerConstants.h"
#import "CTSSignUpRes.h"
#import "UserLogging.h"
#import "CTSUtility.h"
#import "CTSError.h"
#import "CTSOauthManager.h"
#import "NSObject+logProperties.h"
#import "CTSSignupState.h"

#import <CommonCrypto/CommonDigest.h>
#ifndef MIN
#import <NSObjCRuntime.h>
#endif

@implementation CTSAuthLayer
@synthesize delegate;

#pragma mark - public methods

- (void)requestResetPassword:(NSString*)userNameArg
           completionHandler:(ASResetPasswordCallback)callBack;
{
  [self addCallback:callBack forRequestId:RequestForPasswordResetReqId];

  OauthStatus* oauthStatus = [CTSOauthManager fetchSignupTokenStatus];
  NSString* oauthToken = oauthStatus.oauthToken;

  if (oauthStatus.error != nil) {
    [self resetPasswordHelper:oauthStatus.error];
  }

  if (![CTSUtility validateEmail:userNameArg]) {
    [self resetPasswordHelper:[CTSError getErrorForCode:EmailNotValid]];
    return;
  }
  CTSRestCoreRequest* request = [[CTSRestCoreRequest alloc]
      initWithPath:MLC_REQUEST_CHANGE_PWD_REQ_PATH
         requestId:RequestForPasswordResetReqId
           headers:[CTSUtility readOauthTokenAsHeader:oauthToken]
        parameters:@{MLC_REQUEST_CHANGE_PWD_QUERY_USERNAME : userNameArg}
              json:nil
        httpMethod:POST];

  [restCore requestAsyncServer:request];
}

- (void)requestInternalSignupMobile:(NSString*)mobile email:(NSString*)email {
  if (![CTSUtility validateEmail:email]) {
    [self signupHelperUsername:userNameSignup
                         oauth:[CTSOauthManager readOauthToken]
                         error:[CTSError getErrorForCode:EmailNotValid]];
    return;
  }
  if (![CTSUtility validateMobile:mobile]) {
    [self signupHelperUsername:userNameSignup
                         oauth:[CTSOauthManager readOauthToken]
                         error:[CTSError getErrorForCode:MobileNotValid]];
    return;
  }

  CTSRestCoreRequest* request = [[CTSRestCoreRequest alloc]
      initWithPath:MLC_SIGNUP_REQ_PATH
         requestId:SignupStageOneReqId
           headers:[CTSUtility readSignupTokenAsHeader]
        parameters:@{
          MLC_SIGNUP_QUERY_EMAIL : email,
          MLC_SIGNUP_QUERY_MOBILE : mobile
        } json:nil
        httpMethod:POST];

  [restCore requestAsyncServer:request];
}

- (void)requestSignUpWithEmail:(NSString*)email
                        mobile:(NSString*)mobile
                      password:(NSString*)password
             completionHandler:(ASSignupCallBack)callBack {
  [self addCallback:callBack forRequestId:SignupOauthTokenReqId];

  if (![CTSUtility validateEmail:email]) {
    [self signupHelperUsername:userNameSignup
                         oauth:[CTSOauthManager readOauthToken]
                         error:[CTSError getErrorForCode:EmailNotValid]];
    return;
  }
  if (![CTSUtility validateMobile:mobile]) {
    [self signupHelperUsername:userNameSignup
                         oauth:[CTSOauthManager readOauthToken]
                         error:[CTSError getErrorForCode:MobileNotValid]];
    return;
  }

  userNameSignup = email;
  mobileSignUp = mobile;
  if (password == nil) {
    passwordSignUp = [self generatePseudoRandomPassword];
  } else {
    passwordSignUp = password;
  }

  //  CTSSignupState* signupState = [[CTSSignupState alloc] initWithEmail:email
  //                                                               mobile:mobile
  //                                                             password:password];
  //
  //  long index = [self addDataToCacheAtAutoIndex:signupState];

  [self requestSignUpOauthToken];
}

- (void)requestSignUpOauthToken {
  ENTRY_LOG
  wasSignupCalled = YES;

  CTSRestCoreRequest* request = [[CTSRestCoreRequest alloc]
      initWithPath:MLC_OAUTH_TOKEN_SIGNUP_REQ_PATH
         requestId:SignupOauthTokenReqId
           headers:nil
        parameters:MLC_OAUTH_TOKEN_SIGNUP_QUERY_MAPPING
              json:nil
        httpMethod:POST];

  [restCore requestAsyncServer:request];

  EXIT_LOG
}

- (void)requestSigninWithUsername:(NSString*)userNameArg
                         password:(NSString*)password
                completionHandler:(ASSigninCallBack)callBack {
  /**
   *  flow sigin in
   check oauth expiry time if oauth token is expired call for refresh token and
   send refresh token
   if refresh token has error then proceed for normal signup

   */

  [self addCallback:callBack forRequestId:SigninOauthTokenReqId];

  if (![CTSUtility validateEmail:userNameArg]) {
    [self signinHelperUsername:userNameArg
                         oauth:nil
                         error:[CTSError getErrorForCode:EmailNotValid]];
    return;
  }

  userNameSignIn = userNameArg;
  NSDictionary* parameters = @{
    MLC_OAUTH_TOKEN_QUERY_CLIENT_ID : MLC_OAUTH_TOKEN_SIGNIN_CLIENT_ID,
    MLC_OAUTH_TOKEN_QUERY_CLIENT_SECRET : MLC_OAUTH_TOKEN_SIGNIN_CLIENT_SECRET,
    MLC_OAUTH_TOKEN_QUERY_GRANT_TYPE : MLC_SIGNIN_GRANT_TYPE,
    MLC_OAUTH_TOKEN_SIGNIN_QUERY_PASSWORD : password,
    MLC_OAUTH_TOKEN_SIGNIN_QUERY_USERNAME : userNameArg
  };

  CTSRestCoreRequest* request =
      [[CTSRestCoreRequest alloc] initWithPath:MLC_OAUTH_TOKEN_SIGNUP_REQ_PATH
                                     requestId:SigninOauthTokenReqId
                                       headers:nil
                                    parameters:parameters
                                          json:nil
                                    httpMethod:POST];

  [restCore requestAsyncServer:request];
}

- (void)usePassword:(NSString*)password
     hashedUsername:(NSString*)hashedUsername {
  ENTRY_LOG

  NSString* oauthToken = [CTSOauthManager readOauthTokenWithExpiryCheck];
  if (oauthToken == nil) {
    [self signupHelperUsername:userNameSignup
                         oauth:[CTSOauthManager readOauthToken]
                         error:[CTSError getErrorForCode:OauthTokenExpired]];
  }

  CTSRestCoreRequest* request = [[CTSRestCoreRequest alloc]
      initWithPath:MLC_CHANGE_PASSWORD_REQ_PATH
         requestId:SignupChangePasswordReqId
           headers:[CTSUtility readOauthTokenAsHeader:oauthToken]
        parameters:@{
          MLC_CHANGE_PASSWORD_QUERY_OLD_PWD : hashedUsername,
          MLC_CHANGE_PASSWORD_QUERY_NEW_PWD : password
        } json:nil
        httpMethod:PUT];

  [restCore requestAsyncServer:request];
  EXIT_LOG
}

- (void)requestChangePasswordUserName:(NSString*)userName
                          oldPassword:(NSString*)oldPassword
                          newPassword:(NSString*)newPassword
                    completionHandler:(ASChangePassword)callback {
  ENTRY_LOG
  [self addCallback:callback forRequestId:ChangePasswordReqId];

  OauthStatus* oauthStatus = [CTSOauthManager fetchSignupTokenStatus];
  if (oauthStatus.error != nil) {
    [self changePasswordHelper:oauthStatus.error];
  }

  CTSRestCoreRequest* request = [[CTSRestCoreRequest alloc]
      initWithPath:MLC_CHANGE_PASSWORD_REQ_PATH
         requestId:ChangePasswordReqId
           headers:[CTSUtility readOauthTokenAsHeader:oauthStatus.oauthToken]
        parameters:@{
          MLC_CHANGE_PASSWORD_QUERY_OLD_PWD : oldPassword,
          MLC_CHANGE_PASSWORD_QUERY_NEW_PWD : newPassword
        } json:nil
        httpMethod:PUT];

  [restCore requestAsyncServer:request];
  EXIT_LOG
}

- (void)requestIsUserCitrusMemberUsername:(NSString*)email
                        completionHandler:
                            (ASIsUserCitrusMemberCallback)callback {
  [self addCallback:callback forRequestId:IsUserCitrusMemberReqId];
  if (![CTSUtility validateEmail:email]) {
    [self isUserCitrusMemberHelper:NO
                             error:[CTSError getErrorForCode:EmailNotValid]];
    return;
  }

  OauthStatus* oauthStatus = [CTSOauthManager fetchSignupTokenStatus];

  if (oauthStatus.error != nil) {
    [self isUserCitrusMemberHelper:NO error:oauthStatus.error];
  }

  CTSRestCoreRequest* request = [[CTSRestCoreRequest alloc]
      initWithPath:MLC_IS_MEMBER_REQ_PATH
         requestId:IsUserCitrusMemberReqId
           headers:[CTSUtility readOauthTokenAsHeader:oauthStatus.oauthToken]
        parameters:@{
          MLC_IS_MEMBER_QUERY_EMAIL : email
        } json:nil
        httpMethod:MLC_IS_MEMBER_REQ_TYPE];

  [restCore requestAsyncServer:request];
}

- (BOOL)signOut {
  [CTSOauthManager resetOauthData];
  return YES;
}

- (BOOL)isAnyoneSignedIn {
  NSString* signInOauthToken = [CTSOauthManager readOauthTokenWithExpiryCheck];
  if (signInOauthToken == nil)
    return NO;
  else
    return YES;
}

#pragma mark - pseudo password generator methods
- (NSString*)generatePseudoRandomPassword {
  // Build the password using C strings - for speed
  int length = 7;
  char* cPassword = calloc(length + 1, sizeof(char));
  char* ptr = cPassword;

  cPassword[length - 1] = '\0';

  char* lettersAlphabet = "abcdefghijklmnopqrstuvwxyz";
  ptr = appendRandom(ptr, lettersAlphabet, 2);

  char* capitalsAlphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  ptr = appendRandom(ptr, capitalsAlphabet, 2);

  char* digitsAlphabet = "0123456789";
  ptr = appendRandom(ptr, digitsAlphabet, 2);

  char* symbolsAlphabet = "!@#$%*[];?()";
  ptr = appendRandom(ptr, symbolsAlphabet, 1);

  // Shuffle the string!
  for (int i = 0; i < length; i++) {
    int r = arc4random() % length;
    char temp = cPassword[i];
    cPassword[i] = cPassword[r];
    cPassword[r] = temp;
  }
  return [NSString stringWithCString:cPassword encoding:NSUTF8StringEncoding];
}

char* appendRandom(char* str, char* alphabet, int amount) {
  for (int i = 0; i < amount; i++) {
    int r = arc4random() % strlen(alphabet);
    *str = alphabet[r];
    str++;
  }

  return str;
}

- (void)generator:(int)seed {
  seedState = seed;
}

- (int)nextInt:(int)max {
  seedState = 7 * seedState % 3001;
  return (seedState - 1) % max;
}
- (char)nextLetter {
  int n = [self nextInt:52];
  return (char)(n + ((n < 26) ? 'A' : 'a' - 26));
}
static NSData* digest(NSData* data,
                      unsigned char* (*cc_digest)(const void*,
                                                  CC_LONG,
                                                  unsigned char*),
                      CC_LONG digestLength) {
  unsigned char md[digestLength];
  (void)cc_digest([data bytes], (unsigned int)[data length], md);
  return [NSData dataWithBytes:md length:digestLength];
}

- (NSData*)md5:(NSString*)email {
  NSData* data = [email dataUsingEncoding:NSASCIIStringEncoding];
  return digest(data, CC_MD5, CC_MD5_DIGEST_LENGTH);
}

- (NSArray*)copyOfRange:(NSArray*)original from:(int)from to:(int)to {
  int newLength = to - from;
  NSArray* destination;
  if (newLength < 0) {
  } else {
    // int copy[newLength];
    destination = [original subarrayWithRange:NSMakeRange(from, newLength)];
  }
  return destination;
}
- (int)genrateSeed:(NSString*)data {
  NSMutableArray* array = [[NSMutableArray alloc] init];
  NSData* hashed = [self md5:data];
  NSUInteger len = [hashed length];
  Byte* byteData = (Byte*)malloc(len);
  [hashed getBytes:byteData length:len];

  int result1[16];
  for (int i = 0; i < 16; i++) {
    Byte b = byteData[i];  // 0xDC;
    result1[i] = (b & 0x80) > 0 ? b - 0xFF - 1 : b;
    [array addObject:[NSNumber numberWithInt:result1[i]]];
  }

  NSArray* val = [self copyOfRange:array
                              from:(unsigned int)[array count] - 3
                                to:(unsigned int)[array count]];
  NSData* arrayData = [NSKeyedArchiver archivedDataWithRootObject:val];
  NSLog(@"%@", arrayData);
  int x = 0;
  for (int i = 0; i < [val count]; i++) {
    int z = [[val objectAtIndex:(val.count - 1 - i)] intValue];
    if (z < 0) {
      z = z + 256;
    }
    z = z << (8 * i);
    x = x + z;
    NSLog(@"%d", x);
  }
  return x;
}
- (NSString*)generateBigIntegerString:(NSString*)email {
  int ran = [self genrateSeed:email];

  [self generator:ran];
  NSMutableString* large_CSV_String = [[NSMutableString alloc] init];
  for (int i = 0; i < 8; i++) {
    // Add something from the key?? Your format here.
    [large_CSV_String appendFormat:@"%c", [self nextLetter]];
  }
  NSLog(@"random password:%@", large_CSV_String);
  return large_CSV_String;
}


#pragma mark - main class methods
enum {
  SignupOauthTokenReqId,
  SigninOauthTokenReqId,
  SignupStageOneReqId,
  SignupChangePasswordReqId,
  ChangePasswordReqId,
  RequestForPasswordResetReqId,
  IsUserCitrusMemberReqId
};
- (instancetype)init {
  NSDictionary* dict = @{
    toNSString(SignupOauthTokenReqId) : toSelector(handleReqSignupOauthToken
                                                   :),
    toNSString(SigninOauthTokenReqId) : toSelector(handleReqSigninOauthToken
                                                   :),
    toNSString(SignupStageOneReqId) : toSelector(handleReqSignupStageOneComplete
                                                 :),
    toNSString(SignupChangePasswordReqId) : toSelector(handleReqUsePassword
                                                       :),
    toNSString(RequestForPasswordResetReqId) :
        toSelector(handleReqRequestForPasswordReset
                   :),
    toNSString(ChangePasswordReqId) : toSelector(handleReqChangePassword
                                                 :),
    toNSString(IsUserCitrusMemberReqId) : toSelector(handleIsUserCitrusMember
                                                     :)
  };

  self =
      [super initWithRequestSelectorMapping:dict baseUrl:CITRUS_AUTH_BASE_URL];

  return self;
}

- (void)handleReqSignupOauthToken:(CTSRestCoreResponse*)response {
  NSError* error = response.error;
  JSONModelError* jsonError;
  // signup flow
  if (error == nil) {
    CTSOauthTokenRes* resultObject =
        [[CTSOauthTokenRes alloc] initWithString:response.responseString
                                           error:&jsonError];
    [CTSOauthManager saveSignupToken:resultObject.accessToken];

    [self requestInternalSignupMobile:mobileSignUp email:userNameSignup];
  } else {
    [self signupHelperUsername:userNameSignup
                         oauth:[CTSOauthManager readOauthToken]
                         error:error];
    return;
  }
}

- (void)handleReqChangePassword:(CTSRestCoreResponse*)response {
  [self changePasswordHelper:response.error];
}

- (void)handleReqSigninOauthToken:(CTSRestCoreResponse*)response {
  NSError* error = response.error;
  JSONModelError* jsonError;
  // signup flow
  if (error == nil) {
    CTSOauthTokenRes* resultObject =
        [[CTSOauthTokenRes alloc] initWithString:response.responseString
                                           error:&jsonError];
    [resultObject logProperties];
    [CTSOauthManager saveOauthData:resultObject];
    if (wasSignupCalled == YES) {
      // in case of sign up flow

      [self usePassword:passwordSignUp
          hashedUsername:[self generateBigIntegerString:userNameSignup]];
      wasSignupCalled = NO;
    } else {
      // in case of sign in flow

      [self signinHelperUsername:userNameSignIn
                           oauth:[CTSOauthManager readOauthToken]
                           error:error];
    }
  } else {
    if (wasSignupCalled == YES) {
      // in case of sign up flow
      [self signupHelperUsername:userNameSignup
                           oauth:[CTSOauthManager readOauthToken]
                           error:error];
    } else {
      // in case of sign in flow

      [self signinHelperUsername:userNameSignIn
                           oauth:[CTSOauthManager readOauthToken]
                           error:error];
    }
  }
}

- (void)handleReqSignupStageOneComplete:(CTSRestCoreResponse*)response {
  NSError* error = response.error;

  // change password
  //[self usePassword:TEST_PASSWORD for:SET_FIRSTTIME_PASSWORD];

  // get singn in oauth token for password use use hashed email
  // use it for sending the change password so that the password is set(for
  // old password use username)

  // always use this acess token

  if (error == nil) {
    // signup flow - now sign in

    [self
        requestSigninWithUsername:userNameSignup
                         password:[self generateBigIntegerString:userNameSignup]
                completionHandler:nil];

    //    [self requestSigninWithUsername:userNameSignup
    //                           password:passwordSignUp
    //                  completionHandler:nil];

  } else {
    [self signupHelperUsername:userNameSignup
                         oauth:[CTSOauthManager readOauthToken]
                         error:error];
  }
}

- (void)handleReqUsePassword:(CTSRestCoreResponse*)response {
  LogTrace(@"password changed ");

  [self signupHelperUsername:userNameSignup
                       oauth:[CTSOauthManager readOauthToken]
                       error:response.error];
}

- (void)handleReqRequestForPasswordReset:(CTSRestCoreResponse*)response {
  LogTrace(@"password change requested");
  [self resetPasswordHelper:response.error];
}

- (void)handleIsUserCitrusMember:(CTSRestCoreResponse*)response {
  if (response.error == nil) {
    [self isUserCitrusMemberHelper:[CTSUtility toBool:response.responseString]
                             error:nil];

  } else {
    [self isUserCitrusMemberHelper:NO error:response.error];
  }
}

#pragma mark - helper methods
- (void)signinHelperUsername:(NSString*)username
                       oauth:(NSString*)token
                       error:(NSError*)error {
  ASSigninCallBack callBack =
      [self retrieveAndRemoveCallbackForReqId:SigninOauthTokenReqId];

  if (error != nil) {
    [CTSOauthManager resetOauthData];
  }

  if (callBack != nil) {
    callBack(username, token, error);
  } else {
    [delegate auth:self
        didSigninUsername:username
               oauthToken:token
                    error:error];
  }
}

- (void)signupHelperUsername:(NSString*)username
                       oauth:(NSString*)token
                       error:(NSError*)error {
  ASSigninCallBack callBack =
      [self retrieveAndRemoveCallbackForReqId:SignupOauthTokenReqId];

  wasSignupCalled = NO;

  if (error != nil) {
    [CTSOauthManager resetOauthData];
  }

  if (callBack != nil) {
    callBack(username, token, error);
  } else {
    [delegate auth:self
        didSignupUsername:username
               oauthToken:token
                    error:error];
  }

  [self resetSignupCredentials];
}

- (void)changePasswordHelper:(NSError*)error {
  ASChangePassword callback =
      [self retrieveAndRemoveCallbackForReqId:ChangePasswordReqId];

  if (callback != nil) {
    callback(error);
  } else {
    [delegate auth:self didChangePasswordError:error];
  }
}

- (void)isUserCitrusMemberHelper:(BOOL)isMember error:(NSError*)error {
  ASIsUserCitrusMemberCallback callback =
      [self retrieveAndRemoveCallbackForReqId:IsUserCitrusMemberReqId];
  if (callback != nil) {
    callback(isMember, error);
  } else {
    [delegate auth:self didCheckIsUserCitrusMember:isMember error:error];
  }
}

- (void)resetPasswordHelper:(NSError*)error {
  ASResetPasswordCallback callback =
      [self retrieveAndRemoveCallbackForReqId:RequestForPasswordResetReqId];
  if (callback != nil) {
    callback(error);
  } else {
    [delegate auth:self didRequestForResetPassword:error];
  }
}

- (void)resetSignupCredentials {
  userNameSignup = @"";
  mobileSignUp = @"";
  passwordSignUp = @"";
}

@end
