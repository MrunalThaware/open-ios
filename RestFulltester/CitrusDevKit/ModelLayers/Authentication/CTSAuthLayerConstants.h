//
//  CTSAuthLayerConstants.h
//  RestFulltester
//
//  Created by Yadnesh Wankhede on 26/05/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#ifndef RestFulltester_CTSAuthLayerConstants_h
#define RestFulltester_CTSAuthLayerConstants_h
#define CITRUS_AUTH_BASE_URL @"https://stgadmin.citruspay.com"
//#define CITRUS_AUTH_BASE_URL @"http://localhost:8080"

//#define CITRUS_BASE_URL @"https://stgadmin.citruspay.com/service/v2/"

// MLC: model layer constants

typedef enum PasswordUseType {
  SIGN_IN,
  SET_FIRSTTIME_PASSWORD
} PasswordUseType;

#pragma mark - class constants
#define MLC_SIGNUP_ACCESS_OAUTH_TOKEN @"signup_oauth_token"
#define MLC_SIGNIN_ACCESS_OAUTH_TOKEN @"signin_oauth_token"

#pragma mark - OAUTH_TOKEN
#define MLC_OAUTH_TOKEN_QUERY_GRANT_TYPE @"grant_type"
#define MLC_OAUTH_TOKEN_QUERY_CLIENT_ID @"client_id"
#define MLC_OAUTH_TOKEN_QUERY_CLIENT_SECRET @"client_secret"

#define MLC_OAUTH_TOKEN_SIGNUP_CLIENT_ID @"citrus-mobile-subscription"
#define MLC_OAUTH_TOKEN_SIGNUP_CLIENT_SECRET @"2e6d37aa23a868e043705ba539da999a"
#define MLC_OAUTH_TOKEN_SIGNUP_GRANT_TYPE @"implicit"

#define MLC_OAUTH_TOKEN_SIGNUP_REQ_PATH @"/oauth/token"
#define MLC_OAUTH_TOKEN_SIGNUP_RES_TYPE [CTSOauthTokenRes class]

#define MLC_OAUTH_TOKEN_SIGNUP_REQ_TYPE POST
#define MLC_OAUTH_TOKEN_SIGNUP_RESPONSE_MAPPING \
  @{                                            \
    @"access_token" : @"accessToken",           \
    @"token_type" : @"tokenType",               \
    @"expires_in" : @"tokenExpiryTime",         \
    @"scope" : @"scope"                         \
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
#define MLC_OAUTH_TOKEN_SIGNIN_CLIENT_ID @"citrus-mobile-app-v1"
#define MLC_OAUTH_TOKEN_SIGNIN_CLIENT_SECRET @"0e49deace77ab85a434324c3c13ae9f2"
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

#pragma - REQUEST_CHANGE_PASSWORD
#define MLC_REQUEST_CHANGE_PWD_REQ_PATH @"/service/v2/identity/passwords/reset"
#define MLC_REQUEST_CHANGE_PWD_REQ_TYPE POST
#define MLC_REQUEST_CHANGE_PWD_QUERY_USERNAME @"username"

#endif
