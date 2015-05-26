//
//  CTSOauthManager.m
//  CTS iOS Sdk
//
//  Created by Yadnesh Wankhede on 21/07/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import "CTSOauthManager.h"
#import "CTSAuthLayerConstants.h"
#import "CTSError.h"
#import "CTSUtility.h"
#import <Foundation/NSObjCRuntime.h>
#import <objc/runtime.h>
#import "CTSRestCore.h"
#import "CTSAuthLayer.h"

@implementation CTSOauthManager

- (instancetype)init {
  self = [super init];
  if (self) {
    //    < #statements # >
  }
  return self;
}

// check if oauth exitsts
// if null ask user to sign in
// if exits check for expiry
// if expired return authExpired
// if server tells to sign in ask user to sign in else procced

+ (void)saveOauthData:(CTSOauthTokenRes*)object {
  object.tokenSaveDate = [NSDate date];
  NSData* encodedObject = [NSKeyedArchiver archivedDataWithRootObject:object];
  NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
  [defaults setObject:encodedObject forKey:MLC_OAUTH_OBJECT_KEY];
  [defaults synchronize];
}

+ (CTSOauthTokenRes*)readOauthData {
  NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
  NSData* encodedObject = [defaults objectForKey:MLC_OAUTH_OBJECT_KEY];
  CTSOauthTokenRes* object =
      [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];

  return object;
}

/**
 *  reads oauth token from the navtive disk,
 *  @return returns oauth token
 *
 */
+ (NSString*)readOauthToken {
  return [self readOauthData].accessToken;
}

+ (NSString*)readOauthTokenWithExpiryCheck {
  if (![self hasOauthExpired]) {
    return [self readOauthData].accessToken;
  } else {
    return nil;
  }
}
+ (NSString*)readRefreshToken {
  CTSOauthTokenRes* oauthTokenRes = [CTSOauthManager readOauthData];
  LogDebug(@" readRefreshToken %@ %@", oauthTokenRes, oauthTokenRes.refreshToken);
  return oauthTokenRes.refreshToken;
}

+ (void)resetOauthData {
  [[NSUserDefaults standardUserDefaults]
      removeObjectForKey:MLC_OAUTH_OBJECT_KEY];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)hasOauthExpired {
  CTSOauthTokenRes* oauthTokenRes = [self readOauthData];
  NSDate* tokenSaveDate = oauthTokenRes.tokenSaveDate;
  NSDate* todaysDate = [NSDate date];
  NSTimeInterval secondsBetween =
      [todaysDate timeIntervalSinceDate:tokenSaveDate];

  if (secondsBetween > oauthTokenRes.tokenExpiryTime) {
    return YES;
  } else {
    return NO;
  }
}

+ (BOOL)hasOauthExpired:(CTSOauthTokenRes*)oauthTokenRes {
  NSDate* tokenSaveDate = oauthTokenRes.tokenSaveDate;
  NSDate* todaysDate = [NSDate date];
  NSTimeInterval secondsBetween =
      [todaysDate timeIntervalSinceDate:tokenSaveDate];

  if (secondsBetween > oauthTokenRes.tokenExpiryTime) {
    return YES;
  } else {
    return NO;
  }
}

- (void)requestOauthTokenRefresh {
  // request for oauth refresh
}

+ (OauthStatus*)fetchSigninTokenStatus {
  OauthStatus* oauthStatus = [[OauthStatus alloc] init];
  CTSOauthTokenRes* oauthTokenRes = [CTSOauthManager readOauthData];
  if (oauthTokenRes == nil) {
    oauthStatus.error = [CTSError getErrorForCode:UserNotSignedIn];
    return oauthStatus;
  } else if ([CTSOauthManager hasOauthExpired:oauthTokenRes]) {
    // server call to refresh the token
    oauthTokenRes = [CTSOauthManager refreshOauthToken];
    if (oauthTokenRes == nil) {
      oauthStatus.error = [CTSError getErrorForCode:UserNotSignedIn];
      return oauthStatus;
    }
  }
  oauthStatus.oauthToken = oauthTokenRes.accessToken;

  return oauthStatus;
}



+ (void)saveSignupToken:(NSString*)token {
  [CTSUtility saveToDisk:token as:MLC_SIGNUP_ACCESS_OAUTH_TOKEN];
}

