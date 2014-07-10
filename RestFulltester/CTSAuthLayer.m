//
//  CTSAuthLayer.m
//  RestFulltester
//
//  Created by Yadnesh Wankhede on 23/05/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import "CTSAuthLayer.h"
#import "CTSRestLayer.h"
#import "RestLayerConstants.h"
#import "CTSAuthLayerConstants.h"
#import "CTSSignUpRes.h"
#import "Logging.h"
#import <CommonCrypto/CommonDigest.h>
#ifndef MIN
#import <NSObjCRuntime.h>
#endif

#ifdef DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_ERROR;
#endif
@implementation CTSAuthLayer
@synthesize delegate;

//+ (id)sharedRestLayer {
//  static CTSAuthLayer* sharedInstance = nil;
//  static dispatch_once_t onceToken;
//  dispatch_once(&onceToken, ^{ sharedInstance = [[self alloc] init]; });
//  return sharedInstance;
//}

- (instancetype)init {
  self = [super init];
  if (self) {
    restService = [[CTSRestLayer alloc] initWithBaseURL:CITRUS_AUTH_BASE_URL];
    [restService register:[self formRegistrationArray]];
    restService.delegate = self;
    userNameSignIn = @"";
    wasSignupCalled = NO;
  }
  return self;
}

- (NSArray*)formRegistrationArray {
  NSMutableArray* registrationArray = [[NSMutableArray alloc] init];

  // NSDictionary* mappingDictionary = ;

  [registrationArray
      addObject:
          [[CTSRestRegister alloc]
                 initWithPath:MLC_OAUTH_TOKEN_SIGNUP_REQ_PATH
                   httpMethod:MLC_OAUTH_TOKEN_SIGNUP_REQ_TYPE
               requestMapping:nil
              responseMapping:
                  [[CTSTypeToParameterMapping alloc]
                      initWithType:MLC_OAUTH_TOKEN_SIGNUP_RES_TYPE
                        parameters:MLC_OAUTH_TOKEN_SIGNUP_RESPONSE_MAPPING]]];

  [registrationArray
      addObject:
          [[CTSRestRegister alloc]
                 initWithPath:MLC_SIGNUP_REQ_PATH
                   httpMethod:MLC_SIGNUP_REQ_TYPE
               requestMapping:nil
              responseMapping:[[CTSTypeToParameterMapping alloc]
                                  initWithType:MLC_SIGNUP_RES_TYPE
                                    parameters:MLC_SIGNUP_RESPONSE_MAPPING]]];

  return registrationArray;
}

#pragma mark - public methods

- (void)requestChangePassword:(NSString*)userNameArg {
  if (![CTSUtility validateEmail:userNameArg]) {
    [delegate signUp:NO error:[CTSError getErrorForCode:EmailNotValid]];
    return;
  }
  [restService postObject:nil
                   atPath:MLC_REQUEST_CHANGE_PWD_REQ_PATH
               withHeader:[CTSUtility readSigninTokenAsHeader]
           withParameters:@{
             MLC_REQUEST_CHANGE_PWD_QUERY_USERNAME : userNameArg
           } withInfo:nil];
}
- (void)resetSignupCredentials {
  userNameSignup = @"";
  mobileSignUp = @"";
  passwordSignUp = @"";
}

- (void)failedSignupWithError:(NSError*)error {
  [self resetSignupCredentials];
  [delegate signUp:NO error:error];
}

- (void)requestInternalSignupMobile:(NSString*)mobile email:(NSString*)email {
  //  if (![CTSUtility validateEmail:email]) {
  //    [self failedSignupWithError:[CTSError getErrorForCode:EmailNotValid]];
  //    return;
  //  }
  //  if (![CTSUtility validateMobile:mobile]) {
  //    [self failedSignupWithError:[CTSError getErrorForCode:MobileNotValid]];
  //    return;
  //  }

  //  [restService postObject:nil
  //                   atPath:MLC_SIGNUP_REQ_PATH
  //               withHeader:[CTSUtility readSignupTokenAsHeader]
  //           withParameters:@{
  //             MLC_SIGNUP_QUERY_EMAIL : email,
  //             MLC_SIGNUP_QUERY_MOBILE : mobile
  //           } withInfo:nil];

  [restService postObject:nil
                   atPath:MLC_SIGNUP_REQ_PATH
               withHeader:nil
           withParameters:@{
             MLC_SIGNUP_QUERY_EMAIL : email,
             MLC_SIGNUP_QUERY_MOBILE : mobile
           } withInfo:nil];
}

