//
//  CTSError.h
//  CTS iOS Sdk
//
//  Created by Yadnesh Wankhede on 26/06/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import <Foundation/Foundation.h>
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
    TokenMissing

} CTSErrorCode;

#define CITRUS_ERROR_DOMAIN @"com.citrus.errorDomain"
#define CITRUS_ERROR_DESCRIPTION_KEY @"CTSServerErrorDescription"

@interface CTSError : NSObject
// Follwoing methods are for internal use only
+ (NSError*)getErrorForCode:(CTSErrorCode)code;
+ (NSError*)getServerErrorWithCode:(int)errorCode
                          withInfo:(NSDictionary*)information;
@end
