//
//  CTSProfileLayer.m
//  RestFulltester
//
//  Created by Yadnesh Wankhede on 04/06/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import "CTSProfileLayer.h"
#import "CTSProfileLayerConstants.h"
#import "CTSTypeToParameterMapping.h"
#import "CTSContactUpdate.h"
#import "CTSRestRegister.h"
#import "CTSProfileContactRes.h"
#import "CTSAuthLayerConstants.h"
#import "CTSError.h"
#import "CTSOauthManager.h"
@implementation CTSProfileLayer
@synthesize delegate;
// get profile
// update profile
#ifdef DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_ERROR;
#endif
- (instancetype)init {
  self = [super init];
  if (self) {
    restService =
        [[CTSRestLayer alloc] initWithBaseURL:CITRUS_PROFILE_BASE_URL];
    [restService register:[self formRegistrationArray]];
    [restService complexObjectRegister];
    [restService registerComplexRes];
    restService.delegate = self;
  }
  return self;
}

- (NSArray*)formRegistrationArray {
  NSMutableArray* registrationArray = [[NSMutableArray alloc] init];
  CTSRestRegister* profileContactUpdate = [[CTSRestRegister alloc]
         initWithPath:MLC_PROFILE_UPDATE_CONTACT_PATH
           httpMethod:MLC_PROFILE_UPDATE_CONTACT_METHOD
       requestMapping:[[CTSTypeToParameterMapping alloc]
                          initWithType:MLC_PROFILE_UPDATE__REQUEST_TYPE
                            parameters:MLC_PROFILE_UPDATE__REQUEST_MAPPING]
      responseMapping:nil];

  CTSRestRegister* profileContactGet = [[CTSRestRegister alloc]
         initWithPath:MLC_PROFILE_UPDATE_CONTACT_PATH
           httpMethod:MLC_PROFILE_GET_CONTACT_METHOD
       requestMapping:nil
      responseMapping:[[CTSTypeToParameterMapping alloc]
                          initWithType:MLC_PROFILE_GET_RESPONSE_TYPE
                            parameters:MLC_PROFILE_GET_CONTACT_RES_MAPPING]];

  [registrationArray addObject:profileContactUpdate];
  [registrationArray addObject:profileContactGet];

  return registrationArray;
}

#pragma mark - class methods
- (void)updateContactInformation:(CTSContactUpdate*)contactInfo {
  if ([CTSOauthManager readOauthToken] == nil) {
    [delegate
        contactInfoUpdatedError:[CTSError getErrorForCode:UserNotSignedIn]];
    return;
  }
  [restService putObject:contactInfo
                  atPath:MLC_PROFILE_UPDATE_CONTACT_PATH
              withHeader:[CTSUtility readSigninTokenAsHeader]
          withParameters:nil
                withInfo:MLC_PROFILE_UPDATE_CONTACT_ID];
}

- (void)requestContactInformation {
  if ([CTSOauthManager readOauthToken] == nil) {
    [delegate contactInformation:nil
                           error:[CTSError getErrorForCode:UserNotSignedIn]];
    return;
  }
  [restService getObjectAtPath:MLC_PROFILE_UPDATE_CONTACT_PATH
                    withHeader:[CTSUtility readSigninTokenAsHeader]
                withParameters:nil
                      withInfo:MLC_PROFILE_GET_CONTACT_ID];
}

- (void)updatePaymentInformation:(CTSPaymentDetailUpdate*)paymentInfo {
  if ([CTSOauthManager readOauthToken] == nil) {
    [delegate contactInformation:nil
                           error:[CTSError getErrorForCode:UserNotSignedIn]];
    return;
  } else {
    CTSErrorCode error = [paymentInfo validate];
    if (error != NoError) {
      [delegate contactInformation:nil error:[CTSError getErrorForCode:error]];
      return;
    }
  }

  [paymentInfo logProperties];
  [[paymentInfo.paymentOptions objectAtIndex:0] logProperties];
  [restService putObject:paymentInfo
                  atPath:MLC_PROFILE_UPDATE_PAYMENT_PATH
              withHeader:[CTSUtility readSigninTokenAsHeader]
          withParameters:nil
                withInfo:MLC_PROFILE_UPDATE_PAYMENT_ID];
}

- (void)requestPaymentInformation {
  if ([CTSOauthManager readOauthToken] == nil) {
    [delegate paymentInformation:nil
                           error:[CTSError getErrorForCode:UserNotSignedIn]];
    return;
  }

  [restService getObjectAtPath:MLC_PROFILE_UPDATE_PAYMENT_PATH
                    withHeader:[CTSUtility readSigninTokenAsHeader]
                withParameters:nil
                      withInfo:MLC_PROFILE_GET_PAYMENT_ID];
}

#pragma mark - CTSRestLayerProtocol methods
- (void)receivedObjectArray:(NSArray*)responseArray
                    forPath:(NSString*)path
                  withError:(NSError*)error
                   withInfo:(NSString*)info {
  DDLogInfo(@" path %@", path);
  BOOL isSuccess = NO;

  if (error == nil)
    isSuccess = YES;
  DDLogInfo(@"path %@ , info %@", path, info);
  if ([info isEqualToString:MLC_PROFILE_GET_CONTACT_ID]) {
    for (CTSProfileContactRes* result in responseArray) {
      [result logProperties];
      [delegate contactInformation:result error:error];
    }
  } else if ([info isEqualToString:MLC_PROFILE_UPDATE_CONTACT_ID]) {
    [delegate contactInfoUpdatedError:nil];
  } else if ([info isEqualToString:MLC_PROFILE_GET_PAYMENT_ID]) {
    DDLogInfo(@"MLC_PROFILE_GET_PAYMENT_ID");
    for (CTSProfilePaymentRes* result in responseArray) {
      [delegate paymentInformation:result error:error];
    }
  } else if ([info isEqualToString:MLC_PROFILE_UPDATE_PAYMENT_ID]) {
    DDLogInfo(@"MLC_PROFILE_UPDATE_PAYMENT_ID");
    [delegate paymentInfoUpdatedError:error];
  }
}

@end