+ (NSString*)readSignupToken {
  return [CTSUtility readFromDisk:MLC_SIGNUP_ACCESS_OAUTH_TOKEN];
}

+ (OauthStatus*)fetchSignupTokenStatus {
  OauthStatus* oauthTokenStatus = [[OauthStatus alloc] init];

  oauthTokenStatus.oauthToken = [CTSOauthManager readSignupToken];
  if (oauthTokenStatus.oauthToken == nil) {
    CTSOauthTokenRes* tokenResponse = [CTSOauthManager requestSignupOauthToken];
    if (tokenResponse == nil) {
      oauthTokenStatus.error = [CTSError getErrorForCode:CantFetchSignupToken];
    } else {
      oauthTokenStatus.oauthToken = tokenResponse.accessToken;
    }
  }

  return oauthTokenStatus;
}

+ (CTSOauthTokenRes*)refreshOauthToken {
    // 260315 Dynamic Oauth keys
    NSString *signInId = [CTSAuthLayer getDynamicSignInId];
    if (!signInId) {
        signInId = MLC_OAUTH_REFRESH_CLIENT_ID;
    }
    
    NSString *signInSecretKey = [CTSAuthLayer getDynamicSignInSecretKey];
    if (!signInSecretKey) {
        signInSecretKey = MLC_OAUTH_TOKEN_SIGNIN_CLIENT_SECRET;
    }
    
    NSDictionary* parameters = @{
                                 MLC_OAUTH_TOKEN_QUERY_CLIENT_ID : signInId,
                                 MLC_OAUTH_TOKEN_QUERY_CLIENT_SECRET : signInSecretKey,
                                 MLC_OAUTH_TOKEN_QUERY_GRANT_TYPE : MLC_OAUTH_REFRESH_QUERY_REFRESH_TOKEN,
                                 MLC_OAUTH_REFRESH_QUERY_REFRESH_TOKEN : [CTSOauthManager readRefreshToken]
                                 };

  CTSRestCoreRequest* request =
      [[CTSRestCoreRequest alloc] initWithPath:MLC_OAUTH_TOKEN_SIGNUP_REQ_PATH
                                     requestId:-1
                                       headers:nil
                                    parameters:parameters
                                          json:nil
                                    httpMethod:POST];

  CTSRestCoreResponse* response =
      [CTSRestCore requestSyncServer:request withBaseUrl:CITRUS_BASE_URL];

  NSError* error = response.error;
  JSONModelError* jsonError;
  CTSOauthTokenRes* resultObject = nil;
  if (error == nil) {
    resultObject =
        [[CTSOauthTokenRes alloc] initWithString:response.responseString
                                           error:&jsonError];
    [CTSOauthManager saveOauthData:resultObject];
  }
  return resultObject;
}

+ (CTSOauthTokenRes*)requestSignupOauthToken {
    
    // 260315 Dynamic Oauth keys
    NSString *subscriptionId = [CTSAuthLayer getDynamicSubscriptionId];
    if (!subscriptionId) {
        subscriptionId = MLC_OAUTH_TOKEN_SIGNUP_CLIENT_ID;
    }
    
    NSString *subscriptionSecretKey = [CTSAuthLayer getDynamicSubscriptionSecretKey];
    if (!subscriptionSecretKey) {
        subscriptionSecretKey = MLC_OAUTH_TOKEN_SIGNUP_CLIENT_SECRET;
    }
    
    NSDictionary* parameters = @{MLC_OAUTH_TOKEN_QUERY_CLIENT_ID : subscriptionId,
                                 MLC_OAUTH_TOKEN_QUERY_CLIENT_SECRET : subscriptionSecretKey,
                                 MLC_OAUTH_TOKEN_QUERY_GRANT_TYPE : MLC_OAUTH_TOKEN_SIGNUP_GRANT_TYPE
                                 };

    CTSRestCoreRequest* request = [[CTSRestCoreRequest alloc]
                                   initWithPath:MLC_OAUTH_TOKEN_SIGNUP_REQ_PATH
                                   requestId:-1
                                   headers:nil
                                   parameters:parameters
                                   json:nil
                                   httpMethod:POST];

  CTSRestCoreResponse* response =
      [CTSRestCore requestSyncServer:request withBaseUrl:CITRUS_BASE_URL];
  NSError* error = response.error;
  CTSOauthTokenRes* resultObject = nil;

  if (error == nil) {
    JSONModelError* jsonError;
    resultObject =
        [[CTSOauthTokenRes alloc] initWithString:response.responseString
                                           error:&jsonError];
    LogDebug(@"jsonError %@ ", jsonError);
    [CTSOauthManager saveSignupToken:resultObject.accessToken];
  }
  return resultObject;
}

