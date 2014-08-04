//
//  CTSAuthLayer.h
//  RestFulltester
//
//  Created by Yadnesh Wankhede on 23/05/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CTSOauthTokenRes.h"
#import "CTSRestRegister.h"
#import "RestLayerConstants.h"
#import "CTSAuthLayerConstants.h"
#import "CTSRestPluginBase.h"
#import "CTSRestCoreResponse.h"
@class CTSAuthLayer;
@protocol CTSAuthenticationProtocol
/**
 *  reports sign in respose
 *
 *  @param isSuccessful  status
 *  @param userName     username that was used for signin
 *  @param token : oauth token if signin followed by signup is successful is
 *successful,nil otherwise.
 *  @param error        error,nil in case of success.
 */

- (void)auth:(CTSAuthLayer*)layer
    didSigninUsername:(NSString*)userName
           oauthToken:(NSString*)token
                error:(NSError*)error;

/**
 *  reports sign up reply
 *
 *  @param isSuccessful
 *  @param token : oauth token if signin is successful,nil otherwise
 *  @param error
 */
- (void)auth:(CTSAuthLayer*)layer
    didSignupUsername:(NSString*)userName
           oauthToken:(NSString*)token
                error:(NSError*)error;

/**
 *  called when refresh token is updated from server
 *
 *  @param error if any,nil othewise
 */

- (void)auth:(CTSAuthLayer*)layer
    didRefreshOauthStatus:(OauthRefresStatus)status
                    error:(NSError*)error;

@end

@interface CTSAuthLayer : CTSRestPluginBase {
  int seedState;
  NSString* userNameSignIn, *userNameSignup, *passwordSignUp, *mobileSignUp;
  BOOL wasSignupCalled;
}
@property(nonatomic, strong) id<CTSAuthenticationProtocol> delegate;

- (void)requestSigninWithUsername:(NSString*)userName
                         password:(NSString*)password;
- (void)requestSignUpWithEmail:(NSString*)email
                        mobile:(NSString*)mobile
                      password:(NSString*)password;
- (void)requestChangePassword:(NSString*)userNameArg;
/**
 *  call at the time of oath error and according to statud returned in delegate
 * do the needful
 */
- (void)requestOauthTokenRefresh;

@end
