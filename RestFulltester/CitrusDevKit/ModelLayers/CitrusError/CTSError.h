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
  CvvNotValid,
  CardNumberNotValid,
  ExpiryDateNotValid,
  ServerErrorWithCode,
  InvalidParameter
} CTSErrorCode;

#define CITRUS_ERROR_DOMAIN @"com.citrus.errorDomain"

@interface CTSError : NSObject
+ (NSError*)getErrorForCode:(CTSErrorCode)code;
+ (NSError*)getServerErrorWithCode:(int)errorCode;

@end
