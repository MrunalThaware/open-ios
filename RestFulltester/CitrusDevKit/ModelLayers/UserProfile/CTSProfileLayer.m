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

//- (NSArray*)formRegistrationArray {
//  NSMutableArray* registrationArray = [[NSMutableArray alloc] init];
//  CTSRestRegister* profileContactUpdate = [[CTSRestRegister alloc]
//         initWithPath:MLC_PROFILE_UPDATE_CONTACT_PATH
//           httpMethod:MLC_PROFILE_UPDATE_CONTACT_METHOD
//       requestMapping:[[CTSTypeToParameterMapping alloc]
//                          initWithType:MLC_PROFILE_UPDATE__REQUEST_TYPE
//                            parameters:MLC_PROFILE_UPDATE__REQUEST_MAPPING]
//      responseMapping:nil];
//
//  CTSRestRegister* profileContactGet = [[CTSRestRegister alloc]
//         initWithPath:MLC_PROFILE_UPDATE_CONTACT_PATH
//           httpMethod:MLC_PROFILE_GET_CONTACT_METHOD
//       requestMapping:nil
//      responseMapping:[[CTSTypeToParameterMapping alloc]
//                          initWithType:MLC_PROFILE_GET_RESPONSE_TYPE
//                            parameters:MLC_PROFILE_GET_CONTACT_RES_MAPPING]];
//
//  [registrationArray addObject:profileContactUpdate];
//  [registrationArray addObject:profileContactGet];
//
//  return registrationArray;
//}

#pragma mark - class methods
- (void)updateContactInformation:(CTSContactUpdate*)contactInfo {
  if ([CTSOauthManager readOauthToken] == nil) {
    [delegate
        contactInfoUpdatedError:[CTSError getErrorForCode:UserNotSignedIn]];
    return;
  }
  //  [restService putObject:contactInfo
  //                  atPath:MLC_PROFILE_UPDATE_CONTACT_PATH
  //              withHeader:[CTSUtility readSigninTokenAsHeader]
  //          withParameters:nil
  //                withInfo:MLC_PROFILE_UPDATE_CONTACT_ID];

  CTSRestCoreRequest* request = [[CTSRestCoreRequest alloc]
      initWithPath:MLC_PROFILE_UPDATE_CONTACT_PATH
         requestId:ProfileUpdateContactReqId
           headers:[CTSUtility readSigninTokenAsHeader]
        parameters:nil
              json:[contactInfo toJSONString]
        httpMethod:POST];

  [restCore requestServer:request];
}

- (void)requestContactInformation {
  if ([CTSOauthManager readOauthToken] == nil) {
    [delegate contactInformation:nil
                           error:[CTSError getErrorForCode:UserNotSignedIn]];
    return;
  }
  //  [restService getObjectAtPath:MLC_PROFILE_UPDATE_CONTACT_PATH
  //                    withHeader:[CTSUtility readSigninTokenAsHeader]
  //                withParameters:nil
  //                      withInfo:MLC_PROFILE_GET_CONTACT_ID];

  CTSRestCoreRequest* request = [[CTSRestCoreRequest alloc]
      initWithPath:MLC_PROFILE_UPDATE_CONTACT_PATH
         requestId:ProfileGetContactReqId
           headers:[CTSUtility readSigninTokenAsHeader]
        parameters:nil
              json:nil
        httpMethod:GET];

  [restCore requestServer:request];
}

- (void)updatePaymentInformation:(CTSPaymentDetailUpdate*)paymentInfo {
  NSString* oauthToken = [CTSOauthManager readOauthToken];
  if (oauthToken == nil) {
    [delegate contactInformation:nil
                           error:[CTSError getErrorForCode:UserNotSignedIn]];
    return;
  } else {
    CTSErrorCode error = [paymentInfo validate];
    if (error != NoError) {
      [delegate contactInformation:nil error:[CTSError getErrorForCode:error]];
      // return;
    }
  }

  //  [paymentInfo logProperties];
  //  [[paymentInfo.paymentOptions objectAtIndex:0] logProperties];
  //  [restService putObject:paymentInfo
  //                  atPath:MLC_PROFILE_UPDATE_PAYMENT_PATH
  //              withHeader:[CTSUtility readSigninTokenAsHeader]
  //          withParameters:nil
  //                withInfo:MLC_PROFILE_UPDATE_PAYMENT_ID];

  CTSRestCoreRequest* request = [[CTSRestCoreRequest alloc]
      initWithPath:MLC_PROFILE_UPDATE_PAYMENT_PATH
         requestId:ProfileUpdatePaymentReqId
           headers:[CTSUtility readOauthTokenAsHeader:oauthToken]
        parameters:nil
              json:[paymentInfo toJSONString]
        httpMethod:PUT];

  [restCore requestServer:request];
}

