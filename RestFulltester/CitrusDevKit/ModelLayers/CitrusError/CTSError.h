//
//  CTSError.h
//  CTS iOS Sdk
//
//  Created by Yadnesh Wankhede on 26/06/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CTSPaymentTransactionRes.h"

typedef enum {
    NoError,
    UserNotSignedIn,
    EmailNotValid,
    MobileNotValid,
    FirstNameNotValid,
    LastNameNotValid,
    CvvNotValid,
    CardNumberNotValid,
    ExpiryDateNotValid,
    ServerErrorWithCode,
    InvalidParameter,
    OauthTokenExpired,
    CantFetchSignupToken,
    UserExits,
    TokenMissing,
    MobileAlreadyExits = 212,
    MobileNotVerified = 210,
    unknownError = 222,
    ReturnUrlNotValid,
    PrepaidBillFetchFailed,
    WrongBill,
    NoViewController,
    InvalidOTP
} CTSErrorCode;


typedef enum {
    USER_EXIST_EXCEPTION = 200, //user already exists
    EXPIRED_OTP_EXCEPTION = 201, //entered otp is expired
    INVALID_OTP_EXCEPTION = 202, //invalid otp
    USER_NOT_EXIST_EXCEPTION = 203 ,//user not exists
    RESET_EXCEPTION = 204, //reset exception
    INTERNAL_SERVER_EXCEPTION = 205, //500 response from server( internal server error)
    BAD_CREDENTIALS_EXCEPTION = 206, //invalid login password combo
    USER_LOCKED_EXCEPTION = 207, //user locked
    USER_NOT_LOGGED_IN_EXCEPTION = 208, //user not logged in
    INVALID_PASSWORD_EXCEPTION = 209, //invalid old password
    
    UNKNOWN_EXCEPTION = 222, //all exceptions except above all
} SDKExceptionCode;


#define USER_EXIST_MESSAGE @"com.citruspay.directory.exception.CitrusUserAlreadyExistsException"

#define UPDATE_MOBILE_MESSAGE @"com.citruspay.common.subscription.util.UserAlreadyExistsException"

#define USER_NOT_EXISTS_MESSAGE @"com.citruspay.directory.exception.CitrusUserNotFoundException"

#define USER_NOT_EXISTS_RESET_MESSAGE @"com.citruspay.common.subscription.util.UserNotFoundException"

#define USER_OTP_EXPIRE_MESSAGE @"com.citruspay.common.verificationservice.exception.ExpiredOTPException"

#define USER_OTP_INVALID_MESSAGE @"com.citruspay.common.verificationservice.exception.InvalidOTPException"

#define INTERNAL_SERVER_MESSAGE @"Internal Server Exception"

#define BAD_CREDENTIALS @"BadCredentials"

#define USER_LOCKED @"UserLocked"

#define USER_NOT_LOGGED_IN @"GrantTypeMismatch"

#define INVALID_PASSWORD @"javax.security.auth.login.CredentialException"

#define INVALID_GRANT @"invalid_grant"

#define DEFAULT_MESSAGE @"Something Went Wrong!!!"



#define CITRUS_ERROR_DOMAIN @"com.citrus.errorDomain"
#define CITRUS_ERROR_DESCRIPTION_KEY @"CTSServerErrorDescription"

@interface CTSError : NSObject
{
}
// Follwoing methods are for internal use only
+ (NSError*)getErrorForCode:(CTSErrorCode)code;
+ (NSError*)getServerErrorWithCode:(int)errorCode
                          withInfo:(NSDictionary*)information;
+ (id)sharedManager ;
+(NSString *)userNameSpecificDes:(NSString*)userName;
+ (NSString*)getSDKDescriptionForCode:(SDKExceptionCode)code;
+(SDKExceptionCode)getSDKExceptionCode:(NSString*)errorType;
+(NSError *)errorForStatusCode:(int)statusCode;
+(NSError *)convertToError:(CTSPaymentTransactionRes *)ctsPaymentTxRes;
@end
