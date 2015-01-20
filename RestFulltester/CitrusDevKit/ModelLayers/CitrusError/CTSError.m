//
//  CTSError.m
//  CTS iOS Sdk
//
//  Created by Yadnesh Wankhede on 26/06/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import "CTSError.h"

@implementation CTSError

+ (id)sharedManager {
    static CTSError *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
        [sharedMyManager initDict];
             });
    return sharedMyManager;
}

-(void)initDict{
//    dumbDict =  @{
//                  @"com.citruspay.directory.exception.CitrusUserAlreadyExistsException":@"The Email ID/Mobile Number entered by you already exists. Please use a different Email ID/Mobile Number.",
//                  @"com.citruspay.common.subscription.util.UserAlreadyExistsException":@"The Email ID/Mobile Number entered by you already exists. Please use a different Email ID/Mobile Number.",
//                  @"com.citruspay.directory.exception.CitrusUserNotFoundException":@"Your mobile number was not found for OTP verification.",
//                  @"com.citruspay.common.subscription.util.UserNotFoundException":@"The Email ID/Mobile Number entered by you already exists. Please use a different Email ID/Mobile Number.",
//                  @"com.citruspay.common.verificationservice.exception.ExpiredOTPException":@"OTP entered by you is expired. Please regenerate a new OTP for verification.",
//                  @"com.citruspay.common.verificationservice.exception.InvalidOTPException":@"The OTP Entered by you is invalid. Please enter the correct OTP.",
//                  @"javax.security.auth.login.CredentialException":@"Invalid current password. Please make sure your current password is correct."};
}


+ (NSError*)getErrorForCode:(CTSErrorCode)code {
    NSString* errorDescription = @"CitrusDefaultError";
    
    switch (code) {
        case UserNotSignedIn:
            errorDescription = @"This proccess cannot be completed without signing "
            @"in,please signin";
            break;
        case EmailNotValid:
            errorDescription =
            @"email adress format not valid";
            break;
        case MobileNotValid:
            errorDescription = @"mobile number not valid";
            break;
        case CvvNotValid:
            errorDescription = @"cvv format not valid, expected 3 digits for non "
            @"amex and 4 for amex";
            break;
        case CardNumberNotValid:
            errorDescription = @"card number not valid";
            break;
        case ExpiryDateNotValid:
            errorDescription = @"wrong expiry date format,expected - \"mm/yyyy\" ";
            break;
        case ServerErrorWithCode:
            errorDescription = @"server sent error code";
        case InvalidParameter:
            errorDescription = @"invalid parameter passed to method";
        case OauthTokenExpired:
            errorDescription = @"Oauth Token expired, Please refresh it from server";
        case CantFetchSignupToken:
            errorDescription = @"Can not fetch Signup Oauth token from merchant";
        case TokenMissing:
            errorDescription = @"Token for payment is missing";
        case FirstNameNotValid:
            errorDescription = @"First name not valid";
        case LastNameNotValid:
            errorDescription = @"Last name not valid";
        case MobileNotVerified:
            errorDescription = @"Mobile number not verified, Please verify it.";

        default:
            break;
    }
    NSDictionary* userInfo = @{NSLocalizedDescriptionKey : errorDescription};
    
    return
    [NSError errorWithDomain:CITRUS_ERROR_DOMAIN code:code userInfo:userInfo];
}

+ (NSError*)getServerErrorWithCode:(int)errorCode
                          withInfo:(NSDictionary*)information {
    NSMutableDictionary* userInfo =
    [[NSMutableDictionary alloc] initWithDictionary:information];
    
    [userInfo addEntriesFromDictionary:@{
                                         NSLocalizedDescriptionKey :
                                             [NSString stringWithFormat:@"Server threw an error,code %d", errorCode]
                                         }];
    
    return [NSError errorWithDomain:CITRUS_ERROR_DOMAIN
                               code:ServerErrorWithCode
                           userInfo:userInfo];
}

- (NSError*)getSDKErrorWithType:(NSString*)type
                          withInfo:(NSDictionary*)information {
    
    return [CTSError getSDKErrorForCode:[self getSDKExceptionCode:type]];
}

