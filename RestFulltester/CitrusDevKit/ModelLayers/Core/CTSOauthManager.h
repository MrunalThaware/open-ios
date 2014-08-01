//
//  CTSOauthManager.h
//  CTS iOS Sdk
//
//  Created by Yadnesh Wankhede on 21/07/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CTSOauthTokenRes.h"
#import "CTSRestIntergration.h"

@protocol OauthHandler<NSObject>


@end

@interface CTSOauthManager : CTSRestIntergration<CTSRestLayerProtocol>
+ (NSString*)readOauthToken;
+ (void)resetOauthData;
+ (BOOL)hasOauthExpired;
+ (void)saveOauthData:(CTSOauthTokenRes*)object;
+ (CTSOauthTokenRes*)readOauthData;
/**
 *  read oauthToken with expiry check,nil in case of expiry
 *
 *  @return OauthToken or nil if expired
 */
+ (NSString*)readOauthTokenWithExpiryCheck;

/**
 *  whenever access token error is reported merchant should call this method to
 * get new token from server.
 */
+ (NSString*)readRefreshToken;

@end