- (void)requestSignUpWithEmail:(NSString*)email
                        mobile:(NSString*)mobile
                      password:(NSString*)password {
  if (![CTSUtility validateEmail:email]) {
    [self failedSignupWithError:[CTSError getErrorForCode:EmailNotValid]];
    return;
  }
  if (![CTSUtility validateMobile:mobile]) {
    [self failedSignupWithError:[CTSError getErrorForCode:MobileNotValid]];
    return;
  }

  userNameSignup = email;
  mobileSignUp = mobile;
  passwordSignUp = password;

  [self requestSignUpOauthToken];
}

- (void)requestSignUpOauthToken {
  ENTRY_LOG
  wasSignupCalled = YES;
  [restService postObject:nil
                   atPath:MLC_OAUTH_TOKEN_SIGNUP_REQ_PATH
               withHeader:nil
           withParameters:MLC_OAUTH_TOKEN_SIGNUP_QUERY_MAPPING
                 withInfo:MLC_OAUTH_TOKEN_SIGNUP_GRANT_TYPE];

  EXIT_LOG
}

- (void)requestSigninWithUsername:(NSString*)userNameArg
                         password:(NSString*)password {
  if (![CTSUtility validateEmail:userNameArg]) {
    [delegate signin:NO
         forUserName:userNameArg
               error:[CTSError getErrorForCode:EmailNotValid]];
    return;
  }
  userNameSignIn = userNameArg;
  NSDictionary* parameters = @{
    MLC_OAUTH_TOKEN_QUERY_CLIENT_ID : MLC_OAUTH_TOKEN_SIGNIN_CLIENT_ID,
    MLC_OAUTH_TOKEN_QUERY_CLIENT_SECRET : MLC_OAUTH_TOKEN_SIGNIN_CLIENT_SECRET,
    MLC_OAUTH_TOKEN_QUERY_GRANT_TYPE : MLC_SIGNIN_GRANT_TYPE,
    MLC_OAUTH_TOKEN_SIGNIN_QUERY_PASSWORD : password,
    MLC_OAUTH_TOKEN_SIGNIN_QUERY_USERNAME : userNameArg
  };

  [restService postObject:nil
                   atPath:MLC_OAUTH_TOKEN_SIGNUP_REQ_PATH
               withHeader:nil
           withParameters:parameters
                 withInfo:MLC_SIGNIN_GRANT_TYPE];
}

- (void)usePassword:(NSString*)password
     hashedUsername:(NSString*)hashedUsername {
  ENTRY_LOG

  NSString* token;

  token = [CTSUtility readFromDisk:MLC_SIGNIN_ACCESS_OAUTH_TOKEN];

  if (token == nil) {
    DDLogError(@"SignIn token Not Found,returning");
    return;
  }
  NSDictionary* headers = @{
    @"Authorization" : [NSString stringWithFormat:@" Bearer %@", token]
  };

  [restService putObject:nil
                  atPath:MLC_CHANGE_PASSWORD_REQ_PATH
              withHeader:headers
          withParameters:@{
            MLC_CHANGE_PASSWORD_QUERY_OLD_PWD : hashedUsername,
            MLC_CHANGE_PASSWORD_QUERY_NEW_PWD : password
          } withInfo:nil];
  EXIT_LOG
}

