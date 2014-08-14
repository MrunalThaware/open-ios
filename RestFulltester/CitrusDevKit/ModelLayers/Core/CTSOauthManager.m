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

#import <Foundation/NSObjCRuntime.h>
#import <objc/runtime.h>

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
  return [self readOauthData].refreshToken;
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

+ (OauthStatus*)fetchOauthStatus {
  OauthStatus* oauthStatus = [[OauthStatus alloc] init];
  CTSOauthTokenRes* oauthTokenRes = [CTSOauthManager readOauthData];
  if ([CTSOauthManager readOauthData] == nil) {
    oauthStatus.error = [CTSError getErrorForCode:UserNotSignedIn];
  } else if ([CTSOauthManager hasOauthExpired:oauthTokenRes]) {
    oauthStatus.error = [CTSError getErrorForCode:OauthTokenExpired];
  } else {
    oauthStatus.oauthToken = oauthTokenRes.accessToken;
  }
  return oauthStatus;
}

@end
