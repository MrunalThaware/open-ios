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
#import "CTSRestError.h"

#import <CommonCrypto/CommonDigest.h>
#ifndef MIN
#import <NSObjCRuntime.h>
#endif

@implementation CTSAuthLayer

// 010615 Dynamic Oauth keys init with base URL
static NSString * VanityUrl;
static NSString * SignInId;
static NSString * SignInSecretKey;
static NSString * SubscriptionId;
static NSString * SubscriptionSecretKey;
static NSString * ReturnUrl;
static NSString * MerchantAccessKey;
static NSString * BaseUrl;

#pragma mark - public methods

-(void)requestBindSigninUsername:(NSString *)email completionHandler:(ASBindCallBack)callback{
    
    [self addCallback:callback forRequestId:BindSigninRequestId];

    
    if (![CTSUtility validateEmail:email]) {
        [self bindUserHelperUsernameError:[CTSError getErrorForCode:EmailNotValid]];
        return;
    }
    
    
    NSDictionary* parameters = @{
                                 MLC_OAUTH_TOKEN_QUERY_CLIENT_ID : MLC_OAUTH_TOKEN_SIGNIN_CLIENT_ID,
                                 MLC_OAUTH_TOKEN_QUERY_CLIENT_SECRET : MLC_OAUTH_TOKEN_SIGNIN_CLIENT_SECRET,
                                 MLC_OAUTH_TOKEN_QUERY_GRANT_TYPE : MLC_OAUTH_TOKEN_SIGNIN_QUERY_USERNAME,
                                 MLC_OAUTH_TOKEN_SIGNIN_QUERY_USERNAME : email
                                 };
    
    CTSRestCoreRequest* request =
    [[CTSRestCoreRequest alloc] initWithPath:MLC_OAUTH_TOKEN_SIGNUP_REQ_PATH
                                   requestId:BindSigninRequestId
                                     headers:nil
                                  parameters:parameters
                                        json:nil
                                  httpMethod:POST];
    
    [restCore requestAsyncServer:request];
}