#pragma mark - CTSRestLayerProtocol methods
- (void)receivedObjectArray:(NSArray*)responseArray
                    forPath:(NSString*)path
                  withError:(NSError*)error
                   withInfo:(NSString*)info {
  ENTRY_LOG
  DDLogInfo(@" path %@", path);
  BOOL isSuccess = NO;

  if (error == nil)
    isSuccess = YES;

  if ([MLC_OAUTH_TOKEN_SIGNUP_REQ_PATH isEqualToString:path] &&
      [info isEqualToString:MLC_OAUTH_TOKEN_SIGNUP_GRANT_TYPE]) {
    for (CTSOauthTokenRes* result in responseArray) {
      NSLog(@"%@", result);
    }
    if (isSuccess) {
      // signup flow
      CTSOauthTokenRes* resultObject = [responseArray objectAtIndex:0];
      [CTSUtility saveToDisk:resultObject.accessToken
                          as:MLC_SIGNUP_ACCESS_OAUTH_TOKEN];
      [self requestInternalSignupMobile:mobileSignUp email:userNameSignup];
    } else {
      [self failedSignupWithError:error];
      return;
    }

  } else if ([MLC_OAUTH_TOKEN_SIGNUP_REQ_PATH isEqualToString:path] &&
             [info isEqualToString:MLC_SIGNIN_GRANT_TYPE]) {
    CTSOauthTokenRes* resultObject = [responseArray objectAtIndex:0];
    [CTSUtility saveToDisk:resultObject.accessToken
                        as:MLC_SIGNIN_ACCESS_OAUTH_TOKEN];

    if (wasSignupCalled == YES) {
      // in case of sign up flow
      if (isSuccess) {
        [self usePassword:passwordSignUp
            hashedUsername:[self generateBigIntegerString:userNameSignup]];
      } else {
        [self failedSignupWithError:error];
      }
      wasSignupCalled = NO;
    } else {
      // in case of sign in flow
      [delegate signin:isSuccess forUserName:userNameSignIn error:error];
    }

    [CTSUtility readFromDisk:MLC_SIGNIN_ACCESS_OAUTH_TOKEN];

  } else if ([MLC_SIGNUP_REQ_PATH isEqualToString:path]) {
    for (CTSSignUpRes* signupRes in responseArray) {
      NSLog(@"signupRes %@", signupRes);
      // change password
      //[self usePassword:TEST_PASSWORD for:SET_FIRSTTIME_PASSWORD];

      // get singn in oauth token for password use use hashed email
      // use it for sending the change password so that the password is set(for
      // old password use username)

      // always use this acess token
    }
    if (!isSuccess) {
      [self failedSignupWithError:error];
      return;
    } else {
      // signup flow - now sign in
      [self requestSigninWithUsername:userNameSignup
                             password:[self generateBigIntegerString:
                                                userNameSignup]];
    }

  } else if ([MLC_CHANGE_PASSWORD_REQ_PATH isEqualToString:path]) {
    DDLogInfo(@"password changed ");
    [self resetSignupCredentials];
    [delegate signUp:isSuccess error:error];
  } else if ([MLC_REQUEST_CHANGE_PWD_REQ_PATH isEqualToString:path]) {
    DDLogInfo(@"password change requested");
  }
  EXIT_LOG
}

#pragma mark - pseudo password generator methods

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
  (void)cc_digest([data bytes], [data length], md);
  return [NSData dataWithBytes:md length:digestLength];
}

- (NSData*)md5:(NSString*)email {
  NSData* data = [email dataUsingEncoding:NSASCIIStringEncoding];
  return digest(data, CC_MD5, CC_MD5_DIGEST_LENGTH);
}

- (NSArray*)copyOfRange:(NSArray*)original:(int)from:(int)to {
  int newLength = to - from;
  NSArray* destination;
  if (newLength < 0) {
  } else {
    int copy[newLength];
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

  NSArray* val = [self copyOfRange:array:[array count] - 3:[array count]];
  NSData* arrayData = [NSKeyedArchiver archivedDataWithRootObject:val];
  NSLog(@"%@", arrayData);
  int x = 0;
  for (int i = 0; i < [val count]; i++) {
    int z = [[val objectAtIndex:(val.count - 1 - i)] intValue];
    if (z < 0) {
      z = z + 256;
    }
    z = z << (8 * i);
    x = x + z;
    NSLog(@"%d", x);
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
  NSLog(@"random password:%@", large_CSV_String);
  return large_CSV_String;
}

@end