+ (CTSOauthTokenRes*)readBindSignInOauthData {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSData* encodedObject = [defaults objectForKey:MLC_OAUTH_BIND_SIGN_IN];
    CTSOauthTokenRes* object =
    [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
    
    return object;
}

+(void)saveBindSignInOauth:(CTSOauthTokenRes*)object{
    object.tokenSaveDate = [NSDate date];
    NSData* encodedObject = [NSKeyedArchiver archivedDataWithRootObject:object];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:encodedObject forKey:MLC_OAUTH_BIND_SIGN_IN];
    [defaults synchronize];
    
}

+ (void)resetBindSiginOauthData {
    [[NSUserDefaults standardUserDefaults]
     removeObjectForKey:MLC_OAUTH_BIND_SIGN_IN];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


+ (CTSOauthTokenRes*)refreshBindSiginInOauthToken {
    NSDictionary* parameters = @{
                                 MLC_OAUTH_TOKEN_QUERY_CLIENT_ID : MLC_OAUTH_REFRESH_CLIENT_ID,
                                 MLC_OAUTH_TOKEN_QUERY_CLIENT_SECRET : MLC_OAUTH_TOKEN_SIGNIN_CLIENT_SECRET,
                                 MLC_OAUTH_TOKEN_QUERY_GRANT_TYPE : MLC_OAUTH_REFRESH_QUERY_REFRESH_TOKEN,
                                 MLC_OAUTH_REFRESH_QUERY_REFRESH_TOKEN : [CTSOauthManager readBindSignInRefreshToken]
                                 };
    
    CTSRestCoreRequest* request =
    [[CTSRestCoreRequest alloc] initWithPath:MLC_OAUTH_TOKEN_SIGNUP_REQ_PATH
                                   requestId:-1
                                     headers:nil
                                  parameters:parameters
                                        json:nil
                                  httpMethod:POST];
    
    CTSRestCoreResponse* response =
    [CTSRestCore requestSyncServer:request withBaseUrl:CITRUS_BASE_URL];
    
    NSError* error = response.error;
    JSONModelError* jsonError;
    CTSOauthTokenRes* resultObject = nil;
    if (error == nil) {
        resultObject =
        [[CTSOauthTokenRes alloc] initWithString:response.responseString
                                           error:&jsonError];
        [CTSOauthManager saveBindSignInOauth:resultObject];
    }
    return resultObject;
}

+(NSString *)readBindSignInRefreshToken{
    CTSOauthTokenRes* oauthTokenRes = [CTSOauthManager readBindSignInOauthData];
    LogDebug(@" readRefreshToken %@ %@", oauthTokenRes, oauthTokenRes.refreshToken);
    return oauthTokenRes.refreshToken;
    
}

+ (OauthStatus*)fetchBindSigninTokenStatus {
    OauthStatus* oauthStatus = [[OauthStatus alloc] init];
    CTSOauthTokenRes* oauthTokenRes = [CTSOauthManager readBindSignInOauthData];
    if (oauthTokenRes == nil) {
        oauthStatus.error = [CTSError getErrorForCode:UserNotSignedIn];
        return oauthStatus;
    } else if ([CTSOauthManager hasOauthExpired:oauthTokenRes]) {
        // server call to refresh the token
        oauthTokenRes = [CTSOauthManager refreshBindSiginInOauthToken];
        if (oauthTokenRes == nil) {
            oauthStatus.error = [CTSError getErrorForCode:UserNotSignedIn];
            return oauthStatus;
        }
    }
    oauthStatus.oauthToken = oauthTokenRes.accessToken;
    
    return oauthStatus;
}

@end
