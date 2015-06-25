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
#import "CTSUserVerificationRes.h"
#import "CTSMobileVerifiactionRes.h"

@class CTSAuthLayer;

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

typedef void (^ASCitrusSigninCallBack)(NSError* error);

typedef void (^ASBindCallBack)(NSError* error);

typedef void (^ASMobileVerifiactionCallback)(CTSMobileVerifiactionRes *mobileVerifiactionRes, NSError* error);

typedef void (^ASGenerationMobileVerificationCodeCallback)(NSError* error);

typedef void (^ASMobileVerificationCodeCallback)(BOOL isVerified,NSError* error);


// 010615 Dynamic Oauth keys init with base URL
- (instancetype)initWithBaseURLAndDynamicVanityOauthKeysURLs:(NSString *)url vanityUrl:(NSString *)vanityUrl signInId:(NSString *)signInId signInSecretKey:(NSString *)signInSecretKey subscriptionId:(NSString *)subscriptionId subscriptionSecretKey:(NSString *)subscriptionSecretKey returnUrl:(NSString *)returnUrl merchantAccessKey:(NSString *)merchantAccessKey;

// 010615 Dynamic Oauth keys init with base URL
+ (NSString*)getDynamicSignInId;
+ (NSString*)getDynamicSignInSecretKey;
+ (NSString*)getDynamicSubscriptionId;
+ (NSString*)getDynamicSubscriptionSecretKey;
+ (NSString*)getBaseURL;
+ (NSString*)getVanityUrl;
+ (NSString*)getMerchantAccessKey;
+ (NSString*)getReturnUrl;



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


/**
 @brief              Sign in using Citrus pay Account.
 @param userName     Set Citrus pay username.
 @param password     Set Citrus pay passwrd.
 @param callback     Set success/failure callBack.
 @details            Using this method user will Sign in into Citrus pay prepaid Account.
 */
-(void)requestCitrusPaySignin:(NSString *)userName  password:(NSString*)password
            completionHandler:(ASCitrusSigninCallBack)callBack;

/**
 @brief              Bind the user to Citrus pay.
 @param userName     Set Citrus pay username.
 @param callback     Set success/failure callBack.
 @details            Using this method user can authorize to use Citrus pay services.
 */
-(void)requestBindSigninUsername:(NSString *)email completionHandler:(ASBindCallBack)callback;

/**
 @brief              Set Cookie for pay using citrus cash.
 @details            Using this method user dont need to sign on pay using Citrus cash payment mode.
 */
-(BOOL)isCookieSetAlready;

/**
 @brief            For send mobile verification Code.
 @param mobile     Set linked mobile number.
 @param callback   Set success/failure callBack.
 @details          Use this method For send mobile verification Code.
                   Use same for regenerate mobile verification Code again
                   You can use same method for update mobile number also
 */
- (void)sendMobileVerificationCode:(NSString*)mobile completionHandler:(ASMobileVerifiactionCallback)callback;

/**
 @brief                   For verifying mobile number .
 @param verificationCode  Use sent mobile verification code.
 @param callback          Set success/failure callBack.
 @details                 Use this method For verifying mobile number .
 */
- (void)verifyingMobileNumber:(NSString*)verificationCode completionHandler:(ASMobileVerifiactionCallback)callback;

/**
 @brief                   For genrate mobile verification code .
 @param mobile            Set mobile number.
 @param callback          Set success/failure callBack.
 @details                 Use this method For genrate mobile verification code .
 */
-(void)requestGenerateMobileVerificationCode:(NSString *)mobile completionHandler:(ASGenerationMobileVerificationCodeCallback)callback;

/**
 @brief                   For verifiy mobile verification code .
 @param mobile            Set mobile number.
 @param callback          Set success/failure callBack.
 @details                 Use this method For verifiy mobile verification code .
 */
-(void)requestVerifyMobileCodeWithMobile:(NSString *)mobile mobileOTP:(NSString *)mobileOTP completionHandler:(ASMobileVerificationCodeCallback)callback;
@end