- (void)requestPaymentInformation {
  NSString* oauthToken = [CTSOauthManager readOauthToken];

  if (oauthToken == nil) {
    [delegate paymentInformation:nil
                           error:[CTSError getErrorForCode:UserNotSignedIn]];
    return;
  }

  //  [restService getObjectAtPath:MLC_PROFILE_UPDATE_PAYMENT_PATH
  //                    withHeader:[CTSUtility readSigninTokenAsHeader]
  //                withParameters:nil
  //                      withInfo:MLC_PROFILE_GET_PAYMENT_ID];

  CTSRestCoreRequest* request = [[CTSRestCoreRequest alloc]
      initWithPath:MLC_PROFILE_UPDATE_PAYMENT_PATH
         requestId:ProfileGetPaymentReqId
           headers:[CTSUtility readOauthTokenAsHeader:oauthToken]
        parameters:nil
              json:nil
        httpMethod:GET];
  [restCore requestServer:request];
}

//#pragma mark - CTSRestLayerProtocol methods
//- (void)receivedObjectArray:(NSArray*)responseArray
//                    forPath:(NSString*)path
//                  withError:(NSError*)error
//                   withInfo:(NSString*)info {
//  DDLogInfo(@" path %@", path);
//  BOOL isSuccess = NO;
//
//  if (error == nil)
//    isSuccess = YES;
//  DDLogInfo(@"path %@ , info %@", path, info);
//  if ([info isEqualToString:MLC_PROFILE_GET_CONTACT_ID]) {
//    for (CTSProfileContactRes* result in responseArray) {
//      [result logProperties];
//      [delegate contactInformation:result error:error];
//    }
//  } else if ([info isEqualToString:MLC_PROFILE_UPDATE_CONTACT_ID]) {
//    [delegate contactInfoUpdatedError:nil];
//  } else if ([info isEqualToString:MLC_PROFILE_GET_PAYMENT_ID]) {
//    DDLogInfo(@"MLC_PROFILE_GET_PAYMENT_ID");
//    for (CTSProfilePaymentRes* result in responseArray) {
//      [delegate paymentInformation:result error:error];
//    }
//  } else if ([info isEqualToString:MLC_PROFILE_UPDATE_PAYMENT_ID]) {
//    DDLogInfo(@"MLC_PROFILE_UPDATE_PAYMENT_ID");
//    [delegate paymentInfoUpdatedError:error];
//  }
//}

#pragma mark - new methods
enum {
  ProfileGetContactReqId,
  ProfileUpdateContactReqId,
  ProfileGetPaymentReqId,
  ProfileUpdatePaymentReqId
};

- (instancetype)init {
  NSDictionary* dic = @{
    toNSString(ProfileGetContactReqId) : toSelector(handleReqProfileGetContact
                                                    :),
    toNSString(ProfileUpdateContactReqId) :
        toSelector(handleProfileUpdateContact
                   :),
    toNSString(ProfileGetPaymentReqId) : toSelector(handleProfileGetPayment
                                                    :),
    toNSString(ProfileUpdatePaymentReqId) :
        toSelector(handleProfileUpdatePayment
                   :)
  };

  self = [super initWithRequestSelectorMapping:dic
                                       baseUrl:CITRUS_PROFILE_BASE_URL];

  return self;
}
- (void)handleReqProfileGetContact:(CTSRestCoreResponse*)response {
  NSError* error = response.error;
  JSONModelError* jsonError;
  CTSProfileContactRes* contact = nil;
  if (error == nil) {
    contact =
        [[CTSProfileContactRes alloc] initWithString:response.responseString
                                               error:&jsonError];
    [contact logProperties];
  }
  [delegate contactInformation:contact error:error];
}

- (void)handleProfileUpdateContact:(CTSRestCoreResponse*)response {
  [delegate contactInfoUpdatedError:response.error];
}

- (void)handleProfileGetPayment:(CTSRestCoreResponse*)response {
  NSError* error = response.error;
  JSONModelError* jsonError;
  CTSProfilePaymentRes* paymentDetails = nil;

  if (error == nil) {
    paymentDetails =
        [[CTSProfilePaymentRes alloc] initWithString:response.responseString
                                               error:&jsonError];
  }

  [delegate paymentInformation:paymentDetails error:error];
}

- (void)handleProfileUpdatePayment:(CTSRestCoreResponse*)response {
  [delegate paymentInfoUpdatedError:response.error];
}
@end
