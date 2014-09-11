//
//  CTSAuthLayerConstants.h
//  RestFulltester
//
//  Created by Yadnesh Wankhede on 26/05/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//
#import "MerchantConstants.h"

#ifndef RestFulltester_CTSAuthLayerConstants_h
#define RestFulltester_CTSAuthLayerConstants_h
#define CITRUS_AUTH_BASE_URL CITRUS_BASE_URL
//#define CITRUS_AUTH_BASE_URL @"http://localhost:8080"

//#define CITRUS_BASE_URL @"https://stgadmin.citruspay.com/service/v2/"

// MLC: model layer constants

typedef enum PasswordUseType {
  SIGN_IN,
  SET_FIRSTTIME_PASSWORD
} PasswordUseType;

typedef enum SignOutResponseState {
  SIGNOUT_SUCCESFUL,
  SIGNOUT_WAS_NOT_SIGNED_IN
} SignOutResponseState;

#pragma mark - class constants
#define MLC_SIGNUP_ACCESS_OAUTH_TOKEN @"signup_oauth_token"
#define MLC_SIGNIN_ACCESS_OAUTH_TOKEN @"signin_oauth_token"
#define MLC_SIGNIN_REFRESH_TOKEN @"refresh_token"
#define MLC_TOKEN_EXPIRY @"token_expiry"
#define MLC_OAUTH_SCOPE @"token_scope"
#define MLC_OAUTH_TYPE @"token_type"
#define MLC_OAUTH_OBJECT_KEY @"oauth_object_key"
#define MLC_OAUTH_TOKEN_SAVE_DATE @"oauth_token_save_date"
#define MLC_CLIENT_ID SignInId
#define MLC_CLIENT_SECRET SignInSecretKey

#pragma mark - OAUTH_TOKEN
#define MLC_OAUTH_TOKEN_QUERY_GRANT_TYPE @"grant_type"
#define MLC_OAUTH_TOKEN_QUERY_CLIENT_ID @"client_id"
#define MLC_OAUTH_TOKEN_QUERY_CLIENT_SECRET @"client_secret"

#define MLC_OAUTH_TOKEN_SIGNUP_CLIENT_ID SubscriptionId
#define MLC_OAUTH_TOKEN_SIGNUP_CLIENT_SECRET SubscriptionSecretKey
#define MLC_OAUTH_TOKEN_SIGNUP_GRANT_TYPE @"implicit"

#define MLC_OAUTH_TOKEN_SIGNUP_REQ_PATH @"/oauth/token"
#define MLC_OAUTH_TOKEN_SIGNUP_RES_TYPE [CTSOauthTokenRes class]

#define MLC_OAUTH_TOKEN_SIGNUP_REQ_TYPE POST
#define MLC_OAUTH_TOKEN_SIGNUP_RESPONSE_MAPPING \
  @{                                            \
    @"access_token" : @"accessToken",           \
    @"token_type" : @"tokenType",               \
    @"expires_in" : @"tokenExpiryTime",         \
    @"scope" : @"scope",                        \
    @"refresh_token" : @"refreshToken"          \
  }

#define MLC_OAUTH_TOKEN_SIGNUP_QUERY_MAPPING                             \
  @{                                                                     \
    MLC_OAUTH_TOKEN_QUERY_CLIENT_ID : MLC_OAUTH_TOKEN_SIGNUP_CLIENT_ID,  \
    MLC_OAUTH_TOKEN_QUERY_CLIENT_SECRET :                                \
        MLC_OAUTH_TOKEN_SIGNUP_CLIENT_SECRET,                            \
    MLC_OAUTH_TOKEN_QUERY_GRANT_TYPE : MLC_OAUTH_TOKEN_SIGNUP_GRANT_TYPE \
  }

#pragma mark - CHANGE_PASSWORD
#define MLC_CHANGE_PASSWORD_REQ_PATH @"/service/v2/identity/me/password"
#define MLC_CHANGE_PASSWORD_QUERY_OLD_PWD @"old"
#define MLC_CHANGE_PASSWORD_QUERY_NEW_PWD @"new"

#pragma mark - SIGNIN
#define MLC_OAUTH_TOKEN_SIGNIN_CLIENT_ID MLC_CLIENT_ID
#define MLC_OAUTH_TOKEN_SIGNIN_CLIENT_SECRET MLC_CLIENT_SECRET
#define MLC_SIGNIN_GRANT_TYPE @"password"
#define MLC_OAUTH_TOKEN_SIGNIN_REQ_TYPE POST
#define MLC_OAUTH_TOKEN_SIGNIN_QUERY_PASSWORD @"password"
#define MLC_OAUTH_TOKEN_SIGNIN_QUERY_USERNAME @"username"

#pragma mark - SIGNUP
#define MLC_SIGNUP_REQ_PATH @"/service/v2/identity/new"
#define MLC_SIGNUP_REQ_TYPE POST
#define MLC_SIGNUP_RES_TYPE [CTSSignUpRes class]
#define MLC_SIGNUP_RESPONSE_MAPPING @{@"username" : @"userName"}

#define MLC_SIGNUP_QUERY_EMAIL @"email"
#define MLC_SIGNUP_QUERY_MOBILE @"mobile"

#pragma mark - REQUEST_CHANGE_PASSWORD
#define MLC_REQUEST_CHANGE_PWD_REQ_PATH @"/service/v2/identity/passwords/reset"
#define MLC_REQUEST_CHANGE_PWD_REQ_TYPE POST
#define MLC_REQUEST_CHANGE_PWD_QUERY_USERNAME @"username"

#pragma mark - OAUTH_REFRESH
#define MLC_OAUTH_REFRESH_GRANT_TYPE @"refresh_token"
#define MLC_OAUTH_REFRESH_CLIENT_ID MLC_CLIENT_ID
#define MLC_OAUTH_REFRESH_CLIENT_SECRET MLC_CLIENT_SECRET
#define MLC_OAUTH_REFRESH_SIGNIN_REQ_TYPE POST

#define MLC_OAUTH_REFRESH_QUERY_REFRESH_TOKEN @"refresh_token"

#pragma mark - IS_MEMBER
#define MLC_IS_MEMBER_REQ_PATH @"/service/v1/verify/email"
#define MLC_IS_MEMBER_REQ_TYPE POST
#define MLC_IS_MEMBER_QUERY_EMAIL @"email"

typedef enum {
  OauthRefreshStatusSuccess,
  OauthRefreshStatusNeedToLogin
} OauthRefresStatus;

#endif