-(SDKExceptionCode)getSDKExceptionCode:(NSString*)errorType{
    
    if ([errorType isEqualToString:USER_EXIST_MESSAGE]){
        return USER_EXIST_EXCEPTION;
    }else if ([errorType isEqualToString:UPDATE_MOBILE_MESSAGE]){
        return EXPIRED_OTP_EXCEPTION;
    }else if ([errorType isEqualToString:USER_NOT_EXISTS_MESSAGE]){
        return USER_NOT_EXIST_EXCEPTION;
    }else if ([errorType isEqualToString:USER_NOT_EXISTS_RESET_MESSAGE]){
        return USER_NOT_EXIST_EXCEPTION;
    }else if ([errorType isEqualToString:USER_OTP_EXPIRE_MESSAGE]){
        return EXPIRED_OTP_EXCEPTION;
    }else if ([errorType isEqualToString:USER_OTP_INVALID_MESSAGE]){
        return INVALID_OTP_EXCEPTION;
    }else if ([errorType isEqualToString:INTERNAL_SERVER_MESSAGE]){
        return INTERNAL_SERVER_EXCEPTION;
    }else if ([errorType isEqualToString:BAD_CREDENTIALS]){
        return BAD_CREDENTIALS_EXCEPTION;
    }else if ([errorType isEqualToString:USER_LOCKED]){
        return USER_LOCKED_EXCEPTION;
    }else if ([errorType isEqualToString:USER_NOT_LOGGED_IN]){
        return USER_NOT_LOGGED_IN_EXCEPTION;
    }else if ([errorType isEqualToString:INVALID_PASSWORD]){
        return INVALID_PASSWORD_EXCEPTION;
    }else{
        return UNKNOWN_EXCEPTION;
    }
}

+ (NSError*)getSDKErrorForCode:(SDKExceptionCode)code {
    NSString* errorDescription;
    switch (code) {
        case USER_EXIST_EXCEPTION:
            errorDescription = @"The Email ID/Mobile Number entered by you already exists. Please use a different Email ID/Mobile Number.";
        break;
        case EXPIRED_OTP_EXCEPTION:
            errorDescription = @"OTP entered by you is expired. Please regenerate a new OTP for verification.";
        break;
        case INVALID_OTP_EXCEPTION:
            errorDescription = @"The OTP Entered by you is invalid. Please enter the correct OTP.";
        break;
        case USER_NOT_EXIST_EXCEPTION:
            errorDescription = @"Your mobile number was not found for OTP verification.";
        break;
        case RESET_EXCEPTION:
            errorDescription = @"Reset Exception";
        break;
        case INTERNAL_SERVER_EXCEPTION:
            errorDescription = @"Please enter a valid Mobile Number.";
        break;
        case BAD_CREDENTIALS_EXCEPTION:
            errorDescription = @"Invalid login credentials. Please make sure the entered credentials are are correct.";
        case USER_LOCKED_EXCEPTION:
            errorDescription = @"We're sorry, your account is temporarily locked. Please contact our customer care for further assistance.";
        case USER_NOT_LOGGED_IN_EXCEPTION:
            errorDescription = nil;
        case INVALID_PASSWORD_EXCEPTION:
            errorDescription = @"Invalid current password. Please make sure your current password is correct.";
        case UNKNOWN_EXCEPTION:
            errorDescription = @"Oops... Something went wrong.";
        default:
          errorDescription = @"Oops... Something went wrong.";

        break;
    }
    
    NSDictionary* userInfo = @{NSLocalizedDescriptionKey : errorDescription};
    return [NSError errorWithDomain:CITRUS_ERROR_DOMAIN code:code userInfo:userInfo];
}

//-(NSString *)dumbConversion:(NSString*)errorDes{
//
//    for(NSString *from in [dumbDict allKeys]){
//        if ([[errorDes uppercaseString] isEqualToString:[from uppercaseString]]) {
//            return [dumbDict valueForKey:from];
//        }
//    }
//    return nil;
//}



@end
