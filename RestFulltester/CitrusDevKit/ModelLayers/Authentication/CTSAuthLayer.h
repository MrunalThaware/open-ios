//
//  CTSAuthLayer.h
//  RestFulltester
//
//  Created by Yadnesh Wankhede on 23/05/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CTSOauthTokenRes.h"
#import "RestLayerConstants.h"
#import "CTSAuthLayerConstants.h"
#import "CTSRestPluginBase.h"
#import "CTSRestCoreResponse.h"
#import "MerchantConstants.h"
#import "CTSUserVerificationRes.h"

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
@optional
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
@optional
- (void)auth:(CTSAuthLayer*)layer
didSignupUsername:(NSString*)userName
  oauthToken:(NSString*)token
  isSignedIn:(BOOL)isSignedIn
       error:(NSError*)error;

/**
 *  reports change password reply
 *
 *  @param layer
 *  @param error
 */
@optional
- (void)auth:(CTSAuthLayer*)layer didChangePasswordError:(NSError*)error;

/**
 *  reports is user Citrus member
 *
 *  @param layer
 *  @param isMember Bool that reports membership status
 *  @param error
 */
@optional
- (void)auth:(CTSAuthLayer*)layer
didCheckIsUserCitrusMember:(BOOL)isMember
       error:(NSError*)error;

/**
 *  reports password reset
 *
 *  @param layer
 *  @param error
 */
@optional
- (void)auth:(CTSAuthLayer*)layer didRequestForResetPassword:(NSError*)error;

@optional
-(void)auth:(CTSAuthLayer *)layer didVerifyOTP:(BOOL)isVerified error:(NSError *)error;

@optional
-(void)auth:(CTSAuthLayer *)layer didRegenerateOTPWitherror:(NSError *)error;

@optional
-(void)auth:(CTSAuthLayer *)layer didCheckIsMobileVerified:(BOOL )isVerified error:(NSError *)error;

@optional
-(void)auth:(CTSAuthLayer *)layer didCheckIsUserAlreadyRegistered:(CTSUserVerificationRes *)verificationRes error:(NSError *)error;

@optional
-(void)auth:(CTSAuthLayer *)layer didUserVerification:(CTSUserVerificationRes *)verificationRes error:(NSError *)error;


@optional
-(void)auth:(CTSAuthLayer *)layer didCheckIsUserVerified:(CTSUserVerificationRes *)verificationRes error:(NSError *)error;
@end

@interface CTSAuthLayer : CTSRestPluginBase {
    int seedState;
    NSString* userNameSignIn, *userNameSignup, *passwordSignUp, *mobileSignUp,*firstNameSignup,*lastNameSignup,*sourceTypeSignup;
    BOOL wasSignupCalled;
}
- (instancetype)initWithUrl:(NSString *)url;

typedef void (^ASSigninCallBack)(NSString* userName,
                                 NSString* token,
                                 NSError* error);

typedef void (^ASSignupCallBack)(NSString* userName,
                                 NSString* token,
                                 BOOL isSignedIn,
                                 NSError* error);

typedef void (^ASChangePassword)(NSError* error);

typedef void (^ASIsUserCitrusMemberCallback)(BOOL isUserCitrusMember,
                                             NSError* error);

typedef void (^ASIsUserAlreadyRegistered)(CTSUserVerificationRes *userVerification,
                                             NSError* error);

typedef void (^ASResetPasswordCallback)(NSError* error);


typedef void (^ASOtpVerificationCallback)(BOOL isVerified,NSError* error);

typedef void (^ASOtpRegenerationCallback)(NSError* error);

typedef void (^ASIsMobileVerifiedCallback)(BOOL isVerified,NSError* error);

typedef void (^ASUSerVerificationCallback)(CTSUserVerificationRes *verificationRes,NSError* error);

typedef void (^ASIsUserVerified)(CTSUserVerificationRes *verificationRes,NSError* error);



@property(nonatomic, weak) id<CTSAuthenticationProtocol> delegate;

// 260315 Dynamic Oauth keys
@property (strong, nonatomic) NSString *signInId;
@property (strong, nonatomic) NSString *signInSecretKey;

@property (strong, nonatomic) NSString *subscriptionId;
@property (strong, nonatomic) NSString *subscriptionSecretKey;

- (void)initWithDynamicKeys:(NSString *)signInId signInSecretKey:(NSString *)signInSecretKey subscriptionId:(NSString *)subscriptionId subscriptionSecretKey:(NSString *)subscriptionSecretKey;
+ (NSString*)getDynamicSignInId;
+ (NSString*)getDynamicSignInSecretKey;
+ (NSString*)getDynamicSubscriptionId;
+ (NSString*)getDynamicSubscriptionSecretKey;
/**
 *  sign in the user
 *
 *  @param userName email adress
 *  @param password
 *  @param callBack
 */
- (void)requestSigninWithUsername:(NSString*)userName
                         password:(NSString*)password
                completionHandler:(ASSigninCallBack)callBack;

/**
 *  to sign up the user
 *
 *  @param email    this will be the username
 *  @param mobile
 *  @param password
 *  @param callBack
 */
- (void)requestSignUpWithEmail:(NSString*)email
                        mobile:(NSString*)mobile
                      password:(NSString*)password
                     firstName:(NSString*)firstName
                      lastName:(NSString*)lastName
                    sourceType:(NSString *)sourceType
             completionHandler:(ASSignupCallBack)callBack;


-(void)requestOTPVerificationUserName:(NSString *)username otp:(NSString *)otp completionHandler:(ASOtpVerificationCallback)callback;


-(void)requestOTPRegenerateMobile:(NSString *)mobile completionHandler:(ASOtpRegenerationCallback)callback;


- (void)requestIsMobileVerified:(NSString*)mobile
                        completionHandler:
(ASIsMobileVerifiedCallback)callback;

/**
 *  in case of forget password,after recieving this server will send email to
 *this user to initiate the password reset
 *
 *  @param userNameArg
 */
- (void)requestResetPassword:(NSString*)userNameArg
           completionHandler:(ASResetPasswordCallback)callBack;

/**
 *  to change the user password
 *
 *  @param userName
 *  @param oldPassword
 *  @param newPassword
 *  @param callback
 */
- (void)requestChangePasswordUserName:(NSString*)userName
                          oldPassword:(NSString*)oldPassword
                          newPassword:(NSString*)newPassword
                    completionHandler:(ASChangePassword)callback;

/**
 *  to check if username is registered for any member
 *
 *  @param email    this is the username
 *  @param callback
 */
- (void)requestIsUserCitrusMemberUsername:(NSString*)email
                        completionHandler:
(ASIsUserCitrusMemberCallback)callback;


- (void)requestIsUserAlreadyRegisteredMobileOrEmail:(NSString*)mobOrEmail
                        completionHandler:(ASIsUserAlreadyRegistered)callback;



-(void)requestVerifyUser:(NSString *)userName completionHandler:(ASUSerVerificationCallback)callback;
/**
 *  signout
 *
 *  @return YES
 */
- (BOOL)signOut;

/**
 *  to confirm if anyone is signed in
 *
 *  @return yes if anyone is signed in, NO otherwise
 */
-(BOOL)isAnyoneSignedIn;


+(CTSUserVerificationRes * )convertToUserVerification:(CTSRestCoreResponse *)response ;
+ (CTSUserVerificationRes *)requestSyncIsUserAlreadyRegisteredMobileOrEmail:(NSString*)mobOrEmail;



#pragma mark - new methods

-(void)requestIsUserVerified:(NSString *)userName  completionHandler:(ASIsUserVerified)callback;



@end