- (void)requestResetPassword:(NSString*)userNameArg
           completionHandler:(ASResetPasswordCallback)callBack;
{
    [self addCallback:callBack forRequestId:RequestForPasswordResetReqId];
    
    OauthStatus* oauthStatus = [CTSOauthManager fetchSignupTokenStatus];
    NSString* oauthToken = oauthStatus.oauthToken;
    
    if (oauthStatus.error != nil) {
        [self resetPasswordHelper:oauthStatus.error];
    }
    if ([CTSUtility isEmail:userNameArg]) {
        if (![CTSUtility validateEmail:userNameArg]) {
            [self resetPasswordHelper:[CTSError getErrorForCode:EmailNotValid]];
            return;
        }
    }
    else{
        userNameArg = [CTSUtility mobileNumberToTenDigitIfValid:userNameArg];
        if (!userNameArg) {
            [self resetPasswordHelper:[CTSError getErrorForCode:MobileNotValid]];
            return;
        }
        
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

- (void)requestInternalSignupMobile:(NSString*)mobile email:(NSString*)email firstName:(NSString *)firstName lastName:(NSString *)lastName{
    if (![CTSUtility validateEmail:email]) {
        [self signupHelperUsername:userNameSignup
                             oauth:[CTSOauthManager readOauthToken]
                        isSignedIn:NO
                             error:[CTSError getErrorForCode:EmailNotValid]];
        return;
    }
    
    mobile = [CTSUtility mobileNumberToTenDigitIfValid:mobile];
    if (!mobile) {
        [self signupHelperUsername:userNameSignup
                             oauth:[CTSOauthManager readOauthToken]
                        isSignedIn:NO
                             error:[CTSError getErrorForCode:MobileNotValid]];
        return;
    }
    
    if (firstName == nil) {
        [self signupHelperUsername:userNameSignup
                             oauth:[CTSOauthManager readOauthToken]
                        isSignedIn:NO
                             error:[CTSError getErrorForCode:FirstNameNotValid]];
        return;
    }
    if (lastName == nil) {
        [self signupHelperUsername:userNameSignup
                             oauth:[CTSOauthManager readOauthToken]
                        isSignedIn:NO
                             error:[CTSError getErrorForCode:LastNameNotValid]];
        return;
    }
    
    
    CTSRestCoreRequest* request = [[CTSRestCoreRequest alloc]
                                   initWithPath:MLC_SIGNUP_REQ_PATH
                                   requestId:SignupStageOneReqId
                                   headers:[CTSUtility readSignupTokenAsHeader]
                                   parameters:@{
                                                MLC_SIGNUP_QUERY_EMAIL : email,
                                                MLC_SIGNUP_QUERY_MOBILE : mobile,
                                                MLC_SIGNUP_QUERY_FIRSTNAME:firstName,
                                                MLC_SIGNUP_QUERY_LASTNAME:lastName,
                                                MLC_SIGNUP_QUERY_PASSWORD:passwordSignUp,
                                                MLC_SIGNUP_QUERY_SOURCE_TYPE:sourceTypeSignup
                                                } json:nil
                                   httpMethod:POST];
    
    
    [restCore requestAsyncServer:request];
}

- (void)requestSignUpWithEmail:(NSString*)email
                        mobile:(NSString*)mobile
                      password:(NSString*)password
                     firstName:(NSString*)firstName
                      lastName:(NSString*)lastName
                    sourceType:(NSString *)sourceType
             completionHandler:(ASSignupCallBack)callBack{
    [self addCallback:callBack forRequestId:SignupOauthTokenReqId];
    
    if (![CTSUtility validateEmail:email]) {
        [self signupHelperUsername:email
                             oauth:[CTSOauthManager readOauthToken]
                        isSignedIn:NO
                             error:[CTSError getErrorForCode:EmailNotValid]];
        return;
    }
    mobile = [CTSUtility mobileNumberToTenDigitIfValid:mobile];
    
    if (!mobile) {
        [self signupHelperUsername:email
                             oauth:[CTSOauthManager readOauthToken]
                        isSignedIn:NO
                             error:[CTSError getErrorForCode:MobileNotValid]];
        return;
    }
    
    userNameSignup = email;
    mobileSignUp = mobile;
    firstNameSignup =firstName;
    lastNameSignup = lastName;
    sourceTypeSignup = sourceType;
    if (password == nil) {
       // passwordSignUp = [self generatePseudoRandomPassword];
    } else {
        passwordSignUp = password;
    }
    
    [self requestSignUpOauthToken];
}


-(void)requestOTPVerificationUserName:(NSString *)username otp:(NSString *)otp completionHandler:(ASOtpVerificationCallback)callback{
    [self addCallback:callback forRequestId:OTPVerificationRequestId];
    
    
    username = [CTSUtility mobileNumberToTenDigitIfValid:username];
    if (!username) {
        [self otpVerificationHelper:NO error:[CTSError getErrorForCode:MobileNotValid]];
        return;
    }
    
    NSDictionary* parameters = @{
                                 MLC_OTP_VER_QUERY_OTP : otp,
                                 MLC_OTP_VER_QUERY_MOBILE : username
                                 };
    
    CTSRestCoreRequest* request =
    [[CTSRestCoreRequest alloc] initWithPath:MLC_OTP_VER_PATH
                                   requestId:OTPVerificationRequestId
                                     headers:nil
                                  parameters:parameters
                                        json:nil
                                  httpMethod:POST];
    
    [restCore requestAsyncServer:request];
}


-(void)requestOTPRegenerateMobile:(NSString *)mobile completionHandler:(ASOtpRegenerationCallback)callback{
    [self addCallback:callback forRequestId:OTPRegenerationRequestId];
    mobile = [CTSUtility mobileNumberToTenDigitIfValid:mobile];
    
    if (!mobile) {
        [self otpRegenerationHelperError:[CTSError getErrorForCode:MobileNotValid]];
        return;
    }
    
    NSDictionary* parameters = @{
                                 MLC_OTP_REGENERATE_QUERY_MOBILE : mobile
                                 };
    
    CTSRestCoreRequest* request =
    [[CTSRestCoreRequest alloc] initWithPath:MLC_OTP_REGENERATE_PATH
                                   requestId:OTPRegenerationRequestId
                                     headers:nil
                                  parameters:parameters
                                        json:nil
                                  httpMethod:MLC_OTP_REGENERATE_TYPE];
    
    [restCore requestAsyncServer:request];
}

- (void)requestIsMobileVerified:(NSString*)mobile
              completionHandler:
(ASIsMobileVerifiedCallback)callback{
    [self addCallback:callback forRequestId:ISMobileVerifiedRequestId];
    
    mobile = [CTSUtility mobileNumberToTenDigitIfValid:mobile];
    
    if (!mobile) {
        [self isMobileVerifiedHelper:NO error:[CTSError getErrorForCode:MobileNotValid]];
        return;
    }
    
    
    NSDictionary* parameters = @{
                                 MLC_OTP_REGENERATE_QUERY_MOBILE : mobile
                                 };
    
    CTSRestCoreRequest* request =
    [[CTSRestCoreRequest alloc] initWithPath:MLC_IS_MOBILE_VERIFIED_PATH
                                   requestId:ISMobileVerifiedRequestId
                                     headers:nil
                                  parameters:parameters
                                        json:nil
                                  httpMethod:MLC_IS_MOBILE_VERIFIED_TYPE];
    
    [restCore requestAsyncServer:request];
}


// For send mobile verification Code
// Use same for regenerate mobile verification Code again
// You can use same method for update mobile number also
- (void)sendMobileVerificationCode:(NSString*)mobile completionHandler:(ASMobileVerifiactionCallback)callback{
    [self addCallback:callback forRequestId:MobileVerificationReqId];
    
    mobile = [CTSUtility mobileNumberToTenDigitIfValid:mobile];
    
    if (!mobile) {
        [self userMobileVerificationHelper:nil error:[CTSError getErrorForCode:MobileNotValid]];
        return;
    }
    
    OauthStatus* oauthStatus = [CTSOauthManager fetchSigninTokenStatus];
    NSString* oauthToken = oauthStatus.oauthToken;
    
    if (oauthStatus.error != nil) {
        [self userMobileVerificationHelper:nil error:oauthStatus.error];
        return;
    }
    
    NSString *jsonString =[NSString stringWithFormat:@"{\"%@\":\"%@\"}",MLC_SEND_MOBILE_VERIFICATION_CODE_QUERY_MOBILE, mobile];
    
    CTSRestCoreRequest* request =
    [[CTSRestCoreRequest alloc] initWithPath:MLC_SEND_MOBILE_VERIFICATION_CODE_PATH
                                   requestId:MobileVerificationReqId
                                     headers:[CTSUtility readOauthTokenAsHeader:oauthToken]
                                  parameters:nil
                                        json:jsonString
                                  httpMethod:MLC_SEND_MOBILE_VERIFICATION_CODE_TYPE];
    [restCore requestAsyncServer:request];
}


- (void)verifyingMobileNumber:(NSString*)verificationCode completionHandler:(ASMobileVerifiactionCallback)callback{
    [self addCallback:callback forRequestId:MobileVerificationReqId];
    
    if (verificationCode.length != 4) {
        [self userMobileVerificationHelper:nil error:[CTSError getErrorForCode:InvalidParameter]];
        return;
    }
    
    OauthStatus* oauthStatus = [CTSOauthManager fetchSigninTokenStatus];
    NSString* oauthToken = oauthStatus.oauthToken;
    
    if (oauthStatus.error != nil) {
        [self userMobileVerificationHelper:nil error:oauthStatus.error];
        return;
    }
    
    NSString *jsonString =[NSString stringWithFormat:@"{\"%@\":\"%@\"}",MLC_VERIFYING_MOBLIE_NUMBER_QUERY_MOBILE, verificationCode];
    
    CTSRestCoreRequest* request =
    [[CTSRestCoreRequest alloc] initWithPath:MLC_VERIFYING_MOBLIE_NUMBER_PATH
                                   requestId:MobileVerificationReqId
                                     headers:[CTSUtility readOauthTokenAsHeader:oauthToken]
                                  parameters:nil
                                        json:jsonString
                                  httpMethod:MLC_VERIFYING_MOBLIE_NUMBER_TYPE];
    [restCore requestAsyncServer:request];
}



- (void)requestSignUpOauthToken {
    wasSignupCalled = YES;
    
    NSDictionary* parameters = @{MLC_OAUTH_TOKEN_QUERY_CLIENT_ID : SubscriptionId,
                                 MLC_OAUTH_TOKEN_QUERY_CLIENT_SECRET : SubscriptionSecretKey,
                                 MLC_OAUTH_TOKEN_QUERY_GRANT_TYPE : MLC_OAUTH_TOKEN_SIGNUP_GRANT_TYPE
                                 };

    CTSRestCoreRequest* request = [[CTSRestCoreRequest alloc]
                                   initWithPath:MLC_OAUTH_TOKEN_SIGNUP_REQ_PATH
                                   requestId:SignupOauthTokenReqId
                                   headers:nil
                                   parameters:parameters
                                   json:nil
                                   httpMethod:POST];    
    [restCore requestAsyncServer:request];
    
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
    if([CTSUtility isEmail:userNameArg]){
        if (![CTSUtility validateEmail:userNameArg]) {
            [self signinHelperUsername:userNameArg
                                 oauth:nil
                                 error:[CTSError getErrorForCode:EmailNotValid]];
            return;
        }
        else{
            [self proceedToSiginUserName:userNameArg password:password];
        }
    }
    else{
        userNameArg = [CTSUtility mobileNumberToTenDigitIfValid:userNameArg];
        
        if (!userNameArg) {
            [self signinHelperUsername:userNameArg
                                 oauth:nil
                                 error:[CTSError getErrorForCode:MobileNotValid]];
            return;
        }
        __block NSString *blockMobile = userNameArg;
        __block NSString *blockPassword = password;
        [self requestIsMobileVerified:userNameArg completionHandler:^(BOOL isVerified, NSError *error) {
            if(isVerified)
                [self proceedToSiginUserName:blockMobile password:blockPassword];
            else{
                [self signinHelperUsername:blockMobile
                                     oauth:nil
                                     error:[CTSError getErrorForCode:MobileNotVerified]];
                return;
            }
        }];
    }
}

-(void)proceedToSiginUserName:(NSString *)username password:(NSString *)password{
    userNameSignIn = username;
    
    NSDictionary* parameters = @{
                                 MLC_OAUTH_TOKEN_QUERY_CLIENT_ID : SignInId,
                                 MLC_OAUTH_TOKEN_QUERY_CLIENT_SECRET : SignInSecretKey,
                                 MLC_OAUTH_TOKEN_QUERY_GRANT_TYPE : MLC_SIGNIN_GRANT_TYPE,
                                 MLC_OAUTH_TOKEN_SIGNIN_QUERY_PASSWORD : password,
                                 MLC_OAUTH_TOKEN_SIGNIN_QUERY_USERNAME : username
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
    
    NSString* oauthToken = [CTSOauthManager readOauthTokenWithExpiryCheck];
    if (oauthToken == nil) {
        [self signupHelperUsername:userNameSignup
                             oauth:[CTSOauthManager readOauthToken]
                        isSignedIn:NO
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
}

- (void)requestChangePasswordUserName:(NSString*)userName
                          oldPassword:(NSString*)oldPassword
                          newPassword:(NSString*)newPassword
                    completionHandler:(ASChangePassword)callback {
    [self addCallback:callback forRequestId:ChangePasswordReqId];
    
    
    if([CTSUtility isEmail:userName]){
        if (![CTSUtility validateEmail:userName]) {
            [self changePasswordHelper:[CTSError getErrorForCode:EmailNotValid]];
            return;
        }
    }
    else{
        userName = [CTSUtility mobileNumberToTenDigitIfValid:userName];
        
        if (!userName) {
            [self changePasswordHelper:[CTSError getErrorForCode:MobileNotValid]];
            return;
        }
        
    }
    
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
}

- (void)requestIsUserCitrusMemberUsername:(NSString*)email
                        completionHandler:
(ASIsUserCitrusMemberCallback)callback {
    [self addCallback:callback forRequestId:IsUserCitrusMemberReqId];
    
    
    if([CTSUtility isEmail:email]){
        if (![CTSUtility validateEmail:email]) {
            [self isUserCitrusMemberHelper:NO
                                     error:[CTSError getErrorForCode:EmailNotValid]];
            
            return;
        }
    }
    else{
        email = [CTSUtility mobileNumberToTenDigitIfValid:email];
        
        if (!email) {
            [self isUserCitrusMemberHelper:NO
                                     error:[CTSError getErrorForCode:MobileNotValid]];
            return;
        }
        
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


-(void)requestVerifyUser:(NSString *)userName completionHandler:
(ASUSerVerificationCallback)callback{
    
    [self addCallback:callback forRequestId:UserVerificationReqId];
    
    if([CTSUtility isEmail:userName]){
        if (![CTSUtility validateEmail:userName]) {
         [self userVerificationHelper:nil error:[CTSError getErrorForCode:EmailNotValid]];
            return;
        }
    }
    else{
        userName = [CTSUtility mobileNumberToTenDigitIfValid:userName];
        
        if (!userName) {
            [self userVerificationHelper:nil error:[CTSError getErrorForCode:MobileNotValid]];
            return;
        }
    }
    
    CTSRestCoreRequest* request = [[CTSRestCoreRequest alloc]
                                   initWithPath:MLC_IS_USER_EXIST_PATH
                                   requestId:UserVerificationReqId
                                   headers:nil
                                   parameters:@{
                                                MLC_IS_USER_EXIST_QUERY_USER : userName
                                                } json:nil
                                   httpMethod:MLC_IS_USER_EXIST_TYPE];
    [restCore requestAsyncServer:request];
}

-(BOOL)isCookieSetAlready{
    BOOL isSet = NO;
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [cookieJar cookies]) {
        if ([cookie.domain rangeOfString:@"citrus" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            isSet = YES;
            break;
        } 
    }
    return isSet;
}

#define IsMobile 1
#define IsEmail 2
- (void)requestIsUserAlreadyRegisteredMobileOrEmail:(NSString*)mobOrEmail
                                  completionHandler:(ASIsUserAlreadyRegistered)callback{
    [self addCallback:callback forRequestId:IsUserAlreadyRegisteredReqId];
    
    int typeOfUsername=0;
    
    if([mobOrEmail rangeOfString:@"@"].location != NSNotFound){
        typeOfUsername = IsEmail;
    }
    else{
        typeOfUsername = IsMobile;
    }
    
    if (typeOfUsername == IsEmail && ![CTSUtility validateEmail:mobOrEmail]) {
        [self isAlreadyRegisteredHelper:nil error:[CTSError getErrorForCode:EmailNotValid]];
        return;
    }
    else {
        mobOrEmail = [CTSUtility mobileNumberToTenDigitIfValid:mobOrEmail];
        if (typeOfUsername == IsMobile &&  !mobOrEmail) {
            [self isAlreadyRegisteredHelper:nil error:[CTSError getErrorForCode:MobileNotValid]];
            
            return;
        }
    }
    
    CTSRestCoreRequest* request = [[CTSRestCoreRequest alloc]
                                   initWithPath:MLC_IS_USER_EXIST_PATH
                                   requestId:IsUserAlreadyRegisteredReqId
                                   headers:nil
                                   parameters:@{
                                                MLC_IS_USER_EXIST_QUERY_USER : mobOrEmail
                                                } json:nil
                                   httpMethod:MLC_IS_USER_EXIST_TYPE];
    
    
    [restCore requestAsyncServer:request];
}


+ (CTSUserVerificationRes *)requestSyncIsUserAlreadyRegisteredMobileOrEmail:(NSString*)mobOrEmail{
    
    CTSRestCoreRequest* request = [[CTSRestCoreRequest alloc]
                                   initWithPath:MLC_IS_USER_EXIST_PATH
                                   requestId:IsUserAlreadyRegisteredReqId
                                   headers:nil
                                   parameters:@{
                                                MLC_IS_USER_EXIST_QUERY_USER : mobOrEmail
                                                } json:nil
                                   httpMethod:MLC_IS_USER_EXIST_TYPE];
    
    
    CTSRestCoreResponse *response = [CTSRestCore requestSyncServer:request withBaseUrl:BaseUrl];
    return  [self convertToUserVerification:response ];
}




- (BOOL)signOut {
    [CTSOauthManager resetOauthData];
    [self deleteSigninCookie];
    return YES;
}

-(void)deleteSigninCookie{

    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [storage cookies]) {
        
        if ([cookie.domain rangeOfString:@"citrus" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            [storage deleteCookie:cookie];
        }
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)isAnyoneSignedIn {
    NSString* signInOauthToken = [CTSOauthManager readOauthTokenWithExpiryCheck];
    if (signInOauthToken == nil)
        return NO;
    else
        return YES;
}

// get Cookie
-(void)requestCitrusPaySignin:(NSString *)userName  password:(NSString*)password
            completionHandler:(ASCitrusSigninCallBack)callBack{
    
    [self addCallback:callBack forRequestId:CitruPaySigniInReqId];

    //validate username
    CTSRestCoreRequest* request = [[CTSRestCoreRequest alloc]
                                   initWithPath:MLC_CITRUS_PAY_AUTH_COOKIE_PATH
                                   requestId:CitruPaySigniInReqId
                                   headers:nil
                                   parameters:@{
                                                MLC_CITRUS_PAY_AUTH_COOKIE_EMAIL:userName,
                                                MLC_CITRUS_PAY_AUTH_COOKIE_PASSWORD:password,
                                                MLC_CITRUS_PAY_AUTH_COOKIE_RMCOOKIE:@"true"
                                                }
                                   json:nil
                                   httpMethod:POST];
    
    [restCore requestAsyncServerDelegation:request];
}


#pragma mark - New Methods

-(void)requestIsUserVerified:(NSString *)userName  completionHandler:(ASIsUserVerified)callback{
    [self addCallback:callback forRequestId:isUserVerifiedRequestId];

    
    NSError* validationError = [CTSUtility verifiyEmailOrMobile:userName];
    if (validationError) {
        [self isUserVerifedHelper:nil error:validationError];
        return;
        
    }
    if(![CTSUtility isEmail:userName]){
        userName = [CTSUtility mobileNumberToTenDigitIfValid:userName];
    }
    
    OauthStatus* oauthStatus = [CTSOauthManager fetchSigninTokenStatus];
    NSString* oauthToken = oauthStatus.oauthToken;
    
    if (oauthStatus.error != nil) {
        [self isUserVerifedHelper:nil error:oauthStatus.error];
        return;
    }
    
    CTSRestCoreRequest* request = [[CTSRestCoreRequest alloc]
                                   initWithPath:MLC_USER_VERIFIED_OAUTH_PATH
                                   requestId:isUserVerifiedRequestId
                                   headers:[CTSUtility readOauthTokenAsHeader:oauthToken]
                                   parameters:@{
                                                MLC_USER_VERIFIED_OAUTH_QUERY_USER : userName
                                                } json:nil
                                   httpMethod:MLC_USER_VERIFIED_OAUTH_TYPE];
    [restCore requestAsyncServer:request];
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
    LogDebug(@"%@", arrayData);
    int x = 0;
    for (int i = 0; i < [val count]; i++) {
        int z = [[val objectAtIndex:(val.count - 1 - i)] intValue];
        if (z < 0) {
            z = z + 256;
        }
        z = z << (8 * i);
        x = x + z;
        LogDebug(@"%d", x);
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
    LogDebug(@"random password:%@", large_CSV_String);
    return large_CSV_String;
}


#pragma mark - main class methods
typedef enum {
    SignupOauthTokenReqId,
    SigninOauthTokenReqId,
    SignupStageOneReqId,
    SignupChangePasswordReqId,
    ChangePasswordReqId,
    RequestForPasswordResetReqId,
    IsUserCitrusMemberReqId,
    UserVerificationReqId,
    IsUserAlreadyRegisteredReqId,
    OTPVerificationRequestId,
    OTPRegenerationRequestId,
    ISMobileVerifiedRequestId,
    isUserVerifiedRequestId,
    CitruPaySigniInReqId,
    BindSigninRequestId,
    MobileVerificationReqId
}AuthRequestId;


- (instancetype)init {
    NSDictionary* dict = [self getRegistrationDict];
    self =
    [super initWithRequestSelectorMapping:dict baseUrl:BaseUrl];
    
    return self;
}

-(NSDictionary *)getRegistrationDict{
    return @{
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
                                                              :),
             toNSString(OTPVerificationRequestId) : toSelector(handleOTPVerfication
                                                               :),
             toNSString(OTPRegenerationRequestId):toSelector(handleOTPRegeneration:),
             toNSString(ISMobileVerifiedRequestId): toSelector(handleIsMobileVerified:),
             toNSString(IsUserAlreadyRegisteredReqId):toSelector(handleIsAlreadyRegistered:),
             toNSString(UserVerificationReqId):toSelector(handleUserVerification:),
             toNSString(isUserVerifiedRequestId):toSelector(handleIsUserVerified:),
             toNSString(CitruPaySigniInReqId) : toSelector(handleCitrusPaySignin:),
             toNSString(BindSigninRequestId) : toSelector(handleBindSignIn:),
             toNSString(MobileVerificationReqId):toSelector(handleMobileVerification:),
             };
}

- (instancetype)initWithUrl:(NSString *)url
{
    
    if(url == nil){
        url = BaseUrl;
    }
    self = [super initWithRequestSelectorMapping:[self getRegistrationDict]
                                         baseUrl:url];
    return self;
}


// 010615 Dynamic Oauth keys init with base URL
- (instancetype)initWithBaseURLAndDynamicVanityOauthKeysURLs:(NSString *)url vanityUrl:(NSString *)vanityUrl signInId:(NSString *)signInId signInSecretKey:(NSString *)signInSecretKey subscriptionId:(NSString *)subscriptionId subscriptionSecretKey:(NSString *)subscriptionSecretKey returnUrl:(NSString *)returnUrl merchantAccessKey:(NSString *)merchantAccessKey{

    if(url){
        BaseUrl = url;
        LogDebug(@"BaseUrl:%@",url);
    }else{
        LogDebug(@"Enter valid BaseUrl");
    }
    
    self = [super initWithRequestSelectorMapping:[self getRegistrationDict]
                                         baseUrl:url];

    //
    if (vanityUrl){
        VanityUrl = vanityUrl;
        LogDebug(@"VanityUrl:%@",VanityUrl);
    }else{
        LogDebug(@"Enter valid VanityUrl");
    }

    //
    if (signInId){
        SignInId = signInId;
        LogDebug(@"SignInId:%@",SignInId);
    }else{
        LogDebug(@"Enter valid SignInId");
    }

    if (signInSecretKey){
        SignInSecretKey = signInSecretKey;
        LogDebug(@"SignInSecretKey:%@",SignInSecretKey);
    }else{
        LogDebug(@"Enter valid SignInSecretKey");
    }

    //
    if (subscriptionId){
        SubscriptionId = subscriptionId;
        LogDebug(@"SubscriptionId:%@",SubscriptionId);
    }else{
        LogDebug(@"Enter valid SubscriptionId");
    }

    if (subscriptionSecretKey){
        SubscriptionSecretKey = subscriptionSecretKey;
        LogDebug(@"SubscriptionSecretKey:%@",SubscriptionSecretKey);
    }else{
        LogDebug(@"Enter valid SubscriptionSecretKey");
    }

    //
    if (returnUrl){
        ReturnUrl = returnUrl;
        LogDebug(@"ReturnUrl:%@",ReturnUrl);
    }else{
        LogDebug(@"Enter valid ReturnUrl");
    }

    //
    if (merchantAccessKey){
        MerchantAccessKey = merchantAccessKey;
        LogDebug(@"MerchantAccessKey:%@",MerchantAccessKey);
    }else{
        LogDebug(@"Enter valid MerchantAccessKey");
    }

    return self;
}


// 010615 Dynamic Oauth keys init with base URL

+ (NSString*)getDynamicSignInId{
    return SignInId;
}

+ (NSString*)getDynamicSignInSecretKey{
    return SignInSecretKey;
}

+ (NSString*)getDynamicSubscriptionId{
    return SubscriptionId;
}

+ (NSString*)getDynamicSubscriptionSecretKey{
    return SubscriptionSecretKey;
}

+ (NSString*)getBaseURL{
    return BaseUrl;
}

+ (NSString*)getVanityUrl{
    return VanityUrl;
}

+ (NSString*)getMerchantAccessKey{
    return MerchantAccessKey;
}


+ (NSString*)getReturnUrl{
    return ReturnUrl;
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
        
        [self requestInternalSignupMobile:mobileSignUp email:userNameSignup firstName:firstNameSignup lastName:lastNameSignup];
    } else {
        [self signupHelperUsername:userNameSignup
                             oauth:[CTSOauthManager readOauthToken]
                        isSignedIn:NO
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

    }
    
    [self signinHelperUsername:userNameSignIn
                                   oauth:[CTSOauthManager readOauthToken]
                                   error:error];
}


- (void)handleReqSignupStageOneComplete:(CTSRestCoreResponse*)response {
    NSError* error = response.error;
    
    // change password
    if(error != nil){
    
        [self signupHelperUsername:userNameSignup
                             oauth:[CTSOauthManager readOauthToken]
                        isSignedIn:NO
                             error:error];
        
        
    }
    else {
    [self requestSigninWithUsername:userNameSignup password:passwordSignUp completionHandler:^(NSString *userName, NSString *token, NSError *error) {
        if(error){
            [self signupHelperUsername:userName
                                 oauth:[CTSOauthManager readOauthToken]
                            isSignedIn:NO
                                 error:nil];
        }
        else{
            [self signupHelperUsername:userName
                                 oauth:[CTSOauthManager readOauthToken]
                            isSignedIn:YES
                                 error:nil];
        }
    }];
    
    }
}

- (void)handleReqUsePassword:(CTSRestCoreResponse*)response {
    LogDebug(@"password changed ");
    
    [self signupHelperUsername:userNameSignup
                         oauth:[CTSOauthManager readOauthToken]
                    isSignedIn:NO
                         error:response.error];
}

- (void)handleReqRequestForPasswordReset:(CTSRestCoreResponse*)response {
    LogDebug(@"password change requested");
    
    
    
    if(response.error){
        CTSError *ctsError = [[response.error userInfo]objectForKey:CITRUS_ERROR_DESCRIPTION_KEY];
        NSDictionary* userInfo = @{
                                   CITRUS_ERROR_DESCRIPTION_KEY : ctsError,
                                   NSLocalizedDescriptionKey :[self getDescrptionForRquestId:RequestForPasswordResetReqId ]
                                   };
        
        
        response.error = [NSError errorWithDomain:CITRUS_ERROR_DOMAIN
                                             code:[response.error code]
                                         userInfo:userInfo];
    }
    
    
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


-(void)handleOTPVerfication:(CTSRestCoreResponse*)response {
    NSError* error = response.error;
    if(error == nil){
        [self otpVerificationHelper:[CTSUtility convertToBool:response.responseString] error:nil];
    }
    else{
        [self otpVerificationHelper:NO error:error];
    }
}

-(void)handleOTPRegeneration:(CTSRestCoreResponse*)response{
    NSError* error = response.error;
    [self otpRegenerationHelperError:error];
}

-(void)handleIsMobileVerified:(CTSRestCoreResponse *)response{
    NSError *error = response.error;
    if(error == nil){
        [self isMobileVerifiedHelper:[CTSUtility convertToBool:response.responseString] error:nil];
    }
    else{
        [self isMobileVerifiedHelper:NO error:error];
    }
}

-(void)handleIsUserVerified:(CTSRestCoreResponse *)response{

    LogDebug(@"response %@",response.responseString);
    
    NSError* error = response.error;
    JSONModelError* jsonError;
    CTSUserVerificationRes* resultObject = nil;
    if(error == nil){
        resultObject =
        [[CTSUserVerificationRes alloc] initWithString:response.responseString
                                                 error:&jsonError];
    }
    
    if(jsonError){
        error = [CTSError getErrorForCode:unknownError];
    }

    [self isUserVerifedHelper:resultObject error:error];
}


+(CTSUserVerificationRes * )convertToUserVerification:(CTSRestCoreResponse *)response {
    NSError* error = response.error;
    JSONModelError* jsonError;
    CTSUserVerificationRes* resultObject = [[CTSUserVerificationRes alloc] init];
    
    if(error == nil){
        resultObject =
        [[CTSUserVerificationRes alloc] initWithString:response.responseString
                                                 error:&jsonError];
    }else{
        resultObject.respMsg = [[response.error userInfo] objectForKey:NSLocalizedDescriptionKey];
    }
    resultObject.error = response.error;
    return resultObject;
}



-(void)handleUserVerification:(CTSRestCoreResponse *)response{
    NSError* error = response.error;
    JSONModelError* jsonError;
    CTSUserVerificationRes* resultObject = nil;
    if(error == nil){
        resultObject =
        [[CTSUserVerificationRes alloc] initWithString:response.responseString
                                                 error:&jsonError];
    }
    
    if(jsonError){
        error = [CTSError getErrorForCode:unknownError];
    }
    
    [self userVerificationHelper:resultObject error:error];
}


-(void)handleMobileVerification:(CTSRestCoreResponse *)response{
    NSError* error = response.error;
    JSONModelError* jsonError;
    CTSMobileVerifiactionRes* resultObject = nil;
    if(error == nil){
        resultObject =
        [[CTSMobileVerifiactionRes alloc] initWithString:response.responseString
                                                 error:&jsonError];
    }
    
    if(jsonError){
        error = [CTSError getErrorForCode:unknownError];
    }
    
    [self userMobileVerificationHelper:resultObject error:error];
}


-(void)handleIsAlreadyRegistered:(CTSRestCoreResponse *)response{
    CTSUserVerificationRes *veriRes = [CTSAuthLayer convertToUserVerification:response];
    NSError* error = response.error;
    [self isAlreadyRegisteredHelper:veriRes error:error];
}


-(void)handleCitrusPaySignin:(CTSRestCoreResponse *)response{
    LogDebug(@"handleCitrusPaySignin: THREAD %@", [NSThread currentThread]);
    
    [self citrusPaySigninHelper:(NSError *)response.data];
}

-(void)handleBindSignIn:(CTSRestCoreResponse *)response{
    
    //if no error
    //save singin token
    
    //call helper for binduser
    
    NSError* error = response.error;
    JSONModelError* jsonError;
    // signup flow
    if (error == nil) {
        CTSOauthTokenRes* resultObject =
        [[CTSOauthTokenRes alloc] initWithString:response.responseString
                                           error:&jsonError];
        [resultObject logProperties];
        [CTSOauthManager saveOauthData:resultObject];
    }
    [self bindUserHelperUsernameError:error];
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
    }
}

- (void)signupHelperUsername:(NSString*)username
                       oauth:(NSString*)token
                  isSignedIn:(BOOL)isSignedIn
                       error:(NSError*)error {
    ASSignupCallBack callBack =
    [self retrieveAndRemoveCallbackForReqId:SignupOauthTokenReqId];
    
    wasSignupCalled = NO;
    
    if (error != nil) {
        [CTSOauthManager resetOauthData];
    }
    
    
    error = [self dumbSignupErrorConverter:error];
    
    if (callBack != nil) {
        callBack(username, token, isSignedIn,error);
    }
    [self resetSignupCredentials];
}

- (void)changePasswordHelper:(NSError*)error {
    ASChangePassword callback =
    [self retrieveAndRemoveCallbackForReqId:ChangePasswordReqId];
    
    if (callback != nil) {
        callback(error);
    }
}

- (void)isUserCitrusMemberHelper:(BOOL)isMember error:(NSError*)error {
    ASIsUserCitrusMemberCallback callback =
    [self retrieveAndRemoveCallbackForReqId:IsUserCitrusMemberReqId];
    if (callback != nil) {
        callback(isMember, error);
    }
}

- (void)resetPasswordHelper:(NSError*)error {
    ASResetPasswordCallback callback =
    [self retrieveAndRemoveCallbackForReqId:RequestForPasswordResetReqId];
    if (callback != nil) {
        callback(error);
    }
}


-(void)otpVerificationHelper:(BOOL)isVerified error:(NSError *)error{
    ASOtpVerificationCallback callback = [self retrieveAndRemoveCallbackForReqId:OTPVerificationRequestId];
    if(callback != nil){
        callback(isVerified,error);
    }
}


-(void)otpRegenerationHelperError:(NSError *)error{
    ASOtpRegenerationCallback callback = [self retrieveAndRemoveCallbackForReqId:OTPRegenerationRequestId];
    if(callback != nil){
        callback(error);
    }
 }

-(void)isMobileVerifiedHelper:(BOOL)isVerified error:(NSError *)error{
    ASIsMobileVerifiedCallback callback = [self retrieveAndRemoveCallbackForReqId:ISMobileVerifiedRequestId];
    if(callback != nil){
        callback(isVerified,error);
    }
}

-(void)isAlreadyRegisteredHelper:(CTSUserVerificationRes *)userVerification error:(NSError *)error{
    
    ASIsUserAlreadyRegistered callback = [self retrieveAndRemoveCallbackForReqId:IsUserAlreadyRegisteredReqId];
    if(callback != nil){
        callback(userVerification,error);
    }
}

-(void)userVerificationHelper:(CTSUserVerificationRes *)verificationRes error:(NSError *)error{
    ASUSerVerificationCallback callback = [self retrieveAndRemoveCallbackForReqId:UserVerificationReqId];
    if(callback != nil){
        callback(verificationRes,error);
    }
}

-(void)userMobileVerificationHelper:(CTSMobileVerifiactionRes *)mobileVerifiactionRes error:(NSError *)error{
    ASMobileVerifiactionCallback callback = [self retrieveAndRemoveCallbackForReqId:MobileVerificationReqId];
    if(callback != nil){
        callback(mobileVerifiactionRes,error);
    }
}


-(void)isUserVerifedHelper:(CTSUserVerificationRes *)verification error:(NSError *)error{
    ASIsUserVerified callback = [self retrieveAndRemoveCallbackForReqId:isUserVerifiedRequestId];
    if(callback !=nil){
        callback(verification,error);
    }
}

-(void)citrusPaySigninHelper:(NSError *)error{
    
    ASCitrusSigninCallBack callback =
    [self retrieveAndRemoveCallbackForReqId:CitruPaySigniInReqId];
    if (callback != nil) {
        callback(error);
    }
}

- (void)bindUserHelperUsernameError:(NSError*)error {
    ASBindCallBack callback =
    [self retrieveAndRemoveCallbackForReqId:BindSigninRequestId];
    if (callback != nil) {
        callback(error);
    } 
}

- (void)resetSignupCredentials {
    userNameSignup = @"";
    mobileSignUp = @"";
    passwordSignUp = @"";
    firstNameSignup = @"";
    lastNameSignup = @"";
    sourceTypeSignup = @"";
}



-(NSString *)getDescrptionForRquestId:(AuthRequestId)reqId{
    NSString *errorDes = nil;
    switch (reqId) {
        case RequestForPasswordResetReqId:
          errorDes =  @"Email ID invalid or not registered with Citrus. Please use a different Email ID.";
            break;
            
        default:
            errorDes =@"Oops something went wrong!";
            break;
    }
    return errorDes;
}

-(NSError *)dumbSignupErrorConverter:(NSError *)error{
    if([error code] == USER_EXIST_EXCEPTION){
        CTSRestError *ctsError = [[error userInfo]objectForKey:CITRUS_ERROR_DESCRIPTION_KEY];
         error = [self dumbReplaceDescription:error description:[CTSError userNameSpecificDes:ctsError.description]];
    
    }
    return error;
}

-(NSError *)dumbReplaceDescription:(NSError *)error description:(NSString *)newDescription{
    CTSRestError *ctsError = [[error userInfo]objectForKey:CITRUS_ERROR_DESCRIPTION_KEY];
    NSDictionary* userInfo = @{
                               CITRUS_ERROR_DESCRIPTION_KEY : ctsError,
                               NSLocalizedDescriptionKey :newDescription
                               };
    
    
    return [NSError errorWithDomain:CITRUS_ERROR_DOMAIN
                                         code:[error code]
                                     userInfo:userInfo];
}


@end
